import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const ScientificCalcApp());

class ScientificCalcApp extends StatefulWidget {
  const ScientificCalcApp({super.key});

  @override
  State<ScientificCalcApp> createState() => _ScientificCalcAppState();
}

class _ScientificCalcAppState extends State<ScientificCalcApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu ScICal Pro',
      themeMode: _themeMode,
      theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue),
      darkTheme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF17171C)),
      home: CalculatorScreen(onThemeChanged: _toggleTheme),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const CalculatorScreen({super.key, required this.onThemeChanged});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String equation = "0";
  String result = "0";

  void buttonPressed(String btnText) {
    setState(() {
      if (btnText == "AC") {
        equation = "0";
        result = "0";
      } else if (btnText == "⌫") {
        equation = equation.length > 1 ? equation.substring(0, equation.length - 1) : "0";
      } else if (btnText == "=") {
        // සරල ගණනය කිරීම් සඳහා (Manual parsing)
        result = "Calculated"; 
      } else {
        equation = equation == "0" ? btnText : equation + btnText;
      }
    });
  }

  Widget buildButton(String btnText, Color btnColor, {Color txtColor = Colors.white}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => buttonPressed(btnText),
          child: Text(btnText, style: TextStyle(fontSize: 18, color: txtColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu ScICal Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SettingsScreen(isDark: isDark, onThemeChanged: widget.onThemeChanged))),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(equation, style: TextStyle(fontSize: 24, color: isDark ? Colors.grey : Colors.black54)),
                  const SizedBox(height: 10),
                  Text(result, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Divider(),
          _buildButtonLayout(isDark),
        ],
      ),
    );
  }

  Widget _buildButtonLayout(bool isDark) {
    Color numBg = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    Color txtColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        Row(children: [buildButton("sin", Colors.blue), buildButton("cos", Colors.blue), buildButton("tan", Colors.blue), buildButton("√", Colors.blue)]),
        Row(children: [buildButton("AC", Colors.redAccent), buildButton("⌫", Colors.orange), buildButton("%", Colors.grey), buildButton("/", Colors.blue)]),
        Row(children: [buildButton("7", numBg, txtColor: txtColor), buildButton("8", numBg, txtColor: txtColor), buildButton("9", numBg, txtColor: txtColor), buildButton("*", Colors.blue)]),
        Row(children: [buildButton("4", numBg, txtColor: txtColor), buildButton("5", numBg, txtColor: txtColor), buildButton("6", numBg, txtColor: txtColor), buildButton("-", Colors.blue)]),
        Row(children: [buildButton("1", numBg, txtColor: txtColor), buildButton("2", numBg, txtColor: txtColor), buildButton("3", numBg, txtColor: txtColor), buildButton("+", Colors.blue)]),
        Row(children: [buildButton(".", numBg, txtColor: txtColor), buildButton("0", numBg, txtColor: txtColor), buildButton("(", numBg, txtColor: txtColor), buildButton("=", Colors.green)]),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final Function(bool) onThemeChanged;
  const SettingsScreen({super.key, required this.isDark, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDark,
            onChanged: (v) => onThemeChanged(v),
          ),
          const Divider(),
          const ListTile(leading: Icon(Icons.person), title: Text("Developer"), subtitle: Text("Menul19")),
          const ListTile(leading: Icon(Icons.info), title: Text("Version"), subtitle: Text("3.0.0 Stable")),
        ],
      ),
    );
  }
}
