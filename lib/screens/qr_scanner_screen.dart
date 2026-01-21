import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:math' as math;
import 'transfer/amount_input_page.dart';
import '../utils/colors.dart';
import '../utils/page_transitions.dart';
import '../widgets/scan_hero_icon.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
  with TickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  bool _cameraReady = false;
  String? _cameraBootError;

  late final AnimationController _introController;
  late final AnimationController _loadingController;
  late final Animation<double> _scrimOpacity;
  late final Animation<double> _frameOpacity;
  late final Animation<double> _frameScale;
  late final Animation<double> _heroOpacity;
  late final Animation<double> _heroScale;

  static const Duration _introDuration = Duration(milliseconds: 200);
  static const Duration _minCameraPlaceholder = Duration(milliseconds: 520);

  Future<void> _bootCamera() async {
    final startedAt = DateTime.now();
    try {
      await controller.start();
    } catch (e) {
      _cameraBootError = 'Camera unavailable';
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minCameraPlaceholder) {
      await Future.delayed(_minCameraPlaceholder - elapsed);
    }

    if (!mounted) return;
    setState(() {
      _cameraReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(vsync: this, duration: _introDuration);
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Subtle “premium” intro: slightly darken background + fade/scale in scan frame.
    _scrimOpacity = Tween<double>(begin: 0.0, end: 0.22).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOut),
    );
    _frameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
    );
    _frameScale = Tween<double>(begin: 0.985, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
    );

    // Let the Scan icon Hero “land” first, then fade it out as the scan frame appears.
    _heroOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );
    _heroScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    // Delay intro so the incoming Hero flight reads clearly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start camera as early as possible, and keep a premium placeholder until ready.
      _bootCamera();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _introController.forward();
      });
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _loadingController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _processQRCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _processQRCode(String rawValue) {
    setState(() {
      _isProcessing = true;
    });

    // Simple parser for UPI URLs
    // Format: upi://pay?pa=address@upi&pn=Name&...
    String? upiId;
    String? name;

    try {
      final uri = Uri.parse(rawValue);
      if (uri.scheme == 'upi') {
        upiId = uri.queryParameters['pa'];
        name = uri.queryParameters['pn'];
      } else {
        // Fallback for plain text UPI IDs
        if (rawValue.contains('@')) {
          upiId = rawValue;
        }
      }
    } catch (e) {
      // Invalid URI
    }

    if (upiId != null) {
      controller.stop();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        smoothFadeSlideRoute(
          (context) => AmountInputPage(
            contactName: name ?? 'Unknown Merchant',
            contactPhone: upiId!,
          ),
          beginOffset: const Offset(0, 0.10),
          duration: const Duration(milliseconds: 280),
          reverseDuration: const Duration(milliseconds: 240),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid UPI QR Code')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
           IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Always paint a dark/gradient backdrop to avoid any white flash.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF060B12), Color(0xFF000000)],
                ),
              ),
            ),
          ),
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          // Premium camera warm-up placeholder. It fades out when the camera is ready.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _cameraReady ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    final t = _loadingController.value;
                    final sweep = (t * 2.0) - 1.0; // -1..1
                    final scanY = 0.32 + (0.16 * (0.5 + 0.5 * math.sin(t * math.pi * 2)));

                    return Stack(
                      children: [
                        // Colorful subtle sweep.
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.92,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(-1.0 + sweep, -1.0),
                                  end: Alignment(1.0 + sweep, 1.0),
                                  colors: const [
                                    Color(0x2200E5FF),
                                    Color(0x337C4DFF),
                                    Color(0x22FFD54F),
                                    Color(0x00000000),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Small scanning line to entertain while camera warms up.
                        Align(
                          alignment: Alignment(0, (scanY * 2.0) - 1.0),
                          child: Container(
                            width: 280,
                            height: 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0x0000E5FF),
                                  Color(0xFF00E5FF),
                                  Color(0xFF7C4DFF),
                                  Color(0x0000E5FF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withOpacity(0.35),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Text hint (and error if camera couldn't start).
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 46,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _cameraBootError == null ? 'Opening camera…' : _cameraBootError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _cameraBootError == null
                                    ? 'Hold steady — scanner is starting'
                                    : 'Please check permissions and try again',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Hero destination: Scan button flies to the center before UI settles.
          Center(
            child: IgnorePointer(
              child: Hero(
                tag: kScanHeroTag,
                child: FadeTransition(
                  opacity: _heroOpacity,
                  child: ScaleTransition(
                    scale: _heroScale,
                    child: const ScanHeroIcon(size: 76),
                  ),
                ),
              ),
            ),
          ),
          // Subtle intro scrim so the scan frame “settles” nicely.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scrimOpacity,
                builder: (context, child) => Container(
                  color: Colors.black.withOpacity(_scrimOpacity.value),
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _frameOpacity,
              child: ScaleTransition(
                scale: _frameScale,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
