import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ASCyberApp());
}

class ASCyberApp extends StatelessWidget {
  const ASCyberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A.S. Anti-Scam',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF06080C),
        useMaterial3: true,
      ),
      home: const ScanPage(),
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  static const Color gold = Color(0xFFF4C842);
  static const Color goldSoft = Color(0xFFFFD95E);
  static const Color panel = Color(0xFF121A24);
  static const Color panelBorder = Color(0xFF253140);
  static const Color bg = Color(0xFF05070B);

  late final AnimationController _scanLineController;
  late final MobileScannerController _cameraController;

  bool _isScanning = false;
  bool _beepEnabled = true;
  bool _didHandleDetection = false;

  String _signalStatus = 'STABLE';
  String _threatStatus = 'LOW';
  String _lastResult = 'No code detected yet';

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
      autoStart: false,
      formats: const [],
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    try {
      setState(() {
        _isScanning = true;
        _didHandleDetection = false;
        _signalStatus = 'SCANNING';
        _threatStatus = 'ANALYZING';
        _lastResult = 'Live camera sweep active';
      });

      _scanLineController.repeat(reverse: true);
      await _cameraController.start();
    } catch (e) {
      setState(() {
        _isScanning = false;
        _signalStatus = 'ERROR';
        _threatStatus = 'CHECK';
        _lastResult = 'Camera could not start';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera failed to start: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _stopScan() async {
    try {
      await _cameraController.stop();
    } catch (_) {}

    _scanLineController.stop();

    if (mounted) {
      setState(() {
        _isScanning = false;
        _signalStatus = 'STABLE';
        _threatStatus = 'LOW';
      });
    }
  }

  Future<void> _toggleScan() async {
    if (_isScanning) {
      await _stopScan();
    } else {
      await _startScan();
    }
  }

  void _handleDetection(BarcodeCapture capture) {
    if (!_isScanning) return;
    if (_didHandleDetection) return;
    if (capture.barcodes.isEmpty) return;

    final Barcode barcode = capture.barcodes.first;
    final String value =
        barcode.rawValue?.trim().isNotEmpty == true ? barcode.rawValue!.trim() : 'Code detected';

    _didHandleDetection = true;

    if (_beepEnabled) {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _signalStatus = 'LOCKED';
      _threatStatus = 'REVIEW';
      _lastResult = value;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _didHandleDetection = false;
      if (_isScanning) {
        setState(() {
          _signalStatus = 'SCANNING';
          _threatStatus = 'ANALYZING';
        });
      }
    });
  }

  void _saveLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs saved: $_lastResult'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF18212B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [
              Color(0xFF0A1220),
              Color(0xFF070B12),
              Color(0xFF04060A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                'SCAN',
                style: TextStyle(
                  color: gold,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Column(
                    children: [
                      _buildMainCard(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              title: 'Signal',
                              value: _signalStatus,
                              icon: Icons.bolt_rounded,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildStatusCard(
                              title: 'Threat',
                              value: _threatStatus,
                              icon: Icons.show_chart_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 62,
                              child: ElevatedButton(
                                onPressed: _toggleScan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: const Color(0xFF111111),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _isScanning ? 'STOP SCAN' : 'START SCAN',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 62,
                              child: OutlinedButton(
                                onPressed: _saveLogs,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: gold,
                                  side: const BorderSide(color: gold, width: 1.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: const Text(
                                  'SAVE LOGS',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildBeepCard(),
                      const SizedBox(height: 16),
                      _buildResultCard(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: panel.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: panelBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: gold.withOpacity(0.08),
            blurRadius: 35,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'A.S. Anti-Scam',
            style: TextStyle(
              color: gold,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Live sweep • anomaly watch',
            style: TextStyle(
              color: goldSoft.withOpacity(0.92),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _buildCameraScannerArea(),
        ],
      ),
    );
  }

  Widget _buildCameraScannerArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 1.9,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16202B),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isScanning)
                MobileScanner(
                  controller: _cameraController,
                  onDetect: _handleDetection,
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1B2530),
                        Color(0xFF1A2330),
                        Color(0xFF16202A),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

              CustomPaint(
                painter: _GridPainter(),
              ),

              if (_isScanning)
                AnimatedBuilder(
                  animation: _scanLineController,
                  builder: (context, child) {
                    final top = 24 +
                        ((_scanLineController.value) *
                            (MediaQuery.of(context).size.width * 0.36));

                    return Positioned(
                      left: 0,
                      right: 0,
                      top: top,
                      child: child!,
                    );
                  },
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          gold.withOpacity(0.12),
                          gold.withOpacity(0.50),
                          gold.withOpacity(0.12),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gold.withOpacity(0.50),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

              Center(
                child: Container(
                  width: 165,
                  height: 165,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gold.withOpacity(0.20),
                    border: Border.all(
                      color: gold.withOpacity(0.95),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withOpacity(0.35),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: gold.withOpacity(0.24),
                          width: 1.6,
                        ),
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        size: 58,
                        color: gold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: panel.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: panelBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: gold.withOpacity(0.95),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: gold,
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeepCard() {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E151E).withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: panelBorder, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.music_note_rounded, color: gold, size: 30),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Scan beep sound',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(
            value: _beepEnabled,
            onChanged: (value) {
              setState(() {
                _beepEnabled = value;
              });
            },
            activeColor: goldSoft,
            activeTrackColor: const Color(0xFF917828),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D131B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: panelBorder, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last detection',
            style: TextStyle(
              color: gold,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            _lastResult,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _BottomItem(
            icon: Icons.radar_rounded,
            label: 'Scan',
            selected: true,
          ),
          _BottomItem(
            icon: Icons.shield_outlined,
            label: 'Status',
            selected: false,
          ),
          _BottomItem(
            icon: Icons.qr_code_2_rounded,
            label: 'QR/Link',
            selected: false,
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF4C842);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? gold.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: selected ? gold : Colors.white70,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: selected ? gold : Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    const step = 26.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
