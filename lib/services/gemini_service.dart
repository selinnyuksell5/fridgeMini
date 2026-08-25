import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as path;
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(
    model: AppConstants.geminiModelName,
    apiKey: AppConstants.geminiApiKey,
    generationConfig: GenerationConfig(
      temperature: 0.4,
      topP: 1,
      topK: 32,
      maxOutputTokens: 4096,
    ),
  );

  // Buzdolabı görüntüsünü analiz edip malzemeleri çıkarır
  Future<List<Ingredient>> analyzeFridgeImage(File image) async {
    try {
      // Resmi byte array olarak oku
      final bytes = await image.readAsBytes();

      // Dosya uzantısından MIME type'ı belirle
      String mimeType = 'image/jpeg';
      final extension = path.extension(image.path).toLowerCase();
      if (extension == '.png') {
        mimeType = 'image/png';
      } else if (extension == '.jpg' || extension == '.jpeg') {
        mimeType = 'image/jpeg';
      }

      debugPrint('Image size: ${bytes.length} bytes, MIME: $mimeType');

      final prompt = '''
Lütfen bu buzdolabı görselindeki tüm yiyecek ve içecekleri analiz et.
SADECE net bir şekilde gördüğün ve emin olduğun ürünleri listele.

Her ürün için JSON formatında şu bilgileri ver:
- "name": Ürünün Türkçe ismi (küçük harflerle)
- "amount": Tahmini miktar (sayı olarak)
- "unit": Birim (örn: "adet", "kg", "litre", "paket")

SADECE JSON array formatında yanıt ver, başka açıklama yazma.

Örnek format:
[
  {"name": "domates", "amount": 3, "unit": "adet"},
  {"name": "süt", "amount": 1, "unit": "litre"}
]
''';

      // İçerik oluştur
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, bytes),
        ]),
      ];

      debugPrint('Sending request to Gemini API...');

      // API'ye istek gönder
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('API boş yanıt döndü');
      }

      debugPrint('API Response received: ${response.text!.substring(0, response.text!.length > 100 ? 100 : response.text!.length)}...');

      // Yanıtı işle
      final ingredients = _extractIngredientsFromResponse(response.text!);

      if (ingredients.isEmpty) {
        throw Exception('Görselde malzeme tespit edilemedi. Lütfen daha net bir fotoğraf çekin.');
      }

      return ingredients;

    } catch (e) {
      debugPrint('Image analysis error: $e');
      if (e.toString().contains('API key')) {
        throw Exception('API anahtarı geçersiz. Lütfen ayarları kontrol edin.');
      } else if (e.toString().contains('quota')) {
        throw Exception('API kullanım limitine ulaşıldı. Lütfen daha sonra tekrar deneyin.');
      } else if (e.toString().contains('429')) {
        throw Exception('Çok fazla istek gönderildi. Lütfen birkaç saniye bekleyin.');
      }
      throw Exception('Görsel analiz edilirken hata oluştu: $e');
    }
  }

  List<Ingredient> _extractIngredientsFromResponse(String response) {
    try {
      // JSON'u temizle
      String jsonStr = response.trim();

      // Markdown kod bloklarını temizle
      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
      }

      // JSON array'i bul
      if (!jsonStr.startsWith('[')) {
        final startIndex = jsonStr.indexOf('[');
        if (startIndex != -1) {
          jsonStr = jsonStr.substring(startIndex);
        }
      }

      if (!jsonStr.endsWith(']')) {
        final endIndex = jsonStr.lastIndexOf(']');
        if (endIndex != -1) {
          jsonStr = jsonStr.substring(0, endIndex + 1);
        }
      }

      debugPrint('Cleaned JSON: $jsonStr');

      // String içindeki ham satır sonlarını kaçışlı hale getir
      jsonStr = _escapeNewlinesInsideStrings(jsonStr);

      // JSON'u parse et
      final List<dynamic> jsonList = jsonDecode(jsonStr);

      if (jsonList.isEmpty) {
        throw Exception('Malzeme listesi boş');
      }

      // Ingredient listesine dönüştür
      final ingredients = <Ingredient>[];

      for (var item in jsonList) {
        try {
          if (item is! Map<String, dynamic>) continue;

          final name = (item['name'] as String?)?.trim().toLowerCase();
          if (name == null || name.isEmpty) continue;

          final amount = item['amount'];
          final unit = (item['unit'] as String?)?.trim().toLowerCase();

          ingredients.add(Ingredient(
            name: name,
            amount: amount is num ? amount.toDouble() : null,
            unit: unit,
            isAvailable: true,
          ));
        } catch (e) {
          debugPrint('Error parsing ingredient: $e');
          continue;
        }
      }

      debugPrint('Successfully parsed ${ingredients.length} ingredients');
      return ingredients;

    } catch (e) {
      debugPrint('Error extracting ingredients: $e');
      throw Exception('Malzemeler işlenirken hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  // Malzemelerden tarif önerileri oluşturur
  Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients, {List<String> allergies = const []}) async {
    try {
      final ingredientNames = ingredients
          .map((i) => i.name.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      if (ingredientNames.isEmpty) {
        throw Exception('Tarif oluşturmak için malzeme bulunamadı');
      }

      debugPrint('Generating recipes for: ${ingredientNames.join(", ")}');
      if (allergies.isNotEmpty) {
        debugPrint('Alerji nedeniyle hariç tutulanlar: ${allergies.join(", ")}');
      }

      final prompt = '''
Aşağıdaki malzemeleri kullanarak 3 veya 4 farklı, pratik ve lezzetli Türk mutfağı tarifi öner:
${ingredientNames.join(', ')}

${allergies.isNotEmpty ? 'DİKKAT: Aşağıdaki alerjenleri İÇERMEYEN tarifler öner: ${allergies.join(', ')}. Bu malzemeleri içeren hiçbir tarif önerme.\n' : ''}
Her tarif için SADECE şu JSON formatında yanıt ver (alanlar zorunlu):

[
  {
    "title": "Tarifin başlığı",
    "description": "Kısa açıklama (1-2 cümle)",
    "ingredients": [
      {"name": "malzeme", "amount": 2, "unit": "adet"}
    ],
    "instructions": [
      "Adım 1 açıklaması",
      "Adım 2 açıklaması"
    ],
    "prepTime": 15,
    "cookTime": 20,
    "servings": 2,
    "cuisine": "Türk",
    "difficulty": "Kolay"
  }
]

KURALLAR:
- Geçerli JSON (RFC 8259) üret. Kod bloğu veya ek açıklama yazma.
- Sadece çift tırnak kullan. Son elemandan sonra virgül bırakma. Kaçışsız yeni satır yerine \\n kullan.
- "prepTime" ve "cookTime" alanları dakika cinsinden TAM SAYI olmalı.
- SADECE JSON array döndür; array uzunluğu 3 veya 4 olmalı.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('API boş yanıt döndü');
      }

      debugPrint('Recipe API response received');

      // JSON'u temizle ve parse et (daha sağlam)
      String cleanedResponse = response.text!.trim();

      // Kod bloklarını temizle
      if (cleanedResponse.contains('```json')) {
        cleanedResponse = cleanedResponse.split('```json')[1].split('```')[0].trim();
      } else if (cleanedResponse.contains('```')) {
        cleanedResponse = cleanedResponse.split('```')[1].split('```')[0].trim();
      }

      // İlk '[' ve son ']' arasını al (ön/arka metni at)
      if (!cleanedResponse.startsWith('[')) {
        final startIndex = cleanedResponse.indexOf('[');
        if (startIndex != -1) {
          cleanedResponse = cleanedResponse.substring(startIndex);
        }
      }
      if (!cleanedResponse.endsWith(']')) {
        final endIndex = cleanedResponse.lastIndexOf(']');
        if (endIndex != -1) {
          cleanedResponse = cleanedResponse.substring(0, endIndex + 1);
        }
      }

      // Problemli unicode tırnakları düzelt
      cleanedResponse = cleanedResponse
          .replaceAll('\u201c', '"')
          .replaceAll('\u201d', '"')
          .replaceAll('“', '"')
          .replaceAll('”', '"')
          .replaceAll('\u2019', "'")
          .replaceAll('’', "'");

      // Kapanışlardan önceki son virgülleri kaldır
      cleanedResponse = cleanedResponse
          .replaceAll(RegExp(r",\s*\]"), "]")
          .replaceAll(RegExp(r",\s*\}"), "}");

      debugPrint('Cleaned response: ${cleanedResponse.substring(0, cleanedResponse.length > 200 ? 200 : cleanedResponse.length)}...');

      // String içindeki ham satır sonlarını kaçışlı hale getir
      cleanedResponse = _escapeNewlinesInsideStrings(cleanedResponse);

      final List<dynamic> recipesList = _safeJsonDecodeArray(cleanedResponse);

      if (recipesList.isEmpty) {
        throw Exception('Tarif bulunamadı');
      }

      final recipes = recipesList.map<Recipe>((json) {
        try {
          return Recipe.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing recipe: $e');
          return Recipe(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Hatalı Tarif',
            description: 'Bu tarif yüklenirken bir hata oluştu.',
            ingredients: [],
            instructions: [],
          );
        }
      }).toList();

      debugPrint('Successfully generated ${recipes.length} recipes');
      return recipes;

    } catch (e) {
      debugPrint('Recipe generation error: $e');
      throw Exception('Tarifler oluşturulurken hata: $e');
    }
  }
}

/// JSON metni içinde çift tırnaklı stringlerde bulunan ham \r/\n karakterlerini
/// geçerli `\n` kaçış sekansına dönüştürür.
String _escapeNewlinesInsideStrings(String input) {
  final buffer = StringBuffer();
  bool inString = false;
  bool lastWasEscape = false;

  for (int i = 0; i < input.length; i++) {
    final ch = input[i];

    if (ch == '"' && !lastWasEscape) {
      inString = !inString;
      buffer.write(ch);
      lastWasEscape = false;
      continue;
    }

    if (inString) {
      if (ch == '\r') {
        // CRLF -> tek bir \n olarak yaz
        if (i + 1 < input.length && input[i + 1] == '\n') {
          buffer.write('\\n');
          i++; // LF'i tüket
        } else {
          buffer.write('\\n');
        }
        lastWasEscape = false;
        continue;
      }
      if (ch == '\n') {
        buffer.write('\\n');
        lastWasEscape = false;
        continue;
      }
    }

    buffer.write(ch);

    if (ch == '\\') {
      // Ardı ardına gelen ters eğik çizgiler için toggle mantık
      lastWasEscape = !lastWasEscape;
    } else {
      lastWasEscape = false;
    }
  }

  return buffer.toString();
}

/// Gelen metindeki olası JSON format bozukluklarını daha toleranslı biçimde ele alır.
/// Başarılı olursa bir JSON array döndürür; değilse boş liste.
List<dynamic> _safeJsonDecodeArray(String input) {
  // İlk deneme: direkt decode
  try {
    final dynamic data = jsonDecode(input);
    if (data is List) return data;
    if (data is Map) {
      final candidates = [
        'recipes',
        'items',
        'data',
        'tarifler',
        'results',
        'list',
      ];
      for (final key in candidates) {
        final v = data[key];
        if (v is List) return v;
      }
      return [data];
    }
  } catch (_) {
    // Devam edip onarım deneyeceğiz
  }

  // Basit onarım: kapatma parantezlerini dengele
  String s = input;
  final opensBrace = RegExp(r"\{").allMatches(s).length;
  final closesBrace = RegExp(r"\}").allMatches(s).length;
  final opensBracket = RegExp(r"\[").allMatches(s).length;
  final closesBracket = RegExp(r"\]").allMatches(s).length;

  final missingBraces = opensBrace - closesBrace;
  final missingBrackets = opensBracket - closesBracket;
  if (missingBraces > 0) {
    s = s + ("}" * missingBraces);
  }
  if (missingBrackets > 0) {
    s = s + ("]" * missingBrackets);
  }

  try {
    final dynamic data2 = jsonDecode(s);
    if (data2 is List) return data2;
    if (data2 is Map) {
      final candidates = [
        'recipes',
        'items',
        'data',
        'tarifler',
        'results',
        'list',
      ];
      for (final key in candidates) {
        final v = data2[key];
        if (v is List) return v;
      }
      return [data2];
    }
  } catch (_) {
    // Son deneme: üst düzey obje yakalama
  }

  // Üst düzey obje çıkarıcı: metindeki { ... } bloklarını tek tek parse et (array olsun/olmasın)
  final results = <dynamic>[];
  bool inString = false;
  bool escape = false;
  int objectDepth = 0;
  int startIdx = -1;

  for (int i = 0; i < s.length; i++) {
    final ch = s[i];

    if (!escape && ch == '"') {
      inString = !inString;
    }

    if (!inString) {
      if (ch == '\\') {
        escape = !escape;
      } else {
        escape = false;
      }

      if (ch == '{') {
        if (objectDepth == 0) startIdx = i;
        objectDepth++;
      }
      if (ch == '}') {
        if (objectDepth > 0) {
          objectDepth--;
          if (objectDepth == 0 && startIdx >= 0) {
            final objStr = s.substring(startIdx, i + 1);
            try {
              final obj = jsonDecode(objStr);
              results.add(obj);
            } catch (_) {
              // yut
            }
            startIdx = -1;
          }
        }
      }
    } else {
      // String içinde ise kaçış durumunu sadece \ takibiyle güncelle
      if (ch == '\\') {
        escape = !escape;
      } else {
        escape = false;
      }
    }
  }

  if (results.length == 1 && results.first is Map<String, dynamic>) {
    final m = results.first as Map<String, dynamic>;
    final candidates = [
      'recipes',
      'items',
      'data',
      'tarifler',
      'results',
      'list',
    ];
    for (final key in candidates) {
      final v = m[key];
      if (v is List) return v;
    }
  }

  return results;
}
