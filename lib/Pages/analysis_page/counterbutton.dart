import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CounterWidget(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 1; // Initial value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red), // Border color
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus button
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (_counter > 0) _counter--; // Decrease counter
                  });
                },
              ),
              // Display counter value
              Text(
                '$_counter',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Plus button
              IconButton(
                icon: const Icon(Icons.add, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _counter++; // Increase counter
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
