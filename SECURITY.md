# Güvenlik Politikası

Bu dosya, FridgeMini projesindeki güvenlik açıklarının nasıl bildirileceğini açıklar.

## 🚨 Güvenlik Açığı Bildirme

Bir güvenlik açığı keşfettiyseniz lütfen **genel hata takipçisini (Issues) KULLANMAYIN**.
Bunun yerine doğrudan proje sahibi ile iletişime geçin:

- E-posta: [selinnyuksell5@gmail.com](mailto:selinnyuksell5@gmail.com)
- GitHub: [@selinnyuksell5](https://github.com/selinnyuksell5)

### Bildiriminizde Bulunması Gerekenler

- Açıklığın kısa bir özeti ve etkisi
- Tekrarlama adımları (POC kodu varsa)
- Etkilenen sürüm(ler)
- Bilinen geçici çözümler (varsa)
- Ortam bilgileri (OS, Flutter versiyonu vb.)

## ⏳ Yanıt Süresi

- **24 saat içinde** alındığına dair onay
- **7 gün içinde** ilk değerlendirme ve durum güncellemesi
- **30 gün içinde** (ciddi durumlarda daha hızlı) düzeltme ve yayın

## 🎯 Desteklenen Sürümler

Şu anda sadece en son yayınlanan kararlı sürüm güvenlik güncelleştirmeleri almaktadır:

| Sürüm | Durum |
| ------- | ------------------ |
| 1.0.x | ✅ Destekleniyor |
| < 1.0 | ❌ Desteklenmiyor |

## 🔐 Güvenlik Önerileri (Kullanıcılar İçin)

1. **API Anahtarları**: Gemini API anahtarınızı kod içine gömmeyin, production ortamında
   `--dart-define` veya secure storage kullanın:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=anahtariniz
   ```

2. **Firebase Güvenlik Kuralları**: Firestore ve Storage için güvenlik kurallarını
   varsayılan test modundan çıkarıp kullanıcı bazlı kısıtlamalar yapın:
   ```firestore
   match /users/{userId} {
     allow read, write: if request.auth.uid == userId;
   }
   ```

3. **Kullanıcı Verileri**: Alerji bilgileri gibi hassas verileri sadece kullanıcının
   erişebildiği belgelerde saklayın.

4. **Uygulama Güncellemeleri**: Yayınlanan güncellemeleri takip edin, güvenlik yamalarını
   kaçırmayın.

## 🛡️ Güvenlik Katmanları

Uygulama içinde mevcut güvenlik önlemleri:

- ✅ Firebase Auth ile kimlik doğrulama
- ✅ JSON parsing sırasında tip güvenliği ve hata yönetimi
- ✅ Hassas API yanıtlarının loglanmaması (sadece sınırlı debug)
- ✅ Kullanıcı girdisi doğrulama (form_validator)
- ✅ Gradle & Xcode için varsayılan güvenlik ayarları

## 📜 Güvenlik Açığı Düzeltme Süreci

1. Açık raporlanır → gizli kanalla onaylanır
2. Etki alanı ve şiddeti değerlendirilir
3. Bir düzeltme hazırlanır ve test edilir
4. Düzeltme yayınlanır (yeni sürüm)
5. Açıklık hakkında kamuoyu bilgilendirmesi (gizlilik süresi sonrası)

Saygılarımızla,
FridgeMini Güvenlik Ekibi
