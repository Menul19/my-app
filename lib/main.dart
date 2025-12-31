import 'package:flutter/material.dart';
import 'dart:async';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const ScientificCalcApp());

class ScientificCalcApp extends StatefulWidget {
  const ScientificCalcApp({super.key});

  @override
  State<ScientificCalcApp> createState() => _ScientificCalcAppState();
}

class _ScientificCalcAppState extends State<ScientificCalcApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme(bool isDark) {
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menul Calculator',
      themeMode: _themeMode,
      theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue),
      darkTheme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF17171C)),
      home: const SplashScreen(),
    );
  }
}

// --- Splash Screen ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CalculatorHome(onThemeChanged: (val) {})));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17171C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text("Menul Calculator", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- Main Calculator Logic ---
class CalculatorHome extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const CalculatorHome({super.key, required this.onThemeChanged});
  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String equation = "0";
  String result = "0";

  void onBtnClick(String text) {
    setState(() {
      if (text == "AC") {
        equation = "0";
        result = "0";
      } else if (text == "⌫") {
        equation = equation.length > 1 ? equation.substring(0, equation.length - 1) : "0";
      } else if (text == "=") {
        String finalExp = equation;
        finalExp = finalExp.replaceAll('÷', '/').replaceAll('×', '*');

        try {
          Parser p = Parser();
          Expression exp = p.parse(finalExp);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 4);
        } catch (e) {
          result = "Error";
        }
      } else {
        equation = equation == "0" ? text : equation + text;
      }
    });
  }

  Widget calcBtn(String txt, Color col, {Color txtCol = Colors.white}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: col,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () => onBtnClick(txt),
          child: Text(txt, style: TextStyle(fontSize: 18, color: txtCol, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menul Calculator"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SettingsPage(isDark: isDark, onThemeChanged: widget.onThemeChanged))))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(equation, style: TextStyle(fontSize: 26, color: isDark ? Colors.grey : Colors.black54)),
                  const SizedBox(height: 10),
                  Text(result, style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Divider(),
          _buildKeys(isDark),
        ],
      ),
    );
  }

  Widget _buildKeys(bool isDark) {
    Color numBg = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    Color txtCol = isDark ? Colors.white : Colors.black;
    return Column(
      children: [
        Row(children: [calcBtn("sin(", Colors.blue), calcBtn("cos(", Colors.blue), calcBtn("tan(", Colors.blue), calcBtn("sqrt(", Colors.blue)]),
        Row(children: [calcBtn("AC", Colors.redAccent), calcBtn("(", Colors.grey), calcBtn(")", Colors.grey), calcBtn("÷", Colors.orange)]),
        Row(children: [calcBtn("7", numBg, txtCol: txtCol), calcBtn("8", numBg, txtCol: txtCol), calcBtn("9", numBg, txtCol: txtCol), calcBtn("×", Colors.orange)]),
        Row(children: [calcBtn("4", numBg, txtCol: txtCol), calcBtn("5", numBg, txtCol: txtCol), calcBtn("6", numBg, txtCol: txtCol), calcBtn("-", Colors.orange)]),
        Row(children: [calcBtn("1", numBg, txtCol: txtCol), calcBtn("2", numBg, txtCol: txtCol), calcBtn("3", numBg, txtCol: txtCol), calcBtn("+", Colors.orange)]),
        Row(children: [calcBtn(".", numBg, txtCol: txtCol), calcBtn("0", numBg, txtCol: txtCol), calcBtn("⌫", Colors.orange), calcBtn("=", Colors.green)]),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  final bool isDark;
  final Function(bool) onThemeChanged;
  const SettingsPage({super.key, required this.isDark, required this.onThemeChanged});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(title: const Text("Dark Mode"), value: isDark, onChanged: (v) => onThemeChanged(v)),
          const Divider(),
          const ListTile(leading: Icon(Icons.person), title: Text("Developer"), subtitle: Text("Menul19")),
        ],
      ),
    );
  }
}
