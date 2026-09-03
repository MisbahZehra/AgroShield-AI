import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../data/models/crop.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class CropsScreen extends ConsumerWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final crops = ref.watch(cropsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.cropsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: () => _showAddDialog(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 4),
                  Text(l.addCrop, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: crops.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.spa,
              title: l.noCrops,
              subtitle: l.noCropsDesc,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _CropCard(
              crop: list[i],
              onDelete: () async {
                await ref.read(cropRepositoryProvider).remove(list[i].id!);
                ref.invalidate(cropsProvider);
              },
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(message: e.toString()),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final types = ['wheat', 'rice', 'cotton', 'corn', 'sugarcane', 'tomato'];
    String type = types.first;
    String stage = 'Vegetative';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l.addCrop),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: l.cropName),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: l.selectCropType),
                items: [
                  for (final t in types)
                    DropdownMenuItem(value: t, child: Text(t))
                ],
                onChanged: (v) => setState(() => type = v ?? type),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: stage,
                decoration: InputDecoration(labelText: l.growthStage),
                items: [
                  for (final s in [
                    'Vegetative',
                    'Tillering',
                    'Flowering',
                    'Panicle',
                    'Mature'
                  ])
                    DropdownMenuItem(value: s, child: Text(s))
                ],
                onChanged: (v) => setState(() => stage = v ?? stage),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                await ref.read(cropRepositoryProvider).add(Crop(
                      name: name,
                      type: type,
                      growthStage: stage,
                      healthPercent: 100,
                      status: 'good',
                    ));
                ref.invalidate(cropsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback onDelete;

  const _CropCard({required this.crop, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final statusText = switch (crop.status) {
      'good' => l.statusGood,
      'moderate' => l.statusModerate,
      _ => l.statusAtRisk,
    };
    final statusColor = switch (crop.status) {
      'good' => AppColors.primary,
      'moderate' => AppColors.warning,
      _ => AppColors.danger,
    };
    return AgroCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _thumbFor(crop.type),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${l.growthStage}: ${crop.growthStage}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('${l.status}: ',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                    Text(statusText,
                        style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          HealthRing(percent: crop.healthPercent, status: crop.status),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.textSecondary,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _thumbFor(String type) {
    const assets = {
      'wheat': 'assets/images/crop_wheat.png',
      'rice': 'assets/images/crop_rice.png',
      'cotton': 'assets/images/crop_cotton.png',
      'corn': 'assets/images/crop_corn.png',
    };
    final asset = assets[type];
    if (asset != null) {
      return Image.asset(asset,
          width: 56, height: 56, fit: BoxFit.cover);
    }
    return Container(
      width: 56,
      height: 56,
      color: AppColors.primaryLight,
      child: Icon(_iconFor(type), color: AppColors.primary, size: 30),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'wheat' => Icons.grass,
        'rice' => Icons.water_drop,
        'cotton' => Icons.filter_vintage,
        'corn' => Icons.eco,
        'sugarcane' => Icons.height,
        'tomato' => Icons.brightness_1,
        _ => Icons.spa,
      };
}
