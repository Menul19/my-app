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
  String _translatedText = "පරිවර්තනය මෙහි දිස්වේවි";
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
          setState(() {
            _sourceText = val.recognizedWords;
          });
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
    await _tts.speak(result); // පරිවර්තනය කළ දේ ශබ්ද නගා කියවයි
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Traveler Assistant AI", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            FadeInDown(child: _buildTextBox("සිංහල (Sinhala)", _sourceText, Colors.orange.shade100)),
            const SizedBox(height: 20),
            const Icon(Icons.swap_vert, size: 40, color: Colors.orangeAccent),
            const SizedBox(height: 20),
            FadeInUp(child: _buildTextBox("English (US)", _translatedText, Colors.blue.shade100)),
            const Spacer(),
            _buildMicButton(),
            const SizedBox(height: 20),
            Text(_isListening ? "මම අසා සිටිමි..." : "මයික්‍රොෆෝනය ඔබා කතා කරන්න", 
              style: GoogleFonts.notoSansSinhala(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBox(String label, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 10),
          Text(text, style: GoogleFonts.notoSansSinhala(fontSize: 18, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _listen,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isListening ? Colors.redAccent : Colors.orangeAccent,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
        ),
        child: Icon(_isListening ? Icons.stop : Icons.mic, size: 50, color: Colors.white),
      ),
    );
  }
}

