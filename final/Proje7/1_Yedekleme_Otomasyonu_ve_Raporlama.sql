USE master;
GO

PRINT '--- 1. YEDEKLEME RAPORLARI ÝÇÝN TABLO OLUÞTURMA ---';
-- Yedekleme geçmiþini ve durumunu tutacaðýmýz yeni bir veritabaný ve tablo kuruyoruz
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Proje7_Otomasyon')
BEGIN
    CREATE DATABASE Proje7_Otomasyon;
END
GO

USE Proje7_Otomasyon;
GO

IF OBJECT_ID('YedeklemeRaporlari', 'U') IS NOT NULL DROP TABLE YedeklemeRaporlari;

CREATE TABLE YedeklemeRaporlari (
    RaporID INT IDENTITY(1,1) PRIMARY KEY,
    VeritabaniAdi NVARCHAR(100),
    YedekTarihi DATETIME DEFAULT GETDATE(),
    Durum NVARCHAR(50), -- 'BAÞARILI' veya 'BAÞARISIZ'
    HataMesaji NVARCHAR(MAX)
);
GO

PRINT '--- 2. YEDEKLEME VE BÝLDÝRÝM PROSEDÜRÜ (T-SQL SCRIPTING) ---';
-- Bu prosedür yedekleme yapar, sonucunu rapora yazar ve hata varsa uyarý üretir.

IF OBJECT_ID('sp_VeritabaniYedekle', 'P') IS NOT NULL DROP PROCEDURE sp_VeritabaniYedekle;
GO

CREATE PROCEDURE sp_VeritabaniYedekle
    @DBName NVARCHAR(100),
    @BackupPath NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @BackupFile NVARCHAR(600);
    DECLARE @ErrorMessage NVARCHAR(MAX);
    
    -- Dosya ismine tarih ve saat ekleyerek her yedeði benzersiz yapýyoruz
    SET @BackupFile = @BackupPath + @DBName + '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(19), GETDATE(), 120), '-', ''), ' ', '_'), ':', '') + '.bak';

    BEGIN TRY
        -- Yedekleme iþlemi 
        BACKUP DATABASE @DBName TO DISK = @BackupFile WITH FORMAT, INIT, NAME = 'Full Backup';
        
        -- Baþarýlý olursa rapor tablosuna ekle
        INSERT INTO YedeklemeRaporlari (VeritabaniAdi, Durum, HataMesaji)
        VALUES (@DBName, 'BAÞARILI', 'Yedekleme dosyasý oluþturuldu: ' + @BackupFile);
        
        PRINT 'Yedekleme Baþarýlý: ' + @BackupFile;
    END TRY
    BEGIN CATCH
        -- Hata oluþursa yakala
        SET @ErrorMessage = ERROR_MESSAGE();
        
        -- Baþarýsýz durumunu rapor tablosuna ekle
        INSERT INTO YedeklemeRaporlari (VeritabaniAdi, Durum, HataMesaji)
        VALUES (@DBName, 'BAÞARISIZ', @ErrorMessage);
        
        -- YÖNETÝCÝYE BÝLDÝRÝM (Hata fýrlatma / Uyarý Mekanizmasý)
        PRINT '-------------------------------------------------------------------';
        PRINT 'DÝKKAT! YEDEKLEME BAÞARISIZ OLDU. YÖNETÝCÝYE BÝLDÝRÝM GÖNDERÝLÝYOR...';
        PRINT '-------------------------------------------------------------------';
        RAISERROR('CRITICAL ALERT - Yedekleme Hatasý: %s veritabaný yedeklenemedi. Detay: %s', 16, 1, @DBName, @ErrorMessage);
        
        -- Not: Enterprise sistemlerde bu noktada sp_send_dbmail ile e-posta tetiklenir.
    END CATCH
END;
GO

PRINT '--- 3. TEST: BAÞARILI YEDEKLEME SENARYOSU ---';
-- Proje 1'de oluþturduðumuz veritabanýnýn yedeðini alýyoruz
EXEC sp_VeritabaniYedekle @DBName = 'Proje1_Performans', @BackupPath = 'C:\SQL_Loglar\';
GO

PRINT '--- 4. TEST: BAÞARISIZ YEDEKLEME (UYARI) SENARYOSU ---';
-- Bilerek hata verdirmek için var olmayan bir sürücü/klasör yolu veriyoruz (Z:\)
EXEC sp_VeritabaniYedekle @DBName = 'Proje1_Performans', @BackupPath = 'Z:\Olmayan_Klasor\';
GO

PRINT '--- 5. DENETÝM VE YEDEKLEME RAPORU ---';
-- Ýþlemlerin arka planda nasýl raporlandýðýný görelim
SELECT 
    RaporID, 
    VeritabaniAdi, 
    YedekTarihi, 
    Durum, 
    HataMesaji 
FROM YedeklemeRaporlari 
ORDER BY YedekTarihi DESC;
GO

/* --- 6. SQL SERVER AGENT ÝÇÝN OTOMASYON KODU (RAPOR ÝÇÝN) ---
Hocam, SQL Server Express sürümünde Agent servisi aktif olmadýðý için job oluþturma kodu 
aþaðýda T-SQL formatýnda hazýrlanmýþ olup, testler manuel tetiklenerek gerçekleþtirilmiþtir.

USE msdb;
GO
EXEC dbo.sp_add_job @job_name = N'Gunluk_Veritabani_Yedekleme';
EXEC sp_add_jobstep 
    @job_name = N'Gunluk_Veritabani_Yedekleme',
    @step_name = N'Yedekleme_Adimi',
    @subsystem = N'TSQL',
    @command = N'EXEC Proje7_Otomasyon.dbo.sp_VeritabaniYedekle @DBName = ''Proje1_Performans'', @BackupPath = ''C:\SQL_Loglar\''',
    @retry_attempts = 3,
    @retry_interval = 5;
EXEC dbo.sp_add_schedule 
    @schedule_name = N'Gece_Yarisi_Yedek',
    @freq_type = 4, -- Günlük
    @freq_interval = 1,
    @active_start_time = 000000; -- Gece 00:00
EXEC sp_attach_schedule @job_name = N'Gunluk_Veritabani_Yedekleme', @schedule_name = N'Gece_Yarisi_Yedek';
EXEC dbo.sp_add_jobserver @job_name = N'Gunluk_Veritabani_Yedekleme';
GO
*/