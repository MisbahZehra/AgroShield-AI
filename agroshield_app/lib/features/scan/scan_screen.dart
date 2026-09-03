import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _controller;
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _initializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final file = await controller.takePicture();
      if (mounted) context.push('/analyzing', extra: file.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).error),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 95);
    if (picked != null && mounted) {
      // copy to app cache so the path stays stable for history
      final dest =
          '${Directory.systemTemp.path}/agroshield_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(picked.path).copy(dest);
      if (mounted) context.push('/analyzing', extra: dest);
    }
  }

  Future<void> _useSample(String asset) async {
    final data = await rootBundle.load(asset);
    final dest =
        '${Directory.systemTemp.path}/agroshield_sample_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(dest).writeAsBytes(data.buffer.asUint8List());
    if (mounted) context.push('/analyzing', extra: dest);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l.scanTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt),
            onPressed: () {},
          ),
        ],
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.no_photography,
                            size: 56, color: Colors.white70),
                        const SizedBox(height: 16),
                        Text(
                          l.cameraDenied,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: Text(l.gallery),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.eco, size: 16),
                            label: const Text('Sample: Wheat Rust',
                                style: TextStyle(fontSize: 11)),
                            onPressed: () => _useSample(
                                'assets/images/sample_wheat_rust.png'),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.spa, size: 16),
                            label: const Text('Sample: Healthy Leaf',
                                style: TextStyle(fontSize: 11)),
                            onPressed: () => _useSample(
                                'assets/images/sample_tomato_healthy.png'),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CustomPaint(
                          painter: _CornerPainter(),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      right: 32,
                      bottom: 150,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l.placeLeaf,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _sideAction(Icons.photo_library, l.gallery,
                              _pickFromGallery),
                          GestureDetector(
                            onTap: _capture,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _sideAction(Icons.tips_and_updates, l.tips,
                              () => _showTips(context)),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _sideAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _showTips(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.tips_and_updates, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(l.tips),
          ],
        ),
        content: Text(l.tipsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 36.0;
    final w = size.width;
    final h = size.height;
    // top-left
    canvas.drawPath(
        Path()
          ..moveTo(0, len)
          ..lineTo(0, 0)
          ..lineTo(len, 0),
        paint);
    // top-right
    canvas.drawPath(
        Path()
          ..moveTo(w - len, 0)
          ..lineTo(w, 0)
          ..lineTo(w, len),
        paint);
    // bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(0, h - len)
          ..lineTo(0, h)
          ..lineTo(len, h),
        paint);
    // bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(w - len, h)
          ..lineTo(w, h)
          ..lineTo(w, h - len),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
