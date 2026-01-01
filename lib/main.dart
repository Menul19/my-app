import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(TranslatorApp());

class TranslatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  TextEditingController _controller = TextEditingController();
  String translatedText = "පරිවර්තනය මෙතන දිස්වේවි...";

  // සරලව API එකක් හරහා පරිවර්තනය කරන ආකාරය (Example using a free API)
  Future<void> translateText(String text) async {
    // සටහන: මෙහිදී MyMemory වැනි නොමිලේ ලබාදෙන API එකක් භාවිතා කර ඇත
    final response = await http.get(Uri.parse(
        'https://api.mymemory.translated.net/get?q=$text&langpair=si|en'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        translatedText = data['responseData']['translatedText'];
      });
    } else {
      setState(() {
        translatedText = "Error: සම්බන්ධතාවය පරීක්ෂා කරන්න.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_appBar: AppBar(title: Text("සංචාරක සහායකයා (Translator)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "සිංහලෙන් ලියන්න...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => translateText(_controller.text),
              child: Text("පරිවර්තනය කරන්න (Translate)"),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              color: Colors.grey[200],
              child: Text(
                translatedText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

