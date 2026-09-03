import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../knowledge/disease_knowledge_base.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'all';
  String _query = '';

  static const _filters = ['all', 'wheat', 'rice', 'cotton', 'corn', 'tomato'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: l.searchHistory,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final f in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f == 'all'
                          ? l.all
                          : f[0].toUpperCase() + f.substring(1)),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _filter == f ? Colors.white : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: history.when(
              data: (records) {
                final filtered = records.where((r) {
                  final matchesFilter =
                      _filter == 'all' || r.crop == _filter;
                  final matchesQuery = _query.isEmpty ||
                      r.disease.toLowerCase().contains(_query) ||
                      r.crop.toLowerCase().contains(_query);
                  return matchesFilter && matchesQuery;
                }).toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.history,
                    title: l.noHistory,
                    subtitle: l.noHistoryDesc,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    return AgroCard(
                      onTap: () => context.push('/history/${r.id}'),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(r.imagePath),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.eco,
                                    color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DiseaseKnowledgeBase.displayName(
                                      r.disease),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(r.timestamp))} • ${(r.confidence * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          SeverityBadge(severity: r.severity),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (e, s) => ErrorView(message: e.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
