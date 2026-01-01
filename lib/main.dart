import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String _sourceText = "ඔබට අවශ්‍ය දේ පවසන්න...";
  String _translatedText = "Translation will appear here";
  bool _isListening = false;

  final _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.sinhala,
    targetLanguage: TranslateLanguage.english,
  );

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  void _requestPermission() async {
    await Permission.microphone.request();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) async {
          setState(() => _sourceText = val.recognizedWords);
          if (val.finalResult) {
            _translate();
            setState(() => _isListening = false);
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _translate() async {
    final result = await _translator.translateText(_sourceText);
    setState(() => _translatedText = result);
    await _tts.speak(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Traveler Assistant", style: GoogleFonts.poppins()),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            FadeInDown(child: _buildCard("සිංහල", _sourceText)),
            const SizedBox(height: 20),
            const Icon(Icons.arrow_downward, size: 40, color: Colors.orange),
            const SizedBox(height: 20),
            FadeInUp(child: _buildCard("English", _translatedText)),
            const Spacer(),
            FloatingActionButton.large(
              onPressed: _listen,
              backgroundColor: _isListening ? Colors.red : Colors.orange,
              child: Icon(_isListening ? Icons.stop : Icons.mic, size: 40),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String lang, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 10),
          Text(text, style: GoogleFonts.notoSansSinhala(fontSize: 18)),
        ],
      ),
    );
  }
}

