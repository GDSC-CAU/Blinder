import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts ttsController = FlutterTts();

Future<void> initTts() async {
  await ttsController.awaitSpeakCompletion(true);
  await ttsController.setSpeechRate(1.0);
  await ttsController.setLanguage('ko');
}

Future speak(String word) async {
  await ttsController.speak(word);
}
