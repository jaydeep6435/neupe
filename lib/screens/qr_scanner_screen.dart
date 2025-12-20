import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'transfer/amount_entry_screen.dart';
import '../utils/colors.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AmountEntryScreen(
            receiverName: name ?? 'Unknown Merchant',
            receiverPhone: upiId!,
          ),
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
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Simulate Scan for Emulator
                  _processQRCode('upi://pay?pa=merchant@ybl&pn=Shop%20Keeper');
                },
                child: const Text('Simulate Scan (Debug)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
