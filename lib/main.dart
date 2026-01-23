import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const QRAntiScamApp());
}

class QRAntiScamApp extends StatelessWidget {
  const QRAntiScamApp({super.key});

  // App styling
  static const Color bg = Color(0xFF050608);
  static const Color panel = Color(0xFF0C0F14);
  static const Color gold = Color(0xFFFFD54A);
  static const Color goldSoft = Color(0x66FFD54A);
  static const Color line = Color(0x33FFD54A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A.S. Anti-Scam App',

      // Force English only
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: gold,
          surface: panel,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  final _analyzer = LinkAnalyzer();
  AnalysisResult _lastResult = const AnalysisResult(
    level: RiskLevel.unknown,
    title: 'No analysis yet',
    details: 'Paste a QR/link or scan one to analyze.',
    url: '',
  );

  String _lastCaptured = '';

  void _applyResult(AnalysisResult r, {String? captured}) {
    setState(() {
      _lastResult = r;
      if (captured != null) _lastCaptured = captured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ScanPage(
        lastResult: _lastResult,
        onAnalyze: (text) {
          final r = _analyzer.analyze(text);
          _applyResult(r, captured: text);
        },
        onScanned: (value) {
          final r = _analyzer.analyze(value);
          _applyResult(r, captured: value);
        },
      ),
      StatusPage(
        result: _lastResult,
        lastCaptured: _lastCaptured,
      ),
      QrLinkPage(
        result: _lastResult,
        lastCaptured: _lastCaptured,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF050608),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            // Your header logo (NOT the launcher icon generation)
            Image.asset(
              'assets/icons/icon.png',
              width: 28,
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('A.S. Anti-Scam App'),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: const Color(0xFF070A10),
        indicatorColor: const Color(0x33FFD54A),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            label: 'Status',
          ),
          NavigationDestination(
            icon: Icon(Icons.link),
            label: 'QR Link',
          ),
        ],
      ),
    );
  }
}

class ScanPage extends StatefulWidget {
  final AnalysisResult lastResult;
  final void Function(String text) onAnalyze;
  final void Function(String scannedValue) onScanned;

  const ScanPage({
    super.key,
    required this.lastResult,
    required this.onAnalyze,
    required this.onScanned,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _input = TextEditingController();
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool get _isDesktop {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  void dispose() {
    _input.dispose();
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'SCAN',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD54A),
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (_isDesktop) ...[
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desktop mode (Windows/Mac/Linux)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Camera scanning is disabled on desktop. Paste the QR content or link below.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _input,
                    minLines: 6,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Paste here (example: https://example.com)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => widget.onAnalyze(_input.text.trim()),
                    icon: const Icon(Icons.search),
                    label: const Text('Analyze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54A),
                      foregroundColor: const Color(0xFF050608),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: _Panel(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: MobileScanner(
                    controller: _scanner,
                    onDetect: (capture) {
                      final codes = capture.barcodes;
                      if (codes.isEmpty) return;
                      final raw = codes.first.rawValue;
                      if (raw == null || raw.trim().isEmpty) return;
                      widget.onScanned(raw.trim());
                    },
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),
          RiskBanner(result: widget.lastResult),
        ],
      ),
    );
  }
}

class StatusPage extends StatelessWidget {
  final AnalysisResult result;
  final String lastCaptured;

  const StatusPage({
    super.key,
    required this.result,
    required this.lastCaptured,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'STATUS',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD54A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.details,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                _KeyValue(label: 'Risk level', value: result.level.label),
                const SizedBox(height: 8),
                _KeyValue(
                  label: 'Detected URL',
                  value: result.url.isEmpty ? '(none)' : result.url,
                ),
                const SizedBox(height: 8),
                _KeyValue(
                  label: 'Raw input',
                  value: lastCaptured.isEmpty ? '(none)' : lastCaptured,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QrLinkPage extends StatelessWidget {
  final AnalysisResult result;
  final String lastCaptured;

  const QrLinkPage({
    super.key,
    required this.result,
    required this.lastCaptured,
  });

  Future<void> _open(BuildContext context, String url) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No URL available to open.')),
      );
      return;
    }

    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL.')),
      );
      return;
    }

    final ok = await canLaunchUrl(uri);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this URL.')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final urlToOpen = result.url.isNotEmpty ? result.url : lastCaptured;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'QR LINK',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD54A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Open the detected link',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  urlToOpen.isEmpty ? '(no link detected yet)' : urlToOpen,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _open(context, urlToOpen),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54A),
                    foregroundColor: const Color(0xFF050608),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiskBanner extends StatelessWidget {
  final AnalysisResult result;

  const RiskBanner({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    switch (result.level) {
      case RiskLevel.low:
        bg = const Color(0xFF123A22);
        fg = const Color(0xFF9FF0BE);
        text = 'LOW RISK — looks OK, but stay alert.';
        break;
      case RiskLevel.medium:
        bg = const Color(0xFF3A2E12);
        fg = const Color(0xFFFFD28A);
        text = 'MEDIUM RISK — proceed with caution.';
        break;
      case RiskLevel.high:
        bg = const Color(0xFF3A1212);
        fg = const Color(0xFFFF9B9B);
        text = 'HIGH RISK — do not open or share information.';
        break;
      case RiskLevel.unknown:
        bg = const Color(0xFF10141C);
        fg = Colors.white70;
        text = 'No analysis yet — scan or paste a link to analyze.';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFD54A)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: fg, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0F14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFD54A)),
      ),
      child: child,
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ---------- Analyzer (simple, local rules) ----------

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

class LinkAnalyzer {
  AnalysisResult analyze(String raw) {
    final input = raw.trim();
    if (input.isEmpty) {
      return const AnalysisResult(
        level: RiskLevel.unknown,
        title: 'No input',
        details: 'Paste a QR/link or scan one to analyze.',
        url: '',
      );
    }

    final detectedUrl = _extractUrl(input);

    if (detectedUrl.isEmpty) {
      return AnalysisResult(
        level: RiskLevel.medium,
        title: 'Content detected (not a URL)',
        details:
            'This QR content is not a standard URL. Be cautious with unknown formats.',
        url: '',
      );
    }

    final uri = Uri.tryParse(detectedUrl);
    if (uri == null) {
      return AnalysisResult(
        level: RiskLevel.high,
        title: 'Invalid URL format',
        details:
            'The detected link is malformed. Treat it as suspicious and avoid opening it.',
        url: detectedUrl,
      );
    }

    // Simple offline heuristics (local rules)
    final host = (uri.host).toLowerCase();
    final path = uri.path.toLowerCase();
    final full = detectedUrl.toLowerCase();

    final isHttp = uri.scheme == 'http';
    final hasIpHost = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host);

    final suspiciousWords = [
      'login',
      'verify',
      'update',
      'password',
      'wallet',
      'bank',
      'secure',
      'account',
      'free',
      'gift',
      'prize',
      'bonus',
      'crypto',
    ];

    int score = 0;
    if (isHttp) score += 2; // no TLS
    if (hasIpHost) score += 3;
    if (host.contains('-') || host.contains('_')) score += 1;
    if (host.split('.').length >= 4) score += 1;

    for (final w in suspiciousWords) {
      if (path.contains(w) || full.contains(w)) score += 1;
    }

    if (score >= 6) {
      return AnalysisResult(
        level: RiskLevel.high,
        title: 'High risk link',
        details:
            'This link matches multiple risk signals (non-HTTPS, unusual host, or suspicious keywords). Do not enter credentials or payment details.',
        url: detectedUrl,
      );
    }

    if (score >= 3) {
      return AnalysisResult(
        level: RiskLevel.medium,
        title: 'Medium risk link',
        details:
            'This link shows some warning signals. Double-check the domain and avoid entering sensitive data.',
        url: detectedUrl,
      );
    }

    return AnalysisResult(
      level: RiskLevel.low,
      title: 'Low risk (basic checks)',
      details:
          'No strong risk signals detected by offline checks. Still verify the domain before trusting it.',
      url: detectedUrl,
    );
  }

  String _extractUrl(String input) {
    // If it already looks like a URL
    final direct = Uri.tryParse(input);
    if (direct != null && (direct.scheme == 'http' || direct.scheme == 'https')) {
      return input;
    }

    // Try to find a URL in longer text
    final re = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
    final m = re.firstMatch(input);
    if (m == null) return '';

    return m.group(0) ?? '';
  }
}
