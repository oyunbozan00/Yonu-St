# Yonu-S

**Yonu-S**, imalata dayalı üretim yapan küçük atölyeler için geliştirilmiş, süreç bazlı bir stok takip uygulamasıdır.

### 🚀 Özellikler
- Komut bazlı veri girişi (ör: `zü15d`, `zü1xb`)
- Kategoriler: Dökülen, Boyanan, Hazır, Verilen, Sipariş, Kalan Döküm, Kalan Boyama
- Otomatik süreç takibi ve güncelleme
- Geri alma / ileri alma (undo-redo)
- Kullanımı kolay, modern ve sade arayüz
- Flutter ile yazılmıştır

### 🛠 Komut Formatı
- `modelKod + sayı + kategoriKodu`
  - Ör: `zü15d` = Zürafa modelinden 15 adet döküldü
  - `zü1xb` = Zürafa modelinden 1 adet boyanan ürün çöp oldu

### 📱 Kurulum
```bash
flutter pub get
flutter run
