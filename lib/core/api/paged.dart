/// Generic paginated list envelope used by ALL list endpoints (API contract):
/// `{ "items": [ ... ], "total": int, "page": int, "size": int }`.
///
/// Hand-written (no codegen) to stay analyzer-clean. The element type [T] is
/// decoded by the caller-supplied [fromJsonT].
class Paged<T> {
  const Paged({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  final List<T> items;
  final int total;
  final int page;
  final int size;

  /// Whether more pages exist after the current one.
  bool get hasMore => page * size < total;

  factory Paged.empty({int page = 1, int size = 20}) =>
      Paged<T>(items: const [], total: 0, page: page, size: size);

  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final rawItems = (json['items'] as List<dynamic>?) ?? const [];
    return Paged<T>(
      items: rawItems
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(growable: false),
      total: (json['total'] as num?)?.toInt() ?? rawItems.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? rawItems.length,
    );
  }
}
