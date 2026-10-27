import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: HoverTest()));
}

class HoverTest extends StatefulWidget {
  const HoverTest({super.key});

  @override
  State<HoverTest> createState() => _HoverTestState();
}

class _HoverTestState extends State<HoverTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MouseRegion(
          onEnter: (_) {
            debugPrint("MOUSE ENTERED");
          },
          onExit: (_) {
            debugPrint("MOUSE LEFT");
          },
          child: Container(
            width: 300,
            height: 300,
            color: Colors.blue,
            child: const Center(
              child: Text("HOVER OVER ME", style: TextStyle(fontSize: 30)),
            ),
          ),
        ),
      ),
    );
  }
}
