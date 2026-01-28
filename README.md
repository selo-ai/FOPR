# FOPR - Vardiya ve Bordro Asistanı

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0.3-orange?style=for-the-badge)

FOPR, vardiyalı çalışanlar için özel olarak tasarlanmış, kişisel bir iş takip ve finansal hesaplama uygulamasıdır. Kullanıcının vardiya düzenini, maaşını, izinlerini ve fazla mesailerini tek bir merkezden, internete ihtiyaç duymadan yönetmesini sağlar.

## Temel Özellikler

### 1. Akıllı Vardiya Takvimi
- **Otomatik Döngü:** Her Pazartesi değişen 3'lü vardiya sistemi (Gece, Sabah, Akşam).
- **Görsel Takip:** Ana ekranda açılır/kapanır, renk kodlu aylık takvim.
- **Bayram & Tatil:** Resmi tatiller ve bayramlar takvimde otomatik olarak işaretlenir.

### 2. Detaylı Maaş Hesaplama
- **Net/Brüt Hesabı:** Saatlik ücret üzerinden; normal çalışma, fazla mesai (%100 zamlı), gece farkı (%20) ve hafta tatili (%150) hesaplamaları.
- **Kesintiler:** SGK, İşsizlik, Gelir Vergisi (Kümülatif dilim hesabı), Damga Vergisi.
- **Özel Kesintiler:** Sendika, BES (Otomatik %6), İcra, Özel Sigorta vb.
- **Yardımlar:** Yakacak, Çocuk ve Aile yardımları gibi ek gelir kalemleri.

### 3. Fazla Mesai Takibi
- Gün bazlı fazla mesai girişi.
- Aylık ve yıllık toplam mesai saati istatistikleri.
- Ana ekranda anlık mesai durumu özetlenir.

### 4. İzin Yönetimi
- **Hak Ediş Takibi:** Kıdem yılına göre izin hakkı hesaplama.
- **İzin Türleri:** Yıllık izin, mazeret, rapor, ücretsiz izin vb. kategoriler.
- Kalan izin günlerinin ve kullanılan izinlerin detaylı raporu.

### 5. Kişisel Notlar
- İşle ilgili notlar alma, tarihe göre kaydetme ve yıldızlayarak önemlileri ayırma.

### 6. Hızlı Erişim (Quick Actions)
- Uygulama ikonuna basılı tutarak "Mesai Ekle" ve "İzin Ekle" kısayol menülerine erişilebilir.
- Tek dokunuşla ilgili veri giriş ekranını açma özelliği.

### 7. Ana Ekran Widget'ı
- Uygulamayı açmadan ana ekranda (2x2 boyutunda widget) önemli bilgileri görüntüleme.
- **Takip Edilen Veriler:**
    - Bu ayki ve yıllık toplam fazla mesai saati.
    - Bu ay kullanılan ve toplam kalan yıllık izin günü.

### 8. Profil ve Onboarding
- İlk açılışta kişisel bilgileri (Ad Soyad, Başlangıç Tarihi) alarak sistemi kişiselleştirir.

## Teknik Detaylar
- **Framework:** Flutter
- **Veritabanı:** Hive (Yerel veri depolama)
- **Gizlilik:** Tüm veriler cihazda saklanır, internet gerektirmez.
- **AI Asistanı:** Google DeepMind (Agentic Coding)
- **Geliştirme Ortamı:** Antigravity

## Geliştirici
- Selahattin Gültekin

