import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/models/prediction.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class AnalyzingScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const AnalyzingScreen({super.key, required this.imagePath});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  ScanStage _stage = ScanStage.decode;
  String? _qualityError;
  String? _fatalError;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _qualityError = null;
      _fatalError = null;
      _stage = ScanStage.decode;
    });
    try {
      final outcome = await ref
          .read(scanPipelineProvider)
          .run(widget.imagePath, onStage: (s) {
        if (mounted) setState(() => _stage = s);
      });
      ref.read(lastScanProvider.notifier).state = outcome;
      if (mounted) context.go('/result');
    } on ImageQualityException catch (_) {
      if (mounted) setState(() => _qualityError = 'quality');
    } catch (e) {
      if (mounted) setState(() => _fatalError = e.toString());
    }
  }

  double get _progress => switch (_stage) {
        ScanStage.decode => 0.15,
        ScanStage.quality => 0.35,
        ScanStage.preprocess => 0.55,
        ScanStage.inference => 0.8,
        ScanStage.mapping => 0.95,
        ScanStage.done => 1.0,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.analyzingTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(widget.imagePath),
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.image, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (_qualityError != null) ...[
              const Icon(Icons.blur_on, size: 48, color: AppColors.warning),
              const SizedBox(height: 12),
              Text(
                l.qualityFail,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/scan'),
                icon: const Icon(Icons.refresh),
                label: Text(l.retake),
              ),
            ] else if (_fatalError != null) ...[
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(
                _fatalError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _run,
                icon: const Icon(Icons.refresh),
                label: Text(l.retry),
              ),
            ] else ...[
              Text(
                l.analyzingBody,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedLinearProgressIndicator(
                  value: _progress,
                  color: AppColors.primary,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              _stageRow(l.stageDecode, ScanStage.decode),
              _stageRow(l.stageQuality, ScanStage.quality),
              _stageRow(l.stagePreprocess, ScanStage.preprocess),
              _stageRow(l.stageInference, ScanStage.inference),
              _stageRow(l.stageMapping, ScanStage.mapping),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stageRow(String label, ScanStage stage) {
    final reached = _progress >= _progressOf(stage);
    final active = _stage == stage;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (reached && !active)
            const Icon(Icons.check_circle, size: 18, color: AppColors.primary)
          else if (active)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.circle_outlined,
                size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: reached
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  double _progressOf(ScanStage s) => switch (s) {
        ScanStage.decode => 0.15,
        ScanStage.quality => 0.35,
        ScanStage.preprocess => 0.55,
        ScanStage.inference => 0.8,
        ScanStage.mapping => 0.95,
        ScanStage.done => 1.0,
      };
}

class AnimatedLinearProgressIndicator extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double minHeight;

  const AnimatedLinearProgressIndicator({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      child: LinearProgressIndicator(
        value: value,
        color: color,
        backgroundColor: backgroundColor,
        minHeight: minHeight,
      ),
    );
  }
}
