-- 1. Veritabanýný Oluþturma
CREATE DATABASE Proje1_Performans;
GO

USE Proje1_Performans;
GO

-- 2. Test Tablosunu Oluþturma
CREATE TABLE Satislar (
    SatisID INT IDENTITY(1,1) PRIMARY KEY,
    SaticiAdi NVARCHAR(50),
    Sehir NVARCHAR(50),
    SatisTarihi DATETIME,
    Tutar DECIMAL(18,2)
);
GO

-- 3. Tabloya 500.000 Satýr Rastgele Veri Ekleme (Performans testi için büyük veri þart)
SET NOCOUNT ON;
DECLARE @i INT = 1;
DECLARE @RastgeleSayi INT;

WHILE @i <= 500000
BEGIN
    SET @RastgeleSayi = ABS(CHECKSUM(NEWID())) % 5; -- 5 farklý þehir ve satýcý için

    INSERT INTO Satislar (SaticiAdi, Sehir, SatisTarihi, Tutar)
    VALUES (
        CHOOSE(@RastgeleSayi + 1, 'Ali', 'Ayþe', 'Mehmet', 'Fatma', 'Can'),
        CHOOSE(@RastgeleSayi + 1, 'Ankara', 'Ýstanbul', 'Ýzmir', 'Bursa', 'Antalya'),
        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 1000), GETDATE()), -- Son 1000 gün içinde rastgele tarih
        CAST((ABS(CHECKSUM(NEWID())) % 10000) AS DECIMAL(18,2)) -- Rastgele tutar
    );
    
    SET @i = @i + 1;
END;
GO

-- Verilerin baþarýyla eklendiðini kontrol edelim
SELECT COUNT(*) AS ToplamKayit FROM Satislar;