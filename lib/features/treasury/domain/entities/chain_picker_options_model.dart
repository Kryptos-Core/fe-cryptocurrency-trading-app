import 'package:crypto_trading_app/features/treasury/domain/entities/chain_network_catalog_item_model.dart';

/// One chain entry from a picker array in GET /treasury/chain-picker-options.
class ChainPickerItemModel {
  const ChainPickerItemModel({
    required this.code,
    required this.blockchainLabel,
  });

  final String code;
  final String blockchainLabel;

  factory ChainPickerItemModel.fromJson(Map<String, dynamic> json) {
    return ChainPickerItemModel(
      code: json['code']?.toString() ?? '',
      blockchainLabel: json['blockchainLabel']?.toString() ?? '',
    );
  }
}

/// Response from GET /treasury/chain-picker-options (server-driven chain dropdowns).
class ChainPickerOptionsModel {
  ChainPickerOptionsModel({
    required this.operatorMode,
    required this.tronDefaultNetwork,
    required this.pickers,
    this.networkCatalog,
    this.showNetworkSelector = true,
  });

  final String operatorMode;
  final String tronDefaultNetwork;
  final Map<String, List<ChainPickerItemModel>> pickers;
  final List<ChainNetworkCatalogItemModel>? networkCatalog;
  /// Whether the UI should show chain/network selectors (two-dropdown UX).
  /// Server returns `false` in production — network is implicit mainnet.
  final bool showNetworkSelector;

  List<String> get treasuryOps =>
      pickers['treasury_ops']?.map((i) => i.code).toList() ?? const [];

  List<String> get treasuryMainWallet =>
      pickers['treasury_main_wallet']?.map((i) => i.code).toList() ?? const [];

  List<String> get treasuryHistoryFilter =>
      pickers['treasury_history_filter']?.map((i) => i.code).toList() ?? const [];

  List<String> get withdrawalAdminFilter =>
      pickers['withdrawal_admin_filter']?.map((i) => i.code).toList() ?? const [];

  List<String> get managedWallets =>
      pickers['managed_wallets']?.map((i) => i.code).toList() ?? const [];

  List<String> get onchainDepositWithdraw =>
      pickers['onchain_deposit_withdraw']?.map((i) => i.code).toList() ?? const [];

  List<String> get treasuryE2e =>
      pickers['treasury_e2e']?.map((i) => i.code).toList() ?? const [];

  /// Map of chain code → blockchain label from API.
  /// Used as single source of truth for chain display names in dropdowns.
  Map<String, String> get chainLabels {
    final map = <String, String>{};
    for (final items in pickers.values) {
      for (final item in items) {
        if (item.blockchainLabel.isNotEmpty) {
          map[item.code] = item.blockchainLabel;
        }
      }
    }
    return map;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'operatorMode': operatorMode,
        'tronDefaultNetwork': tronDefaultNetwork,
        'showNetworkSelector': showNetworkSelector,
        'pickers': pickers.map(
          (key, value) => MapEntry(
            key,
            value.map((i) => {'code': i.code, 'blockchainLabel': i.blockchainLabel}).toList(),
          ),
        ),
      };

  factory ChainPickerOptionsModel.fromJson(Map<String, dynamic> json) {
    final pickersRaw = json['pickers'];
    final Map<String, List<ChainPickerItemModel>> pickers = {};
    if (pickersRaw is Map) {
      pickersRaw.forEach((key, value) {
        if (value is List) {
          pickers[key.toString()] = value
              .whereType<Map>()
              .map(
                (e) => ChainPickerItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(growable: false);
        }
      });
    }
    List<ChainNetworkCatalogItemModel>? catalog;
    final catRaw = json['networkCatalog'];
    if (catRaw is List) {
      catalog = catRaw
          .whereType<Map>()
          .map(
            (e) => ChainNetworkCatalogItemModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(growable: false);
    }
    return ChainPickerOptionsModel(
      operatorMode: json['operatorMode'] as String? ?? 'sandbox',
      tronDefaultNetwork: json['tronDefaultNetwork'] as String? ?? 'TRON_NILE',
      showNetworkSelector: json['showNetworkSelector'] as bool? ?? true,
      pickers: pickers,
      networkCatalog: catalog,
    );
  }
}
