import 'package:flutter/material.dart';

void main() {
  runApp(const MenuScICal());
}

class MenuScICal extends StatelessWidget {
  const MenuScICal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu ScICal',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String equation = "0";
  String result = "0";

  // Unit Conversion
  double unitInput = 0;
  String unitResult = "Result: --";
  String selectedUnit = "CM to Meters";

  buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        equation = "0";
        result = "0";
      } else if (buttonText == "⌫") {
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") equation = "0";
      } else if (buttonText == "=") {
        // සරලව පෙන්වීමට: සැබෑ ඇප් එකකදී මෙහි math logic එක තවත් දියුණු කළ හැක
        result = "Done"; 
      } else {
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  void convertUnits() {
    setState(() {
      if (selectedUnit == "CM to Meters") unitResult = "${unitInput / 100} m";
      if (selectedUnit == "Meters to CM") unitResult = "${unitInput * 100} cm";
      if (selectedUnit == "KG to Grams") unitResult = "${unitInput * 1000} g";
      if (selectedUnit == "Grams to KG") unitResult = "${unitInput / 1000} kg";
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Menu ScICal"),
          backgroundColor: Colors.blueAccent,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calculate), text: "Calc"),
              Tab(icon: Icon(Icons.swap_horiz), text: "Units"),
              Tab(icon: Icon(Icons.info), text: "About"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCalculator(),
            _buildConverter(),
            _buildAbout(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculator() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Text(equation, style: const TextStyle(fontSize: 38)),
        ),
        const Expanded(child: Divider()),
        _buildButtonGrid(),
      ],
    );
  }

  Widget _buildButtonGrid() {
    var buttons = ["C", "⌫", "/", "*", "7", "8", "9", "-", "4", "5", "6", "+", "1", "2", "3", "=", "0", "."];
    return Wrap(
      children: buttons.map((btn) => SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        height: 70,
        child: TextButton(
          onPressed: () => buttonPressed(btn),
          child: Text(btn, style: const TextStyle(fontSize: 24, color: Colors.white)),
        ),
      )).toList(),
    );
  }

  Widget _buildConverter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: "Enter Value"),
            onChanged: (value) => unitInput = double.tryParse(value) ?? 0,
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedUnit,
            isExpanded: true,
            dropdownColor: Colors.black,
            items: ["CM to Meters", "Meters to CM", "KG to Grams", "Grams to KG"]
                .map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
            onChanged: (val) => setState(() => selectedUnit = val!),
          ),
          ElevatedButton(onPressed: convertUnits, child: const Text("Convert")),
          const SizedBox(height: 20),
          Text(unitResult, style: const TextStyle(fontSize: 24, color: Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _buildAbout() {
    return const Center(
      child: Text("Menu ScICal\nDeveloped by: Menul19", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
    );
  }
}
