import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../knowledge/disease_knowledge_base.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final outcome = ref.watch(lastScanProvider);
    if (outcome == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.resultTitle)),
        body: EmptyState(
          icon: Icons.biotech,
          title: l.noHistory,
          subtitle: l.noHistoryDesc,
        ),
      );
    }
    final p = outcome.prediction;
    final info = DiseaseKnowledgeBase.info(p.className);
    final healthy = p.isHealthy && !outcome.lowConfidence;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.resultTitle),
        actions: [
          AudioButton(
            text: healthy
                ? '${l.healthyLeaf}. ${info.about}'
                : '${l.diseaseDetected}. ${info.displayName}. '
                    '${l.confidenceValue((p.confidence * 100).toStringAsFixed(1))}. '
                    '${l.severity}: ${outcome.severity.severityLabel}. ${info.about}',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (outcome.lowConfidence)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.lowConfidence,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.warning)),
                        const SizedBox(height: 4),
                        Text(l.lowConfidenceBody,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: healthy ? AppColors.primary : AppColors.danger,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  healthy ? Icons.verified : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        healthy ? l.healthyLeaf : l.diseaseDetected,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        info.displayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                      ),
                      Text(
                        l.confidenceValue(
                            (p.confidence * 100).toStringAsFixed(1)),
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(outcome.imagePath),
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ConfidenceIndicator(value: p.confidence),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AgroCard(
            child: Column(
              children: [
                _row(l.affectedCrop, _capitalize(info.crop)),
                const Divider(height: 24),
                _row(l.estimatedAffectedArea,
                    '${outcome.severity.affectedAreaPercent.toStringAsFixed(1)}%'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.severity,
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    SeverityBadge(severity: outcome.severity.severityLabel),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.offline_pin,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l.detectedOnDevice,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AgroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.aboutDisease,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(info.about,
                    style: const TextStyle(
                        height: 1.5,
                        color: AppColors.textSecondary,
                        fontSize: 14)),
                if (info.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l.symptoms,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...info.symptoms.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  ',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800)),
                            Expanded(
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.push('/treatment'),
            icon: const Icon(Icons.medical_services),
            label: Text(l.viewTreatment),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go('/scan'),
            icon: const Icon(Icons.refresh),
            label: Text(l.retakePhoto),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
