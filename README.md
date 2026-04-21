# BLM4522 Ağ Tabanlı Paralel Dağıtım Sistemleri - Veritabanı Projeleri

Bu depo, Ankara Üniversitesi Bilgisayar Mühendisliği Bölümü **BLM4522 Ağ Tabanlı Paralel Dağıtım Sistemleri** dersi vize projesi kapsamında hazırlanan veritabanı yönetimi, otomasyonu ve ETL süreçleri çalışmalarını içermektedir.

**Geliştirici:** Dursun Can Çınar (22290285)  
**Kullanılan Teknolojiler:** Microsoft SQL Server 2025, SSMS, T-SQL, SQLCMD, Windows Task Scheduler

---

## 🗄️ Proje 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı

Bu projede, operasyonel bir veritabanı (AdventureWorks) üzerinde veri kaybını önlemek amacıyla katmanlı bir yedekleme mimarisi tasarlanmış ve felaket kurtarma senaryoları test edilmiştir.

* **Tam ve Fark Yedekleme:** `FULL` ve `DIFFERENTIAL` backup stratejileri oluşturulmuştur.
* **Point-in-Time Restore:** Kaza ile silinen binlerce kritik e-posta verisi, sistem `SINGLE_USER` moduna alınarak log/fark yedekleri üzerinden eksiksiz bir şekilde kurtarılmıştır.
* **Otomasyon:** SQL Server Express sürümü kısıtlamaları aşılarak, `sqlcmd` ve Windows Görev Zamanlayıcı (Task Scheduler) entegrasyonu ile yedekleme süreçleri otonom hale getirilmiştir.

▶️ **[Proje 2 - Uygulama ve Sunum Videosunu İzlemek İçin Tıklayın](https://youtu.be/ek3XNdz6CSo)**

---

## 🧹 Proje 5: Veri Temizleme ve ETL Süreçleri Tasarımı

Bu projede, büyük veri kümelerinin analitik sistemlere aktarılmadan önce geçirdiği nitelikli hale getirme (Extract, Transform, Load) süreçleri tasarlanmıştır.

* **Extract (Çıkarma):** Dış kaynaklardan gelen hatalı, tutarsız ve mükerrer kayıtlar bir `Staging` (geçici) tabloya alınmıştır.
* **Transform (Dönüştürme):** T-SQL fonksiyonları (`TRY_CONVERT`, `ROW_NUMBER`, `REPLACE`, `UPPER/LOWER`, `CASE WHEN`) ve CTE (Common Table Expression) mimarisi kullanılarak veriler standartlaştırılmış, hatalı veri tipleri filtrelenmiş ve mükerrer kayıtlar tekilleştirilmiştir.
* **Load (Yükleme):** Kalite standartlarını geçen temiz veriler `Hedef` tabloya aktarılmış ve sürecin fire oranlarını gösteren otomatik bir **Veri Kalitesi Raporu** oluşturulmuştur.

▶️ **[Proje 5 - Uygulama ve Sunum Videosunu İzlemek İçin Tıklayın](https://youtu.be/oBnKQXlxvgI)**

---
*Bu projeler akademik amaçlı geliştirilmiştir.*