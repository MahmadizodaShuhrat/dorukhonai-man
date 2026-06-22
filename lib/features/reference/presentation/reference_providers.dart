import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../data/reference_repository.dart';

/// A lightweight id+label option for the [EntityPicker]. Keeps the picker
/// generic while repositories return their domain models.
class EntityOption {
  const EntityOption({required this.id, required this.label, this.sublabel});

  final String id;
  final String label;

  /// Optional secondary line (e.g. manufacturer country, supplier phone).
  final String? sublabel;
}

/// Loads drug-group options. `arg` is the search term (`''` for the full list).
final drugGroupOptionsProvider =
    FutureProvider.family<List<EntityOption>, String>((ref, search) async {
      final repo = ref.watch(referenceRepositoryProvider);
      final result = await repo.drugGroups(search: search);
      return switch (result) {
        Success(:final data) => [
          for (final g in data.items) EntityOption(id: g.id, label: g.name),
        ],
        Error(:final failure) => throw failure,
      };
    });

/// Loads manufacturer options.
final manufacturerOptionsProvider =
    FutureProvider.family<List<EntityOption>, String>((ref, search) async {
      final repo = ref.watch(referenceRepositoryProvider);
      final result = await repo.manufacturers(search: search);
      return switch (result) {
        Success(:final data) => [
          for (final m in data.items)
            EntityOption(id: m.id, label: m.name, sublabel: m.country),
        ],
        Error(:final failure) => throw failure,
      };
    });

/// Loads unit options.
final unitOptionsProvider =
    FutureProvider.family<List<EntityOption>, String>((ref, search) async {
      final repo = ref.watch(referenceRepositoryProvider);
      final result = await repo.units(search: search);
      return switch (result) {
        Success(:final data) => [
          for (final u in data.items) EntityOption(id: u.id, label: u.name),
        ],
        Error(:final failure) => throw failure,
      };
    });

/// Loads supplier options.
final supplierOptionsProvider =
    FutureProvider.family<List<EntityOption>, String>((ref, search) async {
      final repo = ref.watch(referenceRepositoryProvider);
      final result = await repo.suppliers(search: search);
      return switch (result) {
        Success(:final data) => [
          for (final s in data.items)
            EntityOption(id: s.id, label: s.name, sublabel: s.phone),
        ],
        Error(:final failure) => throw failure,
      };
    });

/// Resolves a single option's display label by id (for showing the current
/// selection when a form opens in edit mode). Returns `null` when not found.
EntityOption? findOptionById(List<EntityOption> options, String? id) {
  if (id == null || id.isEmpty) return null;
  for (final o in options) {
    if (o.id == id) return o;
  }
  return null;
}
