/*******************************************************************************
    BLM4522 - Að Tabanlý Paralel Daðýtým Sistemleri
    Proje 2: Veritabaný Yedekleme ve Felaketten Kurtarma Planý
    
    Öðrenci: Can
    Veritabaný: AdventureWorks2025
    Sunucu: SQL Server Express
*******************************************************************************/

USE master;
GO

-- 1. ADIM: TAM YEDEK (FULL BACKUP)
-- Stratejinin baþlangýç noktasý olarak veritabanýnýn tam kopyasý alýnýr.
BACKUP DATABASE AdventureWorks2025
TO DISK = 'C:\Users\drsncan\Desktop\SQLBackups\AdventureWorks_Full.bak'
WITH FORMAT, 
     NAME = 'AdventureWorks - Ýlk Tam Yedek';
GO


-- 2. ADIM: FARK YEDEÐÝ (DIFFERENTIAL BACKUP)
-- Tam yedekten bu yana gerçekleþen deðiþiklikleri kapsar.
BACKUP DATABASE AdventureWorks2025
TO DISK = 'C:\Users\drsncan\Desktop\SQLBackups\AdventureWorks_Diff.bak'
WITH DIFFERENTIAL,
     NAME = 'AdventureWorks - Fark Yedeði';
GO


-- 3. ADIM: FELAKET SENARYOSU (VERÝ SÝLÝNMESÝ)
-- Kaza ile veri silinmesi durumunu simüle etmek için EmailAddress tablosu hedef alýnmýþtýr.
USE AdventureWorks2025;
GO

-- Silme öncesi kontrol
SELECT COUNT(*) AS SilinmedenOncekiSayi FROM Person.EmailAddress;

-- Kritik verilerin silinmesi
DELETE FROM Person.EmailAddress WHERE EmailAddress LIKE 'a%';

-- Silme sonrasý kontrol (Verilerin kaybolduðu doðrulanýr)
SELECT COUNT(*) AS SilindiktenSonrakiSayi FROM Person.EmailAddress;
GO


-- 4. ADIM: FELAKETTEN KURTARMA (RESTORE SÜRECÝ)
-- Veritabaný, verilerin silinmediði en güncel Fark Yedeði anýna geri döndürülür.
USE master;
GO

-- Aktif baðlantýlarý kopar ve veritabanýný kurtarma moduna al
ALTER DATABASE AdventureWorks2025 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Önce Tam Yedek yüklenir (NORECOVERY ile bir sonraki yedek beklenir)
RESTORE DATABASE AdventureWorks2025
FROM DISK = 'C:\Users\drsncan\Desktop\SQLBackups\AdventureWorks_Full.bak'
WITH NORECOVERY, REPLACE;
GO

-- Ardýndan Fark Yedek yüklenir (RECOVERY ile veritabaný eriþime açýlýr)
RESTORE DATABASE AdventureWorks2025
FROM DISK = 'C:\Users\drsncan\Desktop\SQLBackups\AdventureWorks_Diff.bak'
WITH RECOVERY;
GO

-- Veritabanýný tekrar çoklu kullanýcý moduna döndür
ALTER DATABASE AdventureWorks2025 SET MULTI_USER;
GO


-- 5. ADIM: SONUÇ KONTROL
-- Verilerin baþarýyla geri gelip gelmediði teyit edilir.
USE AdventureWorks2025;
GO
SELECT COUNT(*) AS KurtarilanKayitSayisi FROM Person.EmailAddress;
GO