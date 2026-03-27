import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0A0C10),
        fontFamily: 'SF Pro Display',
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
  late final AnimationController _controller;

  bool _isScanning = false;
  bool _beepEnabled = true;

  String _signalStatus = 'STABLE';
  String _threatStatus = 'LOW';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addListener(() {
        if (_isScanning && _beepEnabled) {
          final value = _controller.value;
          if ((value > 0.02 && value < 0.04) ||
              (value > 0.48 && value < 0.50) ||
              (value > 0.94 && value < 0.96)) {
            SystemSound.play(SystemSoundType.click);
            HapticFeedback.selectionClick();
          }
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;

      if (_isScanning) {
        _signalStatus = 'SCANNING';
        _threatStatus = 'ANALYZING';
        _controller.repeat(reverse: true);
      } else {
        _signalStatus = 'STABLE';
        _threatStatus = 'LOW';
        _controller.stop();
      }
    });
  }

  void _saveLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF14181F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFFFD54A), width: 0.7),
        ),
        content: const Text(
          'Logs saved successfully.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD54A);
    const goldSoft = Color(0xFFFFE082);
    const panel = Color(0xFF1A2129);
    const panel2 = Color(0xFF12171D);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.15,
              colors: [
                Color(0xFF1A1E24),
                Color(0xFF0E1116),
                Color(0xFF090B0F),
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // TOP TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      'SCAN',
                      style: TextStyle(
                        color: gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const Spacer(),

              // MAIN SCAN CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  decoration: BoxDecoration(
                    color: panel.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
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
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Live sweep • anomaly watch',
                        style: TextStyle(
                          color: goldSoft.withValues(alpha: 0.95),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // SCAN AREA
                      AspectRatio(
                        aspectRatio: 1.95,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final lineY = _isScanning
                                ? 0.20 + (_controller.value * 0.60)
                                : 0.50;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                                color: const Color(0xFF202830),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: CustomPaint(
                                  painter: ScanGridPainter(
                                    lineY: lineY,
                                    isScanning: _isScanning,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 138,
                                      height: 138,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: gold.withValues(alpha: 0.18),
                                        border: Border.all(
                                          color: gold.withValues(alpha: 0.85),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: gold.withValues(alpha: 0.35),
                                            blurRadius: 30,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.shield_rounded,
                                          size: 44,
                                          color: gold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // STATUS CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatusCard(
                        title: 'Signal',
                        value: _signalStatus,
                        icon: Icons.bolt_rounded,
                        accent: gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusCard(
                        title: 'Threat',
                        value: _threatStatus,
                        icon: Icons.show_chart_rounded,
                        accent: gold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _toggleScan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: const Color(0xFF202020),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            _isScanning ? 'STOP SCAN' : 'START SCAN',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _saveLogs,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: gold,
                            side: BorderSide(
                              color: gold.withValues(alpha: 0.90),
                              width: 1.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'SAVE LOGS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // BEEP SWITCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 58,
                  decoration: BoxDecoration(
                    color: panel2,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _beepEnabled
                            ? Icons.music_note_rounded
                            : Icons.music_off_rounded,
                        color: gold,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Scan beep sound',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: _beepEnabled,
                        onChanged: (value) {
                          setState(() => _beepEnabled = value);
                        },
                        activeColor: gold,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade800,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // BOTTOM NAV
              Container(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _BottomNavItem(
                      icon: Icons.radar_rounded,
                      label: 'Scan',
                      selected: true,
                    ),
                    _BottomNavItem(
                      icon: Icons.shield_moon_rounded,
                      label: 'Status',
                      selected: false,
                    ),
                    _BottomNavItem(
                      icon: Icons.qr_code_2_rounded,
                      label: 'QR/Link',
                      selected: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2129),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.90),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: accent,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD54A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 34,
          decoration: BoxDecoration(
            color: selected ? gold.withValues(alpha: 0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: selected ? gold : Colors.white70,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: selected ? gold : Colors.white70,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ScanGridPainter extends CustomPainter {
  final double lineY;
  final bool isScanning;

  ScanGridPainter({
    required this.lineY,
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gold = Color(0xFFFFD54A);

    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF26313A),
          Color(0xFF1B242C),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const gridStep = 20.0;

    for (double x = 0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.24;

    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = gold.withValues(alpha: 0.32);

    canvas.drawCircle(center, radius + 16, pulsePaint);

    final linePosY = size.height * lineY;

    final scanGlowRect = Rect.fromLTWH(0, linePosY - 18, size.width, 36);
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          gold.withValues(alpha: isScanning ? 0.08 : 0.03),
          gold.withValues(alpha: isScanning ? 0.24 : 0.06),
          gold.withValues(alpha: isScanning ? 0.08 : 0.03),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(scanGlowRect);

    canvas.drawRect(scanGlowRect, glowPaint);

    final linePaint = Paint()
      ..color = gold
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawLine(
      Offset(18, linePosY),
      Offset(size.width - 18, linePosY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanGridPainter oldDelegate) {
    return oldDelegate.lineY != lineY || oldDelegate.isScanning != isScanning;
  }
}
