-- 1. Güvenlik Projesi Ýçin Veritabaný Oluþturma
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Proje3_Guvenlik')
BEGIN
    CREATE DATABASE Proje3_Guvenlik;
END
GO

USE Proje3_Guvenlik;
GO

PRINT '--- TABLO KURULUMU ---';
-- Varsa eski tabloyu silip temiz bir baþlangýç yapýyoruz
IF OBJECT_ID('Musteriler', 'U') IS NOT NULL 
    DROP TABLE Musteriler;
GO

-- Þifreli veriyi tutmak için tabloyu oluþturuyoruz
CREATE TABLE Musteriler (
    MusteriID INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad NVARCHAR(100),
    KrediKartiNo_Sifreli VARBINARY(MAX) 
);
GO

PRINT '--- KOLON BAZLI ÞÝFRELEME (CELL-LEVEL ENCRYPTION) KURULUMU ---';

-- A. Master Key (Veritabaný ana anahtarý - varsa atlar)
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'CokGucluBirSifre_2026!';
END
GO

-- B. Þifreleme için Sertifika Oluþturma (Varsa atlar)
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'KolonSifrelemeSertifikasi')
BEGIN
    CREATE CERTIFICATE KolonSifrelemeSertifikasi WITH SUBJECT = 'Kredi Karti Sifreleme';
END
GO

-- C. AES_256 Algoritmasý ile Simetrik Anahtar Oluþturma (Varsa atlar)
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'KrediKartiAnahtari')
BEGIN
    CREATE SYMMETRIC KEY KrediKartiAnahtari
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE KolonSifrelemeSertifikasi;
END
GO

PRINT '--- ÞÝFRELÝ VERÝ EKLEME ÝÞLEMÝ ---';
-- D. Anahtarý Açýp Verileri Þifreleyerek (EncryptByKey) Ekliyoruz
OPEN SYMMETRIC KEY KrediKartiAnahtari DECRYPTION BY CERTIFICATE KolonSifrelemeSertifikasi;

INSERT INTO Musteriler (AdSoyad, KrediKartiNo_Sifreli) 
VALUES ('Dursun Can Çýnar', EncryptByKey(Key_GUID('KrediKartiAnahtari'), '4532-1111-2222-3333')),
       ('Ahmet Yýlmaz', EncryptByKey(Key_GUID('KrediKartiAnahtari'), '5555-4444-3333-2222'));

-- Ýþlem bitince güvenliði saðlamak için anahtarý mutlaka kapatýyoruz
CLOSE SYMMETRIC KEY KrediKartiAnahtari;
GO

PRINT '--- SONUÇ KONTROLÜ (ÞÝFRELÝ VS ÇÖZÜLMÜÞ) ---';
-- E. Tablodaki verileri okuma (DecryptByKey ile çözüp VARCHAR'a çeviriyoruz)
OPEN SYMMETRIC KEY KrediKartiAnahtari DECRYPTION BY CERTIFICATE KolonSifrelemeSertifikasi;

SELECT 
    AdSoyad, 
    KrediKartiNo_Sifreli AS SifreliHali,
    CONVERT(VARCHAR(20), DecryptByKey(KrediKartiNo_Sifreli)) AS CozulmusHali
FROM Musteriler;

CLOSE SYMMETRIC KEY KrediKartiAnahtari;
GO