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
  String _text = "මයික්‍රොෆෝනය ඔබා කතා කරන්න...";
  String _translated = "පරිවර්තනය මෙහි දිස්වේවි";

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
      appBar: AppBar(title: const Text("Traveler Assistant")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(_text, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
            ),
            const Icon(Icons.translate, size: 50, color: Colors.blue),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(_translated, style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 50),
            FloatingActionButton.large(onPressed: _listen, child: const Icon(Icons.mic)),
          ],
        ),
      ),
    );
  }
}

