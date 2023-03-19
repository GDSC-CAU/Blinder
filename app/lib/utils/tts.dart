import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts ttsController = FlutterTts();

Future<void> initTts() async {
  await ttsController.setSpeechRate(0.8);
  await ttsController.setLanguage('ko');
}

Future<void> speak(String word) async {
  await ttsController.speak(word);
}
