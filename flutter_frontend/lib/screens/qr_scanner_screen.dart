import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isRecycling;
  const QRScannerScreen({super.key, this.isRecycling = false});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanning = true;
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status == PermissionStatus.granted;
    });
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (!isScanning) return;
    final barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isScanning = false;
        });
        _handleScanResult(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _handleScanResult(String code) async {
    try {
      if (widget.isRecycling) {
        await _processRecycling(code);
      } else {
        await _scanProduct(code);
      }
    } catch (e) {
      _showErrorDialog('Scan Error', 'Failed to process scan: $e');
    }
  }

  Future<void> _scanProduct(String barcode) async {
    try {
      final result = await ApiService.scanProduct(barcode);
      if (mounted) {
        if (result['success']) {
          _showSuccessDialog(
            'Product Scanned',
            'Product: ${result['product']['name']}\nStatus: ${result['product']['currentStatus']}',
          );
        } else {
          _showErrorDialog('Scan Failed', result['message']);
        }
      }
    } catch (e) {
      _showErrorDialog('Network Error', 'Failed to scan product: $e');
    }
  }

  Future<void> _processRecycling(String productBarcode) async {
    const disposalMachineLocation = 'Machine_001_Location_A';
    final userQRData = '{"userId": "user_id_here", "timestamp": "${DateTime.now().toIso8601String()}"}';
    try {
      final result = await ApiService.processRecycling(
        productBarcode: productBarcode,
        userQRData: userQRData,
        disposalMachineLocation: disposalMachineLocation,
      );
      if (mounted) {
        if (result['success']) {
          _showSuccessDialog(
            'Recycling Complete!',
            'Congratulations! You\'ve successfully recycled the product.\nReward points have been added to your account.',
          );
        } else {
          _showErrorDialog('Recycling Failed', result['message']);
        }
      }
    } catch (e) {
      _showErrorDialog('Network Error', 'Failed to process recycling: $e');
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isScanning = true;
              });
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRecycling ? 'Recycle Product' : 'Scan Product'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: !hasPermission
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Camera Permission Required',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please grant camera permission to scan QR codes',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _requestCameraPermission,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: MobileScanner(
                    onDetect: _onDetect,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          widget.isRecycling
                              ? 'Point the camera at the product barcode to recycle'
                              : 'Point the camera at the QR code or barcode',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                MobileScannerController().toggleTorch();
                              },
                              icon: const Icon(Icons.flash_on),
                              tooltip: 'Toggle Flash',
                            ),
                            IconButton(
                              onPressed: () {
                                MobileScannerController().switchCamera();
                              },
                              icon: const Icon(Icons.flip_camera_ios),
                              tooltip: 'Flip Camera',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
