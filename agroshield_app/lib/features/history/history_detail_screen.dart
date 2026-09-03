import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../knowledge/disease_knowledge_base.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final int id;

  const HistoryDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final record = ref.watch(historyProvider).valueOrNull
        ?.where((r) => r.id == id)
        .toList();
    final r = record != null && record.isNotEmpty ? record.first : null;
    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.historyTitle)),
        body: ErrorView(message: l.noHistory),
      );
    }
    final info = DiseaseKnowledgeBase.info(r.disease);
    return Scaffold(
      appBar: AppBar(
        title: Text(info.displayName),
        actions: [
          AudioButton(
            text:
                '${info.displayName}. ${l.confidenceValue((r.confidence * 100).toStringAsFixed(1))}. '
                '${l.severity}: ${r.severity}. ${info.about}',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(r.imagePath),
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: AppColors.primaryLight,
                child: const Icon(Icons.eco, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AgroCard(
            child: Column(
              children: [
                _row(l.affectedCrop, info.crop),
                const Divider(height: 24),
                _row(l.confidence,
                    '${(r.confidence * 100).toStringAsFixed(1)}%'),
                const Divider(height: 24),
                _row(l.estimatedAffectedArea,
                    '${r.affectedArea.toStringAsFixed(1)}%'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.severity,
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    SeverityBadge(severity: r.severity),
                  ],
                ),
                const Divider(height: 24),
                _row(
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(DateTime.fromMillisecondsSinceEpoch(r.timestamp)),
                    r.risk),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AgroCard(
            child: Text(info.about,
                style: const TextStyle(
                    height: 1.5,
                    color: AppColors.textSecondary,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
