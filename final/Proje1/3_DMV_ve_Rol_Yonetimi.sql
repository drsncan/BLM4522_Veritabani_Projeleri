USE Proje1_Performans;
GO

PRINT '--- 1. DMV ÝLE PERFORMANS ÝZLEME ---';
-- Dynamic Management Views (DMV) kullanarak sistemde en çok CPU tüketen 5 sorguyu bulalým.
-- Bu, arka planda hangi sorgularýn yavaþ çalýþtýðýný tespit etmek için harika bir yöntemdir.
SELECT TOP 5
    t.text AS [Sorgu Metni],
    s.total_worker_time AS [Toplam CPU Süresi (mikrosaniye)],
    s.execution_count AS [Çalýþtýrýlma Sayýsý],
    s.total_logical_reads AS [Toplam Mantýksal Okuma]
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) t
ORDER BY s.total_worker_time DESC;
GO

PRINT '--- 2. VERÝ YÖNETÝCÝSÝ ROLLERÝ VE ERÝÞÝM YÖNETÝMÝ ---';
-- Farklý roller için eriþim yönetimi yapýyoruz.

-- A) Rolleri Oluþturma
CREATE ROLE RaporlamaUzmani;
CREATE ROLE VeriGirisUzmani;
GO

-- B) Yetkileri Atama
-- Raporlama uzmaný sadece verileri okuyabilsin (SELECT)
GRANT SELECT ON Satislar TO RaporlamaUzmani;

-- Veri giriþ uzmaný veri ekleyip, güncelleyip, silebilsin ama tablo yapýsýný deðiþtiremesin
GRANT INSERT, UPDATE, DELETE ON Satislar TO VeriGirisUzmani;
GO

-- C) Test Kullanýcýlarý Oluþturma (Sadece veritabaný seviyesinde, login olmadan)
CREATE USER RaporKullanicisi WITHOUT LOGIN;
CREATE USER VeriKullanicisi WITHOUT LOGIN;
GO

-- D) Kullanýcýlarý Rollere Dahil Etme
ALTER ROLE RaporlamaUzmani ADD MEMBER RaporKullanicisi;
ALTER ROLE VeriGirisUzmani ADD MEMBER VeriKullanicisi;
GO

-- Ýþlemlerin baþarýlý olduðunu test edelim (Hangi kullanýcýnýn hangi rolde olduðunu listeleme)
SELECT DP1.name AS VeritabaniRolu,   
   ISNULL (DP2.name, 'Üye Yok') AS RolUyesi   
FROM sys.database_role_members AS DRM  
RIGHT OUTER JOIN sys.database_principals AS DP1  
   ON DRM.role_principal_id = DP1.principal_id  
LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R' AND DP1.name IN ('RaporlamaUzmani', 'VeriGirisUzmani');
GO