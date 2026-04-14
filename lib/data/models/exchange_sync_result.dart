/// Response body from POST /exchange/sync-info (NestJS ExchangeInfoSyncService).
class ExchangeSyncResult {
  final int currenciesCreated;
  final int currenciesSkipped;
  final int pairsCreated;
  final int pairsSkipped;
  final List<String> errors;

  const ExchangeSyncResult({
    required this.currenciesCreated,
    required this.currenciesSkipped,
    required this.pairsCreated,
    required this.pairsSkipped,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;

  factory ExchangeSyncResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ExchangeSyncResult(
        currenciesCreated: 0,
        currenciesSkipped: 0,
        pairsCreated: 0,
        pairsSkipped: 0,
        errors: [],
      );
    }
    final rawErrors = json['errors'];
    final List<String> errList = [];
    if (rawErrors is List) {
      for (final e in rawErrors) {
        if (e != null) errList.add(e.toString());
      }
    }
    return ExchangeSyncResult(
      currenciesCreated: _asInt(json['currenciesCreated']),
      currenciesSkipped: _asInt(json['currenciesSkipped']),
      pairsCreated: _asInt(json['pairsCreated']),
      pairsSkipped: _asInt(json['pairsSkipped']),
      errors: errList,
    );
  }

  static int _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
