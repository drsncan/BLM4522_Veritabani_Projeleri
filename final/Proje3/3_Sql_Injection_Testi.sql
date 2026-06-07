USE Proje3_Guvenlik;
GO

PRINT '=======================================================';
PRINT '--- SQL INJECTION TESTÝ: ZARARLI GÝRÝÞ HAZIRLIÐI ---';
PRINT '=======================================================';
-- Saldýrganýn, uygulamanýn arama kutusuna yazdýðý tipik bir zararlý SQL kodu:
DECLARE @ZararliGiris NVARCHAR(100) = 'Ahmet'' OR ''1''=''1';

PRINT '';
PRINT '--- 1. DURUM: GÜVENLÝKSÝZ YAPI (UYGULAMADA DOÐRUDAN YAZILSAYDI) ---';
-- Eðer uygulama tarafýnda parametre yerine metin birleþtirme (string concatenation) yapýlsaydý:
DECLARE @GuvenliksizSorgu NVARCHAR(MAX) = 'SELECT AdSoyad FROM Musteriler WHERE AdSoyad = ''' + @ZararliGiris + '''';
PRINT 'Arka Planda Çalýþacak Olan Kötü Niyetli Sorgu: ' + @GuvenliksizSorgu;

-- DÝKKAT: Bu kod çalýþtýrýldýðýnda WHERE þartý (OR '1'='1' her zaman doðru olduðu için) bozulur 
-- ve veritabanýndaki TÜM MÜÞTERÝLER yetkisiz bir þekilde ekranda listelenir! (Veri Sýzýntýsý)
EXEC (@GuvenliksizSorgu);
GO

PRINT '';
PRINT '--- 2. DURUM: GÜVENLÝ YAPI (BÝZÝM STORED PROCEDURE MÝMARÝMÝZ) ---';
-- Ayný zararlý giriþi bizim güvenliðini saðladýðýmýz Stored Procedure'e gönderiyoruz.
DECLARE @ZararliGiris NVARCHAR(100) = 'Ahmet'' OR ''1''=''1';

PRINT 'Saldýrý Stored Procedure üzerinden deneniyor...';
-- Prosedür, gönderilen bu metni çalýþtýrýlabilir bir SQL komutu olarak deðil, 
-- kelimesi kelimesine "Ahmet' OR '1'='1" adýnda bir insan ismi olarak arayacaktýr.
-- Veritabanýnda bu isimde biri olmadýðý için boþ (0 satýr) dönecek ve sistemi koruyacaktýr.
EXEC sp_MusteriAra @AramaMetni = @ZararliGiris;
GO