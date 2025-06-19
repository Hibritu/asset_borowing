import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

class QRScannerWindows extends StatefulWidget {
  const QRScannerWindows({super.key});

  @override
  State<QRScannerWindows> createState() => _QRScannerWindowsState();
}

class _QRScannerWindowsState extends State<QRScannerWindows> {
  String? qrResult = '';
  bool isLoading = false;

  Future<void> pickAndScanImage() async {
  setState(() {
    isLoading = true;
    qrResult = null;
  });

  final result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    final filePath = result.files.single.path!;
    final bytes = await File(filePath).readAsBytes();

    final image = img.decodeImage(bytes);
    if (image == null) {
      setState(() {
        qrResult = 'Could not decode image';
        isLoading = false;
      });
      return;
    }

    // ✅ Convert Uint8List to Int32List using ARGB format
    final Int32List argbData = Int32List.fromList(
      image.getBytes(order: img.ChannelOrder.argb).buffer.asInt32List()
    );

    final luminanceSource = RGBLuminanceSource(
      image.width,
      image.height,
      argbData,
    );

    final bitmap = BinaryBitmap(HybridBinarizer(luminanceSource));
    final reader = QRCodeReader();

    try {
      final result = reader.decode(bitmap);
      setState(() {
        qrResult = result.text;
      });
    } catch (e) {
      setState(() {
        qrResult = 'No QR code found';
      });
    }
  }

  setState(() {
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Scanner (Windows)")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: pickAndScanImage,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Pick Image to Scan QR'),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator()
              else if (qrResult != null)
                Text("QR Result: $qrResult", style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
