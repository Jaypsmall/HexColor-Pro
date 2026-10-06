import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../color_manager.dart';
import '../theme/gold_theme.dart';

class CameraSniperWidget extends StatefulWidget {
  final ValueChanged<Color> onColorCaptured;
  final ValueChanged<Color> onColorConfirmed;
  final VoidCallback onClose;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const CameraSniperWidget({
    super.key,
    required this.onColorCaptured,
    required this.onColorConfirmed,
    required this.onClose,
    this.isFullscreen = false,
    required this.onToggleFullscreen,
  });

  @override
  State<CameraSniperWidget> createState() => _CameraSniperWidgetState();
}

class _CameraSniperWidgetState extends State<CameraSniperWidget> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  Color _liveColor = Colors.white;
  Offset _crosshairOffset = Offset.zero;
  bool _isFlashing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _isInitializing = false);
        return;
      }

      final backCam = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      if (!mounted) return;

      _controller!.startImageStream((CameraImage image) {
        _processCameraImage(image);
      });

      setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    if (image.planes.isEmpty) return;

    final width = image.width;
    final height = image.height;

    // Center pixel calculation from YUV420 format
    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];

    final centerX = (width / 2).round().clamp(0, width - 1);
    final centerY = (height / 2).round().clamp(0, height - 1);

    final yIndex = centerY * planeY.bytesPerRow + centerX;
    if (yIndex >= planeY.bytes.length) return;

    final y = planeY.bytes[yIndex] & 0xFF;

    final uvIndex = (centerY ~/ 2) * planeU.bytesPerRow + (centerX ~/ 2) * planeU.bytesPerPixel!;
    if (uvIndex >= planeU.bytes.length || uvIndex >= planeV.bytes.length) return;

    final u = (planeU.bytes[uvIndex] & 0xFF) - 128;
    final v = (planeV.bytes[uvIndex] & 0xFF) - 128;

    // YUV to RGB Conversion
    int r = (y + 1.402 * v).round().clamp(0, 255);
    int g = (y - 0.344136 * u - 0.714136 * v).round().clamp(0, 255);
    int b = (y + 1.772 * u).round().clamp(0, 255);

    final color = Color.fromRGBO(r, g, b, 1.0);

    if (mounted) {
      setState(() {
        _liveColor = color;
      });
      widget.onColorCaptured(color);
    }
  }

  void _triggerCapture() async {
    setState(() => _isFlashing = true);
    widget.onColorConfirmed(_liveColor);
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      setState(() => _isFlashing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(color: GoldTheme.goldMid),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            const Text(
              "Cámara no disponible",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(backgroundColor: GoldTheme.goldMid),
              child: const Text("CERRAR", style: TextStyle(color: GoldTheme.goldText)),
            )
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.isFullscreen ? 0 : 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: widget.isFullscreen ? null : Border.all(color: GoldTheme.goldMid, width: 1.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            CameraPreview(_controller!),

            // Reticle / Crosshair Overlay
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _crosshairOffset += details.delta;
                });
              },
              onTap: _triggerCapture,
              child: CustomPaint(
                painter: _CrosshairPainter(offset: _crosshairOffset, color: _liveColor),
              ),
            ),

            // Flash effect
            if (_isFlashing)
              Container(color: Colors.white.withOpacity(0.85)),

            // Top Toolbar Controls
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GoldTheme.goldMid, width: 1),
                    ),
                    child: Text(
                      widget.isFullscreen ? "SNIPER FULLSCREEN" : "SNIPER WINDOWED",
                      style: const TextStyle(
                        color: GoldTheme.goldLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(
                        widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: widget.onToggleFullscreen,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Info Bar & Confirm Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GoldTheme.goldMid, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _liveColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ColorManager.colorToHex(_liveColor),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            "RGB: (${(_liveColor.red * 255).round()}, ${(_liveColor.green * 255).round()}, ${(_liveColor.blue * 255).round()})",
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _triggerCapture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GoldTheme.goldMid,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.check, color: GoldTheme.goldText, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  final Offset offset;
  final Color color;

  _CrosshairPainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + offset.dx, size.height / 2 + offset.dy);

    final whiteLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 16.0, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5);
    canvas.drawLine(Offset(center.dx - 28, center.dy), Offset(center.dx + 28, center.dy), whiteLinePaint);
    canvas.drawLine(Offset(center.dx, center.dy - 28), Offset(center.dx, center.dy + 28), whiteLinePaint);

    // Inner active color indicator dot
    canvas.drawCircle(center, 5.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.color != color;
  }
}
