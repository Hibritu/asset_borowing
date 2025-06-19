import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  final TextEditingController _qrInputController = TextEditingController();
  String? qrCodeBase64;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchQRCode(String qrDataString) async {
    setState(() {
      isLoading = true;
      qrCodeBase64 = null;
      errorMessage = '';
    });

    try {
      final url = Uri.parse('http://localhost:5009/api/materials/qr/$qrDataString'); // Replace with your IP
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          qrCodeBase64 = data['qrCodeData'];
        });
      } else {
        setState(() {
          errorMessage = 'QR code not found.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Viewer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _qrInputController,
              decoration: InputDecoration(
                labelText: 'Enter QR Code String',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () {
                    final qrData = _qrInputController.text.trim();
                    if (qrData.isNotEmpty) {
                      fetchQRCode(qrData);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (qrCodeBase64 != null)
              Image.memory(base64Decode(qrCodeBase64!.split(',').last))
            else if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
