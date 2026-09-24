import 'package:translator/translator.dart';

class TranslatedArtPieceContent {
  const TranslatedArtPieceContent({
    required this.title,
    required this.description,
    required this.content,
  });

  final String title;
  final String description;
  final String content;
}

class TranslationService {
  TranslationService({GoogleTranslator? translator})
      : _translator = translator ?? GoogleTranslator();

  final GoogleTranslator _translator;

  Future<String> translate(String value, String targetLanguage) async {
    if (value.trim().isEmpty) return value;
    final result = await _translator.translate(
      value,
      from: 'auto',
      to: targetLanguage,
    );
    return result.text;
  }

  Future<TranslatedArtPieceContent> translatePiece({
    required String title,
    required String description,
    required String content,
    required String targetLanguage,
  }) async {
    final values = await Future.wait([
      translate(title, targetLanguage),
      translate(description, targetLanguage),
      translate(content, targetLanguage),
    ]);
    return TranslatedArtPieceContent(
      title: values[0],
      description: values[1],
      content: values[2],
    );
  }
}
