import 'package:flutter/material.dart';
// importul pentru scanner (ex: mobile_scanner)
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

// ---------------- APP ----------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A.S. Anti-Scam',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

// ---------------- UI PAGE ----------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AnalysisResult? result;

  // 🔥 FIX UI: handler corect
  void _handleScan(String? data) {
    // ❌ nimic detectat → reset UI
    if (data == null || data.isEmpty) {
      setState(() {
        result = null;
      });
      return;
    }

    final analysis = analyzeInput(data);

    setState(() {
      result = analysis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('A.S. Anti-Scam App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 🔽 AICI vine camera/scanner-ul tău
          // Exemplu (decomentează dacă folosești mobile_scanner):
          
          SizedBox(
            height: 300,
            child: MobileScanner(
              onDetect: (barcode, args) {
                final List<Barcode> barcodes = capture.barcodes;
                final String? code =
                    barcodes.isNotEmpty ? barcodes.first.rawValue : null; 
                 _handleScan(code);
              },
            ),
          ),
          

          const SizedBox(height: 16),

          // 🔥 UI corect (nu mai arată risc fără scan)
          Expanded(
            child: Center(
              child: result == null || result!.level == RiskLevel.unknown
                  ? const Text(
                      "Scan a QR code to begin",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    )
                  : _ResultCard(result: result!),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- RESULT UI ----------------

class _ResultCard extends StatelessWidget {
  final AnalysisResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (result.level) {
      case RiskLevel.low:
        color = Colors.green;
        break;
      case RiskLevel.medium:
        color = Colors.orange;
        break;
      case RiskLevel.high:
        color = Colors.red;
        break;
      case RiskLevel.unknown:
        color = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.title,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result.details,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (result.url.isNotEmpty)
            Text(
              result.url,
              style: const TextStyle(color: Colors.blueAccent),
            ),
        ],
      ),
    );
  }
}

// ---------------- ANALYZER ----------------

enum RiskLevel { low, medium, high, unknown }

extension on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.medium:
        return 'MEDIUM';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.unknown:
        return 'UNKNOWN';
    }
  }
}

class AnalysisResult {
  final RiskLevel level;
  final String title;
  final String details;
  final String url;

  const AnalysisResult({
    required this.level,
    required this.title,
    required this.details,
    required this.url,
  });
}

// 🔥 ANALYZER FIX COMPLET
AnalysisResult analyzeInput(String input) {
  final detectedUrl = _extractUrl(input);

  // ❌ fără QR valid → NU arătăm risc
  if (detectedUrl.isEmpty) {
    return const AnalysisResult(
      level: RiskLevel.unknown,
      title: 'No valid QR code detected',
      details: 'Scan a valid QR code or QR link to analyze risk.',
      url: '',
    );
  }

  int score = 0;

  final uri = Uri.tryParse(detectedUrl);

  if (uri == null) {
    score += 5;
  } else {
    if (uri.scheme != 'https') score += 2;

    if (uri.host.contains('bit.ly') ||
        uri.host.contains('tinyurl') ||
        uri.host.contains('goo.gl')) {
      score += 3;
    }

    if (uri.host.contains('-') || uri.host.contains('secure-login')) {
      score += 2;
    }
  }

  if (score >= 6) {
    return AnalysisResult(
      level: RiskLevel.high,
      title: 'HIGH RISK — do not open.',
      details:
          'This link shows strong scam signals. Avoid entering any personal data.',
      url: detectedUrl,
    );
  }

  if (score >= 3) {
    return AnalysisResult(
      level: RiskLevel.medium,
      title: 'MEDIUM RISK — proceed with caution.',
      details:
          'This link shows warning signals. Double-check the domain.',
      url: detectedUrl,
    );
  }

  return AnalysisResult(
    level: RiskLevel.low,
    title: 'LOW RISK — looks OK, but stay alert.',
    details:
        'No strong risk signals detected by offline checks. Still verify the domain.',
    url: detectedUrl,
  );
}

// 🔥 extract URL FIX
String _extractUrl(String input) {
  if (input.isEmpty) return '';

  final direct = Uri.tryParse(input);
  if (direct != null &&
      (direct.scheme == 'http' || direct.scheme == 'https')) {
    return input;
  }

  final re = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
  final match = re.firstMatch(input);

  if (match != null) {
    return match.group(0) ?? '';
  }

  return '';
}
