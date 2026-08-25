# 🍳 FridgeMini - Akıllı Tarif Asistanı

> Buzdolabındaki malzemelerini fotoğrafla, yapay zeka sana özel tarifler önersin!

FridgeMini, Google Gemini yapay zekasını kullanarak buzdolabınızın fotoğrafını analiz eden, içindeki malzemeleri tespit eden ve bu malzemelere göre Türk mutfağı tarifleri öneren akıllı bir Flutter uygulamasıdır.

## ✨ Özellikler

| Özellik | Açıklama |
|---------|----------|
| 📸 **Görüntü Analizi** | Buzdolabı fotoğrafını çeker ve malzemeleri yapay zeka ile tespit eder |
| 🍽️ **Tarif Önerisi** | Tespit edilen malzemelere göre 3-4 arası pratik Türk tarifi sunar |
| 🛡️ **Alerji Desteği** | Kullanıcının alerjilerine göre tarifleri filtreler |
| ⭐ **Favori Tarifler** | Beğendiğiniz tarifleri favorilere ekleyin, dilediğiniz zaman ulaşın |
| 🔐 **Kullanıcı Hesabı** | Firebase Authentication ile güvenli giriş/üye olma |
| ☁️ **Cloud Sync** | Favorileriniz ve bilgileriniz Firestore'da güvenle saklanır |
| 🌙 **Karanlık Mod** | Göz yorgunluğu için açık/koyu tema desteği |
| 📱 **Çok Platformlu** | Android, iOS, Web, Windows, macOS ve Linux desteği |

## 🛠️ Teknoloji Yığını

### Ön Yüz (Frontend)
- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.9+** - Null safety ile modern dil
- **Provider** - State management
- **flutter_screenutil** - Responsive tasarım
- **flutter_animate** - Animasyonlar
- **cached_network_image** - Resim önbellekleme
- **image_picker** - Kamera & galeri erişimi

### Arka Plan & Yapay Zeka
- **Google Gemini AI (gemini-2.5-flash)** - Görüntü analizi & tarif üretimi
- **google_generative_ai** - Gemini API SDK'sı

### Backend & Veritabanı
- **Firebase Core** - Firebase başlatma
- **Firebase Auth** - Email/şifre ile kimlik doğrulama
- **Cloud Firestore** - NoSQL veritabanı (kullanıcı, favori, alerji)

## 📂 Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── firebase_options.dart     # Firebase konfigürasyonu
├── models/                   # Veri modelleri
│   ├── ingredient.dart       # Malzeme modeli
│   ├── recipe.dart           # Tarif modeli
│   └── user_model.dart       # Kullanıcı modeli
├── screens/                  # Ekranlar
│   ├── auth/
│   │   ├── signin_screen.dart
│   │   └── signup_screen.dart
│   ├── home_screen.dart      # Ana ekran (fotoğraf + analiz)
│   └── profile_screen.dart   # Profil & ayarlar
├── services/                 # Servisler
│   ├── auth_service.dart     # Firebase Auth servisi
│   └── gemini_service.dart   # Gemini AI servisi
├── theme/
│   └── app_theme.dart        # Açık & koyu tema
└── utils/
    └── constants.dart        # Sabitler (API anahtarı, tema vb.)
```

## 🚀 Kurulum & Çalıştırma

### 1. Gerekli Yazılımlar
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.9+)
- [Dart SDK](https://dart.dev/get-dart) (Flutter ile birlikte gelir)
- Android Studio / VS Code (önerilen IDE)
- Bir cihaz veya emülatör

### 2. Depoyu Klonla
```bash
git clone https://github.com/selinnyuksell5/fridgeMini.git
cd fridgeMini
```

### 3. Bağımlılıkları Yükle
```bash
flutter pub get
```

### 4. Firebase Kurulumu
1. [Firebase Console](https://console.firebase.google.com/) üzerinden yeni proje oluştur
2. Uygulamayı Firebase'e bağla (flutterfire_cli önerilir):
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Aşağıdaki ürünleri aktif et:
   - **Authentication** → Email/Password sağlayıcısını aç
   - **Firestore Database** → Test modunda oluştur

### 5. API Anahtarını Yapılandır
`lib/utils/constants.dart` dosyasında Gemini API anahtarını güncelle:
```dart
static const String geminiApiKey = 'SENIN_GEMINI_API_ANAHTARIN';
```
> API anahtarını [Google AI Studio](https://aistudio.google.com/apikey) üzerinden alabilirsin.

### 6. Uygulamayı Çalıştır
```bash
flutter run
```

## 📸 Nasıl Kullanılır?

1. **Uygulamayı aç** ve hesap oluştur / giriş yap
2. **"Kamera ile Fotoğraf Çek"** butonuna tıkla
3. Buzdolabının içinin net bir fotoğrafını çek
4. Yapay zeka malzemeleri analiz etsin ⏳
5. Önerilen tariflerden birini seç, adım adım pişir!
6. Beğendiğin tarifi ⭐ **favorilere ekle**

## 🧪 Örnek Akış

```
Kullanıcı fotoğraf çeker
    ↓
GeminiService.analyzeFridgeImage() görüntüyü işler
    ↓
JSON formatında malzemeler döner (domates, biber, yumurta...)
    ↓
GeminiService.generateRecipes() ile tarifler üretilir
    ↓
Alerji filtresi uygulanır
    ↓
Tarif kartları olarak ekranda gösterilir 🎉
```

## 🔒 Güvenlik Notları

- API anahtarlarını doğrudan koda gömmeyin; production'da environment variable veya secure storage kullanın
- Firestore güvenlik kurallarını yapılandırmayı unutmayın:
  ```firestore
  match /users/{userId} {
    allow read, write: if request.auth.uid == userId;
  }
  ```
- Alerji yönetimi hassas veridir, sadece kullanıcı kendi verisine erişebilmeli

## 🛤️ Geliştirme Yolu (Roadmap)

- [ ] Malzeme envanteri takibi & son kullanma tarihi uyarıları
- [ ] Alışveriş listesi oluşturma
- [ ] Beslenme bilgisi ve kalori takibi
- [ ] Sosyal özellikler (tarif paylaşımı)
- [ ] Offline mod desteği
- [ ] Sesli tarif okuma
- [ ] Çoklu dil desteği (İngilizce vb.)

## 🐛 Hata Bildirimi

Bir sorunla karşılaşırsanız [Issues](https://github.com/selinnyuksell5/fridgeMini/issues) bölümünden bildirebilirsiniz.

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

<div align="center">
  <strong>Yemek keyfini çıkarın! 🍽️</strong>
</div>
