import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    // 카메라 리소스 해제
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false, // 왼쪽 정렬
        title: Text(
          "Bookworm",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto', // 원하는 폰트를 추가하세요.
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              print('Scanned barcode: $code');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scanned: $code')),
              );
            }
          }
        },
      ),
    );
  }
}
