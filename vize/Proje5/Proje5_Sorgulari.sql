/*******************************************************************************
    BLM4522 - Að Tabanlý Paralel Daðýtým Sistemleri
    Proje 5: Veri Temizleme ve ETL Süreçleri Tasarýmý
    
    Öðrenci: Dursun Can Çýnar
    Veritabaný: AdventureWorks2025
*******************************************************************************/

USE AdventureWorks2025;
GO

-- ==========================================
-- 1. EXTRACT (Çýkarma): Staging (Geçici) Tablo
-- ==========================================
-- Dýþ sistemlerden gelecek hatalý verileri karþýlayacak olan tablo
CREATE TABLE Musteri_Staging (
    MusteriID INT,
    TamAd VARCHAR(100),
    Eposta VARCHAR(100),
    Telefon VARCHAR(20),
    KayitTarihi VARCHAR(50) 
);
GO

-- Hatalý, tutarsýz ve mükerrer verilerin sisteme alýnmasý
INSERT INTO Musteri_Staging (MusteriID, TamAd, Eposta, Telefon, KayitTarihi)
VALUES 
(1, 'ahmet YILMAZ', 'ahmet.yilmaz@email.com', '555-123-4567', '2023-01-15'), -- Formatý bozuk ama kurtarýlabilir
(2, 'Ayþe Demir', 'aysedemir_gmail.com', '5559876543', '2023/02/20'),    -- @ iþareti eksik
(3, 'mehmet KAYA', NULL, 'Bilinmiyor', '15.03.2023'),                     -- E-posta eksik, telefon metin
(4, 'Fatma  Þahin', 'fatma@sahin.com', '555-111-22-33', '2026-13-45'),    -- 13. Ay hatasý (Geçersiz tarih)
(1, 'ahmet YILMAZ', 'ahmet.yilmaz@email.com', '555-123-4567', '2023-01-15'), -- Duplicate (Mükerrer) kayýt
(5, 'Ali Can', 'alican@sirket.com', NULL, NULL);                          -- NULL veri hatasý
GO


-- ==========================================
-- 2. HEDEF TABLO OLUÞTURMA
-- ==========================================
-- Temizlenen verilerin yükleneceði standartlara uygun ana tablo
CREATE TABLE Musteri_Hedef (
    MusteriID INT PRIMARY KEY,
    TamAd VARCHAR(100),
    Eposta VARCHAR(100),
    Telefon VARCHAR(20),
    KayitTarihi DATE 
);
GO


-- ==========================================
-- 3. TRANSFORM & LOAD (Dönüþtürme ve Yükleme)
-- ==========================================
-- CTE (Common Table Expression) ile verilerin temizlenmesi
WITH TemizlenmisVeri AS (
    SELECT 
        MusteriID,
        
        -- Ýsim formatlama: Boþluklarý kýrp, tek boþluða düþür, büyük harf yap
        UPPER(REPLACE(LTRIM(RTRIM(TamAd)), '  ', ' ')) AS TamAd,
        
        -- E-posta doðrulama: @ ve . kontrolü
        CASE 
            WHEN Eposta LIKE '%@%.%' THEN LOWER(LTRIM(RTRIM(Eposta))) 
            ELSE NULL 
        END AS Eposta,
        
        -- Telefon temizliði: Harf varsa iptal et, tireleri kaldýr
        CASE 
            WHEN Telefon LIKE '%[A-Za-z]%' THEN NULL 
            ELSE REPLACE(Telefon, '-', '') 
        END AS Telefon,
        
        -- Tarih standartlaþtýrma: Ayraçlarý düzelt ve geçerli DATE tipine çevir
        TRY_CONVERT(DATE, REPLACE(REPLACE(KayitTarihi, '/', '-'), '.', '-'), 120) AS KayitTarihi,

        -- Mükerrer kayýt engelleme: Ayný ID'ye sahip satýrlarý numaralandýr
        ROW_NUMBER() OVER(PARTITION BY MusteriID ORDER BY MusteriID) AS SiraNo
    FROM Musteri_Staging
)

-- Temiz verilerin hedef tabloya yüklenmesi (Load)
INSERT INTO Musteri_Hedef (MusteriID, TamAd, Eposta, Telefon, KayitTarihi)
SELECT MusteriID, TamAd, Eposta, Telefon, KayitTarihi
FROM TemizlenmisVeri
WHERE SiraNo = 1 -- Sadece tekil (ilk) kayýtlarý al
  AND Eposta IS NOT NULL 
  AND KayitTarihi IS NOT NULL; 
GO


-- ==========================================
-- 4. VERÝ KALÝTESÝ RAPORU
-- ==========================================
-- ETL sürecinin kalite ve fire metrikleri
SELECT 
    (SELECT COUNT(*) FROM Musteri_Staging) AS Toplam_Gelen_Kayit,
    (SELECT COUNT(*) FROM Musteri_Hedef) AS Basariyla_Yuklenen_Kayit,
    ((SELECT COUNT(*) FROM Musteri_Staging) - (SELECT COUNT(*) FROM Musteri_Hedef)) AS Reddedilen_Hatali_Kayit;
GO