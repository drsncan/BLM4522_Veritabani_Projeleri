USE Proje3_Guvenlik;
GO

PRINT '--- AUDIT LOG TESTÝ ÝÇÝN TABLO OKUMASI YAPILIYOR ---';
-- Sistemi dinleyen Audit mekanizmasýný tetiklemek için tabloya doðrudan SELECT atýyoruz.
SELECT * FROM Musteriler;
GO