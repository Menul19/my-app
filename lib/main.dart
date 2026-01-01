import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: TranslatorApp(), debugShowCheckedModeBanner: false));
}

class TranslatorApp extends StatefulWidget {
  const TranslatorApp({super.key});
  @override
  State<TranslatorApp> createState() => _TranslatorAppState();
}

class _TranslatorAppState extends State<TranslatorApp> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String _text = "Speak...";
  String _translated = "Translation...";

  final _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.sinhala,
    targetLanguage: TranslateLanguage.english,
  );

  void _listen() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (val) async {
        setState(() => _text = val.recognizedWords);
        if (val.finalResult) {
          final res = await _translator.translateText(_text);
          setState(() => _translated = res);
          await _tts.speak(res);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Translator")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_text, style: const TextStyle(fontSize: 18)),
            const Icon(Icons.arrow_downward),
            Text(_translated, style: const TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: _listen, child: const Text("Mic On")),
          ],
        ),
      ),
    );
  }
}

