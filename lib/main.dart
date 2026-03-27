import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  String resultText = "Scan a QR code";
  Color resultColor = Colors.white;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0, end: 300).animate(_controller);
  }

  void analyze(String code) {
    int score = code.length % 100;

    String verdict;
    Color color;

    if (score < 20) {
      verdict = "SAFE";
      color = Colors.green;
    } else if (score < 50) {
      verdict = "LOW RISK";
      color = Colors.lightGreen;
    } else if (score < 80) {
      verdict = "SUSPICIOUS";
      color = Colors.orange;
    } else {
      verdict = "DANGEROUS";
      color = Colors.red;
    }

    setState(() {
      resultText = "$verdict • Score: $score";
      resultColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcode, args) {
              final String? code = barcode.rawValue;
              if (code != null) {
                analyze(code);
              }
            },
          ),

          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Positioned(
                top: _animation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Colors.greenAccent,
                ),
              );
            },
          ),

          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: resultColor),
              ),
              child: Text(
                resultText,
                textAlign: TextAlign.center,
                style: TextStyle(color: resultColor, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
