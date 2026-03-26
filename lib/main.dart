import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

enum RiskLevel { low, medium, high }

class ScanResult {
  final RiskLevel level;
  final int score;
  final String message;
  final String url;
  final List<String> details;

  ScanResult({
    required this.level,
    required this.score,
    required this.message,
    required this.url,
    required this.details,
  });
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

class _ScannerPageState extends State<ScannerPage> {
  ScanResult? result;
  bool isAnalyzing = false;

  Future<void> _handleScan(String? code) async {
    if (code == null || isAnalyzing) return;

    setState(() => isAnalyzing = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final uri = Uri.tryParse(code);

    if (uri == null || !uri.hasScheme) {
      _setResult(ScanResult(
        level: RiskLevel.high,
        score: 90,
        message: "Invalid QR",
        url: code,
        details: ["Invalid link"],
      ));
      return;
    }

    int score = 0;
    List<String> details = [];

    if (uri.scheme != "https") {
      score += 30;
      details.add("No HTTPS");
    } else {
      details.add("Secure HTTPS");
    }

    if (uri.host.contains("login") ||
        uri.host.contains("verify") ||
        uri.host.contains("secure")) {
      score += 40;
      details.add("Suspicious keywords");
    }

    if (uri.host.length > 25) {
      score += 15;
      details.add("Long domain");
    }

    if (uri.host.contains("-")) {
      score += 10;
      details.add("Hyphen domain");
    }

    RiskLevel level;
    String message;

    if (score < 30) {
      level = RiskLevel.low;
      message = "Safe";
    } else if (score < 70) {
      level = RiskLevel.medium;
      message = "Be careful";
    } else {
      level = RiskLevel.high;
      message = "High risk";
    }

    _setResult(ScanResult(
      level: level,
      score: score,
      message: message,
      url: code,
      details: details,
    ));
  }

  void _setResult(ScanResult res) {
    setState(() {
      result = res;
      isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final code = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first.rawValue
                  : null;

              _handleScan(code);
            },
          ),

          const ScannerOverlay(),

          if (isAnalyzing)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            ),

          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (result == null) return const SizedBox();

    Color color;
    switch (result!.level) {
      case RiskLevel.low:
        color = Colors.green;
        break;
      case RiskLevel.medium:
        color = Colors.orange;
        break;
      case RiskLevel.high:
        color = Colors.red;
        break;
    }

    return Positioned(
      bottom: 25,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${result!.message} (${result!.score})",
              style: TextStyle(color: color, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              result!.url,
              style:
                  const TextStyle(color: Colors.blueAccent, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 100, end: 400).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Positioned(
          top: animation.value,
          left: 40,
          right: 40,
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.greenAccent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
