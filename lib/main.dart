import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  double num1 = 0;
  double num2 = 0;
  String operand = '';

  void onButtonClick(String text) {
    setState(() {
      if (text == 'C') {
        display = '0';
        num1 = 0;
        num2 = 0;
        operand = '';
      } else if (text == '+' || text == '-' || text == 'x' || text == '/') {
        num1 = double.parse(display);
        operand = text;
        display = '0';
      } else if (text == '=') {
        num2 = double.parse(display);
        if (operand == '+') display = (num1 + num2).toString();
        if (operand == '-') display = (num1 - num2).toString();
        if (operand == 'x') display = (num1 * num2).toString();
        if (operand == '/') display = (num1 / num2).toString();
        operand = '';
      } else {
        display = display == '0' ? text : display + text;
      }
    });
  }

  Widget buildButton(String text, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => onButtonClick(text),
          child: Text(text, style: const TextStyle(fontSize: 24, color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Smart Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(display, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ),
          ),
          Column(
            children: [
              Row(children: [buildButton('7', Colors.grey), buildButton('8', Colors.grey), buildButton('9', Colors.grey), buildButton('/', Colors.orange)]),
              Row(children: [buildButton('4', Colors.grey), buildButton('5', Colors.grey), buildButton('6', Colors.grey), buildButton('x', Colors.orange)]),
              Row(children: [buildButton('1', Colors.grey), buildButton('2', Colors.grey), buildButton('3', Colors.grey), buildButton('-', Colors.orange)]),
              Row(children: [buildButton('C', Colors.red), buildButton('0', Colors.grey), buildButton('=', Colors.green), buildButton('+', Colors.orange)]),
            ],
          )
        ],
      ),
    );
  }
}
