import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class FarmInformationScreen extends ConsumerStatefulWidget {
  const FarmInformationScreen({super.key});

  @override
  ConsumerState<FarmInformationScreen> createState() =>
      _FarmInformationScreenState();
}

class _FarmInformationScreenState extends ConsumerState<FarmInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _soilCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _irrigation = 'Drip';
  String _farmingType = 'Smallholder';
  List<String> _crops = [];

  static const _irrigationTypes = [
    'Drip', 'Flood', 'Sprinkler', 'Rain-fed', 'Canal',
  ];
  static const _farmingTypes = [
    'Smallholder', 'Commercial', 'Subsistence', 'Mixed',
  ];
  static const _cropOptions = [
    'Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize', 'Vegetables',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(settingsRepositoryProvider);
    final data = await repo.farmInfo();
    if (data != null && mounted) {
      _locationCtrl.text = data['location'] ?? '';
      _provinceCtrl.text = data['province'] ?? '';
      _sizeCtrl.text = data['size'] ?? '';
      _soilCtrl.text = data['soil'] ?? '';
      _notesCtrl.text = data['notes'] ?? '';
      _irrigation = data['irrigation'] ?? 'Drip';
      _farmingType = data['farmingType'] ?? 'Smallholder';
      final cropsStr = data['crops'] ?? '';
      _crops = cropsStr.isEmpty ? [] : cropsStr.split(',');
      setState(() {});
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _provinceCtrl.dispose();
    _sizeCtrl.dispose();
    _soilCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveFarmInfo({
      'location': _locationCtrl.text.trim(),
      'province': _provinceCtrl.text.trim(),
      'size': _sizeCtrl.text.trim(),
      'soil': _soilCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'irrigation': _irrigation,
      'farmingType': _farmingType,
      'crops': _crops.join(','),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm information saved'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.farmInformation),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AgroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.farmDetails,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _field(l.farmLocation, _locationCtrl,
                      hint: 'e.g. Hyderabad, Sindh'),
                  const SizedBox(height: 12),
                  _field(l.province, _provinceCtrl,
                      hint: 'e.g. Sindh'),
                  const SizedBox(height: 12),
                  _field(l.farmSize, _sizeCtrl,
                      hint: 'e.g. 5 acres'),
                  const SizedBox(height: 12),
                  _field(l.soilType, _soilCtrl,
                      hint: 'e.g. Loamy'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AgroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.irrigationType,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _irrigationTypes.map((t) {
                      final selected = _irrigation == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _irrigation = t),
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AgroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.farmingType,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _farmingTypes.map((t) {
                      final selected = _farmingType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _farmingType = t),
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AgroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.primaryCrops,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _cropOptions.map((c) {
                      final selected = _crops.contains(c);
                      return FilterChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _crops.add(c);
                            } else {
                              _crops.remove(c);
                            }
                          });
                        },
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AgroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.notes,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l.farmNotesHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
