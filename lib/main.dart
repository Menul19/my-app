import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MenuScICalApp(),
    ),
  );
}

// තේමාව පාලනය කරන Provider එක
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MenuScICalApp extends StatelessWidget {
  const MenuScICalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu ScICal Pro',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeProvider.themeMode,
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ScientificCalculator(),
    const UnitConverter(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Calc'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Units'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// --- Scientific Calculator කොටස ---
class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({super.key});

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String equation = "0";
  String result = "0";

  void onButtonClick(String text) {
    setState(() {
      if (text == "AC") {
        equation = "0";
        result = "0";
      } else if (text == "⌫") {
        equation = equation.length > 1 ? equation.substring(0, equation.length - 1) : "0";
      } else if (text == "=") {
        try {
          String finalEquation = equation.replaceAll('×', '*').replaceAll('÷', '/');
          Parser p = Parser();
          Expression exp = p.parse(finalEquation);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(equation, style: const TextStyle(fontSize: 28, color: Colors.grey)),
                Text(result, style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                "AC", "⌫", "(", "÷",
                "sin", "cos", "tan", "×",
                "7", "8", "9", "-",
                "4", "5", "6", "+",
                "1", "2", "3", "=",
                "0", ".", "log", "sqrt"
              ].map((text) => CalcButton(text: text, callback: onButtonClick)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CalcButton extends StatelessWidget {
  final String text;
  final Function callback;
  const CalcButton({super.key, required this.text, required this.callback});

  @override
  Widget build(BuildContext context) {
    bool isOperator = ["÷", "×", "-", "+", "="].contains(text);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOperator ? Colors.blueAccent : null,
        foregroundColor: isOperator ? Colors.white : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => callback(text),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// --- Unit Converter කොටස ---
class UnitConverter extends StatelessWidget {
  const UnitConverter({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Unit Converter Coming Soon"));
}

// --- Settings සහ About කොටස ---
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const ListTile(
            title: Text("Appearance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
          const Divider(),
          const ListTile(
            title: Text("About Developer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text("Created by Menul19"),
            subtitle: const Text("Version 2.0.0 - Stable Build"),
            trailing: IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "මෙම ඇප් එක Menul19 විසින් නිර්මාණය කරන ලදී. මෙහි සියලුම විද්‍යාත්මක ගණනය කිරීම් සහ ඒකක පරිවර්තනයන් ඇතුළත් වේ.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
