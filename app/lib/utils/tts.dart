import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts tts = FlutterTts();

Future<void> initTts() async {
  await tts.awaitSpeakCompletion(true);
  await tts.setSpeechRate(0.8);
  await tts.setLanguage('ko');
}

Future<void> speak(String word) async {
  await tts.speak(word);
}
