import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../data/models/treatment_info.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class TreatmentScreen extends ConsumerWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final outcome = ref.watch(lastScanProvider);
    if (outcome == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.treatmentTitle)),
        body: EmptyState(
            icon: Icons.medical_services,
            title: l.noHistory,
            subtitle: l.noHistoryDesc),
      );
    }
    final treatment = ref
        .read(recommendationRepositoryProvider)
        .treatmentFor(outcome.prediction.className);
    final info = ref
        .read(recommendationRepositoryProvider)
        .diseaseInfoFor(outcome.prediction.className);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.treatmentTitle),
        actions: [
          AudioButton(
            text: '${l.recommendedTreatment}. ${treatment.actions.join('. ')}',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services,
                    color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.recommendedTreatment,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text(l.treatmentIntro,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13)),
                      Text('${info.displayName} - ${info.crop}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!treatment.hasVerifiedInfo)
            AgroCard(
              color: AppColors.warningLight,
              child: Text(l.noTreatmentInfo,
                  style: const TextStyle(color: AppColors.warning)),
            )
          else ...[
            // Verified product recommendations (if available)
            if (treatment.hasVerifiedProducts) ...[
              _productCard(treatment),
              const SizedBox(height: 12),
            ],
            AgroCard(
              child: _list(l.recommendedTreatment, Icons.task_alt,
                  treatment.actions),
            ),
            const SizedBox(height: 12),
            AgroCard(
              child: _list(l.preventiveSteps, Icons.shield,
                  treatment.preventive),
            ),
            const SizedBox(height: 12),
            AgroCard(
              child: _list(l.organicAlternatives, Icons.eco,
                  treatment.organic),
            ),
            // Source citation
            if (treatment.source != null) ...[
              const SizedBox(height: 12),
              _sourceCard(treatment.source!),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.gpp_maybe,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.generalGuidance,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.savedToPlan)),
              );
              context.go('/home');
            },
            icon: const Icon(Icons.save),
            label: Text(l.saveToPlan),
          ),
        ],
      ),
    );
  }

  Widget _productCard(TreatmentInfo treatment) {
    return AgroCard(
      color: AppColors.successLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Verified Product Recommendation',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          for (final p in treatment.products!) ...[
            _productRow('Product', p.name),
            _productRow('Active Ingredient', p.activeIngredient),
            _productRow('Dose', p.dose),
            _productRow('Timing', p.timing),
            if (treatment.products!.indexOf(p) <
                treatment.products!.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }

  Widget _productRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _sourceCard(String source) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Verified Source',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 2),
                Text(source,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                            height: 1.45,
                            color: AppColors.textSecondary)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
