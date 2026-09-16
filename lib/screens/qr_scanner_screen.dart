import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';

/// QR Code scanner for indoor positioning.
///
/// Scans QR codes placed at building entrances and key locations.
/// Each QR code encodes a node ID that maps to a position in the node graph.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _lastError = 'Impossible d\'accéder à la caméra: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue == null) continue;

      final code = barcode.rawValue!;
      _processQrCode(code);
      break;
    }
  }

  void _processQrCode(String code) {
    setState(() => _isProcessing = true);

    // Parse the QR code format: "polymap:node:<nodeId>" or just a node ID
    String? nodeId;
    if (code.startsWith('polymap:node:')) {
      nodeId = code.substring('polymap:node:'.length);
    } else if (code.startsWith('PM-')) {
      // Legacy format: PM-BUILDING-FLOOR-ROOM (e.g., PM-GI-1-204)
      nodeId = code;
    }

    if (nodeId != null) {
      // Show success and return the node ID
      _showSuccess(nodeId);
    } else {
      // Unknown QR code format
      _showError('Code QR non reconnu');
    }
  }

  void _showSuccess(String nodeId) {
    // Parse node ID to get building info
    final parts = nodeId.split('-');
    final building = parts.isNotEmpty ? parts[0] : 'Inconnu';
    final room = parts.length > 2 ? parts.sublist(2).join('-') : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PositionConfirmedSheet(
        nodeId: nodeId,
        building: building,
        room: room,
        onConfirm: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(nodeId);
        },
        onCancel: () {
          setState(() => _isProcessing = false);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showError(String message) {
    setState(() {
      _lastError = message;
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_controller != null)
            MobileScanner(
              controller: _controller!,
              onDetect: _onDetect,
            )
          else
            Center(
              child: _lastError != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _lastError!,
                          style: PmText.sans(14, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : CircularProgressIndicator(color: pm.blue),
            ),

          // Dark gradient veil
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Viewfinder
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: pm.blue.withValues(alpha: 0.8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner brackets
                  Positioned(
                    top: -1,
                    left: -1,
                    child: _CornerBracket(color: pm.ochre, isTopLeft: true),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: _CornerBracket(color: pm.ochre, isTopLeft: false),
                  ),
                  Positioned(
                    bottom: -1,
                    left: -1,
                    child: _CornerBracket(color: pm.ochre, isTopLeft: false, isBottom: true),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: _CornerBracket(color: pm.ochre, isTopLeft: false, isBottom: true),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: pad.top + 60,
            left: 40,
            right: 40,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PmFixed.arBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner, color: pm.blue, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Scannez un QR code',
                    style: PmText.grotesk(16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pointez vers un QR code placé à l\'entrée d\'un bâtiment',
                    style: PmText.sans(12, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: pad.bottom + 40,
            left: 40,
            right: 40,
            child: Column(
              children: [
                // Manual entry button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pm.surf,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: pm.line),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement manual code entry
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saisie manuelle à implémenter'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard, color: pm.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Saisir le code manuellement',
                              style: PmText.label(color: pm.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: PmText.label(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: pm.surf,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: pm.blue),
                      const SizedBox(height: 16),
                      Text(
                        'Position détectée...',
                        style: PmText.label(color: pm.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Corner bracket for the viewfinder.
class _CornerBracket extends StatelessWidget {
  const _CornerBracket({
    required this.color,
    this.isTopLeft = true,
    this.isBottom = false,
  });

  final Color color;
  final bool isTopLeft;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _CornerBracketPainter(
        color: color,
        isTopLeft: isTopLeft,
        isBottom: isBottom,
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({
    required this.color,
    required this.isTopLeft,
    required this.isBottom,
  });

  final Color color;
  final bool isTopLeft;
  final bool isBottom;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTopLeft) {
      path.moveTo(0, size.height * 0.6);
      path.lineTo(0, 0);
      path.lineTo(size.width * 0.6, 0);
    } else if (isBottom) {
      path.moveTo(0, size.height * 0.4);
      path.lineTo(0, size.height);
      path.lineTo(size.width * 0.6, size.height);
    } else {
      path.moveTo(size.width * 0.4, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.6);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) => false;
}

/// Bottom sheet shown when position is confirmed.
class _PositionConfirmedSheet extends StatelessWidget {
  const _PositionConfirmedSheet({
    required this.nodeId,
    required this.building,
    required this.room,
    required this.onConfirm,
    required this.onCancel,
  });

  final String nodeId;
  final String building;
  final String room;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: pm.surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: pm.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Success icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: pm.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: pm.green, size: 40),
          ),

          const SizedBox(height: 16),

          Text(
            'Position détectée !',
            style: PmText.grotesk(20, color: pm.ink),
          ),

          const SizedBox(height: 8),

          Text(
            'Vous êtes à :',
            style: PmText.sans(14, color: pm.ink2),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pm.surf2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: pm.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      building,
                      style: PmText.mono(12, weight: FontWeight.w600, color: pm.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bâtiment $building',
                        style: PmText.label(color: pm.ink),
                      ),
                      if (room.isNotEmpty)
                        Text(
                          'Salle $room',
                          style: PmText.sans(12, color: pm.ink2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Annuler',
                    style: PmText.label(color: pm.ink2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pm.blue,
                    foregroundColor: pm.onBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirmer position',
                    style: PmText.label(color: pm.onBlue),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
