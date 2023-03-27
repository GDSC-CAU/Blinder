import 'package:flutter_tts/flutter_tts.dart';

enum TtsSpeakState {
  playing,
  stopped,
  paused,
  continued,
}

class Tts {
  static Tts? _instance;

  /// MIN: 0.3 | MIDDLE: 0.6 | MAX: 0.9
  static const defaultSpeechVolume = 0.6;
  static const defaultSpeechVolumeStep = 3;

  /// MIN: 0.6 | MIDDLE: 0.8 | MAX: 1.0
  static const defaultSpeechRate = 0.8;
  static const defaultSpeechRateStep = 2;

  final FlutterTts controller = FlutterTts();

  double speechRate = defaultSpeechRate;
  double speechVolume = defaultSpeechVolume;

  TtsSpeakState state = TtsSpeakState.stopped;

  factory Tts() => _instance ??= Tts._createSingleInstance();

  Tts._createSingleInstance() {
    if (_isValidOption(speechRate) == false ||
        _isValidOption(speechVolume) == false) {
      throw Exception(
        "volume: $speechVolume and speechRate: $speechRate should be between 0 and 1",
      );
    }
    _setTTSHandler();
  }

  bool _isValidOption(double optionValue) {
    if (optionValue > 1 || optionValue < 0) return false;
    return true;
  }

  Future<void> setupConfig({
    required bool waitForSpeakingCompletion,
    required String language,
    bool? useDefaultEngine,
  }) async {
    try {
      if (await controller.isLanguageAvailable(language) == false) {
        final supportedLanguageList =
            await controller.getLanguages as List<String>;
        throw Exception(
            "TTS error: there is no option for language: $language.\nSupported language is these: $supportedLanguageList");
      }

      if (waitForSpeakingCompletion) {
        await controller.awaitSpeakCompletion(true);
      }
      if (useDefaultEngine == true) {
        final defaultEngine = await controller.getDefaultEngine;
        await controller.setEngine(defaultEngine as String);
      }

      await controller.setLanguage(language);
    } catch (e) {
      throw Exception(
        "Error is occurred, when initializing tts class\nError: $e",
      );
    }
  }

  /// `step`: if step is `0.2`, then input should be `2`
  double _getCorrectUpdatedDouble({
    required double targetDouble,
    required int step,
  }) {
    final result = int.parse("${targetDouble * 10}");
    final updated = result + step;
    return updated.toDouble() / 10;
  }

  void _setTTSHandler() {
    controller.setCompletionHandler(() {
      print("Success Speaking");
      state = TtsSpeakState.stopped;
    });
    controller.setCancelHandler(() {
      print("Canceled Speaking");
      state = TtsSpeakState.stopped;
    });
    controller.setErrorHandler((message) {
      print("Error Speaking: $message");
      state = TtsSpeakState.stopped;
    });

    controller.setStartHandler(() {
      print("Start Speaking");
      state = TtsSpeakState.playing;
    });

    controller.setPauseHandler(() {
      state = TtsSpeakState.paused;
    });

    controller.setContinueHandler(() {
      state = TtsSpeakState.continued;
    });
  }

  Future<void> _updateSpeechRate(double newSpeechRate) async {
    speechRate = newSpeechRate;
    await controller.setSpeechRate(newSpeechRate);
  }

  String _getSpeechRateText() {
    const baseText = '말하기 속도,';
    if (speechRate == 1.0) {
      return "$baseText 빠르게";
    } else if (speechRate == 0.8) {
      return "$baseText 보통";
    } else if (speechRate == 0.6) {
      return "$baseText 천천히";
    } else {
      throw Exception("SpeechRate Range Exceeded!");
    }
  }

  Future<void> increaseSpeechRate() async {
    final increasedRate = _getCorrectUpdatedDouble(
      targetDouble: speechRate,
      step: defaultSpeechRateStep,
    );
    if (increasedRate >= 1) {
      await speak("최대 말하기 속도입니다.");
      return;
    }
    await _updateSpeechRate(increasedRate);
    await speak(_getSpeechRateText());
  }

  Future<void> decreaseSpeechRate() async {
    final decreasedRate = _getCorrectUpdatedDouble(
      targetDouble: speechRate,
      step: -defaultSpeechRateStep,
    );
    if (decreasedRate <= 0.5) {
      await speak("최소 말하기 속도입니다.");
      return;
    }

    await _updateSpeechRate(decreasedRate);
    await speak(_getSpeechRateText());
  }

  Future<void> _updateSpeechVolume(double newVolume) async {
    speechVolume = newVolume;
    await controller.setVolume(newVolume);
  }

  String _getSpeechVolumeText() {
    const baseText = '음성 출력,';
    if (speechVolume == 0.9) {
      return "$baseText 크게";
    } else if (speechVolume == 0.6) {
      return "$baseText 보통";
    } else if (speechVolume == 0.3) {
      return "$baseText 작게";
    } else {
      throw Exception("SpeechVolume Range Exceeded!");
    }
  }

  Future<void> increaseSpeechVolume() async {
    final increasedVolume = speechVolume + defaultSpeechVolumeStep;
    print("증가: $increasedVolume");

    if (increasedVolume >= 1.1) {
      await speak("최대 소리 크기입니다.");
      return;
    }
    await _updateSpeechVolume(increasedVolume);
    await speak(_getSpeechVolumeText());
  }

  Future<void> decreaseSpeechVolume() async {
    final decreasedVolume = speechVolume - defaultSpeechVolumeStep;
    print("감소: $decreasedVolume");

    if (decreasedVolume <= 0.2) {
      await speak("최소 소리 크기입니다.");
      return;
    }
    await _updateSpeechVolume(decreasedVolume);
    await speak(_getSpeechVolumeText());
  }

  Future<void> speak(String word) async {
    await controller.speak(word);
  }
}

late final Tts tts;

Future<void> initializeTtsInstance({
  required bool waitForSpeakingCompletion,
  required String language,
  double? speechVolume,
  double? speechRate,
  bool? useDefaultEngine,
}) async {
  tts = Tts();
  await tts.setupConfig(
    waitForSpeakingCompletion: waitForSpeakingCompletion,
    language: language,
    useDefaultEngine: useDefaultEngine,
  );
  await tts.controller.setSpeechRate(Tts.defaultSpeechRate);
  await tts.controller.setVolume(Tts.defaultSpeechVolume);
}
