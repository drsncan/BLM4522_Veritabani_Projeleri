USE Proje1_Performans;
GO

-- 1. Performans Ýstatistiklerini Açalým (Okuma sayýlarýný ve süreyi görmek için)
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT '--- ÝNDEKS OLMADAN ÖNCEKÝ DURUM ---';
-- 2. Ýndeks Olmadan Yavaþ Çalýþacak Sorgu
-- 'Ýstanbul' þehrindeki belirli bir tarihten sonraki satýþlarýn satýcý bazlý toplamý
-- (Bu aþamada tablo büyük olduðu için SQL Server tüm tabloyu okumak zorunda kalacak: Clustered Index Scan)
SELECT SaticiAdi, SUM(Tutar) AS ToplamSatis
FROM Satislar
WHERE Sehir = 'Ýstanbul' AND SatisTarihi >= '2025-01-01'
GROUP BY SaticiAdi;
GO

PRINT '--- ÝNDEKS OLUÞTURULUYOR ---';
-- 3. Performans Sorununu Çözmek Ýçin Non-Clustered Ýndeks Oluþturma
-- Sehir ve SatisTarihi kolonlarýnda arama (WHERE) yaptýðýmýz için bu kolonlara indeks atýyoruz.
-- SaticiAdi ve Tutar kolonlarýný ise INCLUDE ederek sorgunun asýl tabloya gitmeden sadece indeksten cevap dönmesini saðlýyoruz (Covering Index mantýðý).
CREATE NONCLUSTERED INDEX IX_Satislar_Sehir_SatisTarihi 
ON Satislar (Sehir, SatisTarihi)
INCLUDE (SaticiAdi, Tutar);
GO

PRINT '--- ÝNDEKS SONRASI DURUM ---';
-- 4. Ýndeks Sonrasý Ayný Sorguyu Tekrar Çalýþtýrma 
-- (Bu kez SQL Server tüm tabloyu taramak yerine doðrudan indekse gidecek: Index Seek)
SELECT SaticiAdi, SUM(Tutar) AS ToplamSatis
FROM Satislar
WHERE Sehir = 'Ýstanbul' AND SatisTarihi >= '2025-01-01'
GROUP BY SaticiAdi;
GO

-- Ýstatistikleri kapatalým
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO