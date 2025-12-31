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
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF17171C),
      ),
      home: CalculatorHome(onThemeChanged: _toggleTheme),
    );
  }
}

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
        result = "Result Ready"; // Logic can be expanded here
      } else {
        equation = equation == "0" ? text : equation + text;
      }
    });
  }

  Widget calcBtn(String txt, Color col, {Color txtCol = Colors.white}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: col,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        title: const Text("Menu ScICal Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => 
              SettingsPage(isDark: isDark, onThemeChanged: widget.onThemeChanged))),
          )
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
                  const SizedBox(height: 12),
                  Text(result, style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Divider(),
          Column(
            children: [
              Row(children: [calcBtn("sin", Colors.blue), calcBtn("cos", Colors.blue), calcBtn("tan", Colors.blue), calcBtn("/", Colors.orange)]),
              Row(children: [calcBtn("7", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("8", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("9", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("*", Colors.orange)]),
              Row(children: [calcBtn("4", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("5", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("6", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("-", Colors.orange)]),
              Row(children: [calcBtn("1", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("2", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("3", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("+", Colors.orange)]),
              Row(children: [calcBtn("AC", Colors.redAccent), calcBtn("0", isDark ? Colors.grey[850]! : Colors.grey[300]!, txtCol: isDark ? Colors.white : Colors.black), calcBtn("⌫", Colors.orange), calcBtn("=", Colors.green)]),
            ],
          )
        ],
      ),
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
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDark,
            onChanged: (v) => onThemeChanged(v),
          ),
          const Divider(),
          const ListTile(leading: Icon(Icons.person), title: Text("Developer"), subtitle: Text("Menul19")),
          const ListTile(leading: Icon(Icons.verified), title: Text("Version"), subtitle: Text("4.0.0 Stable Edition")),
        ],
      ),
    );
  }
}
