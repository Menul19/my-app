import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MenuScICal());
}

class MenuScICal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu ScICal',
      themeMode: ThemeMode.system,
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _output = "0";
  String _input = "";
  
  // Unit Conversion Variables
  double _unitInput = 0;
  String _unitResult = "Result: --";
  String _selectedUnit = "CM to Meters";

  void _buttonPressed(String text) {
    setState(() {
      if (text == "C") {
        _input = "";
        _output = "0";
      } else if (text == "=") {
        try {
          // සරල ගණනය කිරීම් සඳහා
          _output = _calculate(_input);
        } catch (e) {
          _output = "Error";
        }
      } else {
        _input += text;
        _output = _input;
      }
    });
  }

  String _calculate(String input) {
    // සරල ගණිතමය තර්කනය (මෙහිදී ඔබට අවශ්‍ය නම් math expressions library එකක් පාවිච්චි කළ හැක)
    // දැනට සරල උදාහරණයක් ලෙස:
    return "Result"; 
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Menu ScICal"),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Calculator"),
              Tab(text: "Converter"),
              Tab(text: "About"),
              Tab(text: "Settings"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Calculator Tab ---
            Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  child: Text(_output, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: Divider()),
                _buildButtons(),
              ],
            ),

            // --- Converter Tab ---
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Enter Value"),
                    onChanged: (value) => _unitInput = double.tryParse(value) ?? 0,
                  ),
                  DropdownButton<String>(
                    value: _selectedUnit,
                    isExpanded: true,
                    items: ["CM to Meters", "Meters to CM", "KG to Grams", "Grams to KG"]
                        .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedUnit = val!),
                  ),
                  ElevatedButton(
                    onPressed: _convertUnits,
                    child: Text("Convert"),
                  ),
                  SizedBox(height: 20),
                  Text(_unitResult, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // --- About Tab ---
            Center(
              child: Text(
                "Menu ScICal\n\nDeveloped by: [ඔබේ නම]\nVersion: 1.0.0 (Stable)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),

            // --- Settings Tab ---
            Center(
              child: Text("Dark Mode: System Default"),
            ),
          ],
        ),
      ),
    );
  }

  void _convertUnits() {
    setState(() {
      if (_selectedUnit == "CM to Meters") _unitResult = "${_unitInput / 100} m";
      if (_selectedUnit == "Meters to CM") _unitResult = "${_unitInput * 100} cm";
      if (_selectedUnit == "KG to Grams") _unitResult = "${_unitInput * 1000} g";
      if (_selectedUnit == "Grams to KG") _unitResult = "${_unitInput / 1000} kg";
    });
  }

  Widget _buildButtons() {
    var buttons = ["7", "8", "9", "/", "4", "5", "6", "*", "1", "2", "3", "-", "C", "0", "=", "+"];
    return GridView.builder(
      itemCount: buttons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (context, index) {
        return ElevatedButton(
          onPressed: () => _buttonPressed(buttons[index]),
          child: Text(buttons[index], style: TextStyle(fontSize: 24)),
        );
      },
    );
  }
}
