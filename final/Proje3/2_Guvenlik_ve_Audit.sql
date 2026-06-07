USE master;
GO

PRINT '--- 1. SQL SERVER AUTHENTICATION VE ERÝÞÝM YÖNETÝMÝ ---';
-- Güvenlik testi için özel bir SQL Login (Giriþ) oluþturuyoruz. Varsa önce siliyoruz.
IF EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'GuvenlikUzmani')
    DROP LOGIN GuvenlikUzmani;

CREATE LOGIN GuvenlikUzmani WITH PASSWORD = 'StrongPassword123!';
GO

USE Proje3_Guvenlik;
GO

-- Bu login için veritabanýmýzda bir User (Kullanýcý) tanýmlýyoruz.
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'GuvenlikUzmaniUser')
    DROP USER GuvenlikUzmaniUser;

CREATE USER GuvenlikUzmaniUser FOR LOGIN GuvenlikUzmani;
GO


PRINT '--- 2. SQL INJECTION KORUMASI (STORED PROCEDURE) ---';
-- Veritabanýný SQL Injection saldýrýlarýndan korumanýn en güvenli yolu parametrik Stored Procedure (Saklý Yordam) kullanmaktýr.
-- Varsa eski prosedürü siliyoruz.
IF OBJECT_ID('sp_MusteriAra', 'P') IS NOT NULL 
    DROP PROCEDURE sp_MusteriAra;
GO

CREATE PROCEDURE sp_MusteriAra
    @AramaMetni NVARCHAR(100)
AS
BEGIN
    -- Parametre kullanýldýðý için dýþarýdan gelen zararlý kodlar çalýþtýrýlamaz.
    SELECT AdSoyad FROM Musteriler WHERE AdSoyad = @AramaMetni;
END;
GO

-- Güvenlik uzmanýna sadece bu güvenli prosedürü çalýþtýrma yetkisi veriyoruz (tabloyu doðrudan okuyamaz).
GRANT EXECUTE ON sp_MusteriAra TO GuvenlikUzmaniUser;
GO


PRINT '--- 3. DOSYA TABANLI AUDIT LOG (ÝZLEME) KURULUMU ---';
-- Önce veritabaný izlemesini kapatýp siliyoruz (Varsa)
USE Proje3_Guvenlik;
GO
IF EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'Proje3_DB_Audit_Spec')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION Proje3_DB_Audit_Spec WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION Proje3_DB_Audit_Spec;
END
GO

-- Sonra sunucu izlemesini kapatýp siliyoruz (Varsa)
USE master;
GO
IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Proje3_ServerAudit')
BEGIN
    ALTER SERVER AUDIT Proje3_ServerAudit WITH (STATE = OFF);
    DROP SERVER AUDIT Proje3_ServerAudit; -- HATA BURADAYDI, DÜZELTÝLDÝ.
END
GO

-- Yeni dosya tabanlý (FILE) Audit mekanizmasýný kuruyoruz
-- DÝKKAT: C:\ sürücüsünde SQL_Loglar adýnda bir klasör oluþturduðundan emin ol!
CREATE SERVER AUDIT Proje3_ServerAudit
TO FILE (FILEPATH = 'C:\SQL_Loglar\')
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);
GO

-- Audit mekanizmasýný aktif ediyoruz.
ALTER SERVER AUDIT Proje3_ServerAudit WITH (STATE = ON);
GO

USE Proje3_Guvenlik;
GO
-- Veritabaný seviyesinde izleme kurallarýný tekrar ekliyoruz
CREATE DATABASE AUDIT SPECIFICATION Proje3_DB_Audit_Spec
FOR SERVER AUDIT Proje3_ServerAudit
ADD (SELECT ON dbo.Musteriler BY public) 
WITH (STATE = ON);
GO

PRINT 'Tüm güvenlik, SQL Injection korumasý ve dosya tabanlý izleme (Audit) iþlemleri baþarýyla tamamlandý!';