import 'package:crypto_trading_app/features/treasury/domain/entities/chain_network_catalog_item_model.dart';

/// Response from GET /treasury/chain-picker-options (server-driven chain dropdowns).
class ChainPickerOptionsModel {
  ChainPickerOptionsModel({
    required this.operatorMode,
    required this.tronDefaultNetwork,
    required this.pickers,
    this.networkCatalog,
  });

  final String operatorMode;
  final String tronDefaultNetwork;
  final Map<String, List<String>> pickers;
  final List<ChainNetworkCatalogItemModel>? networkCatalog;

  List<String> get treasuryOps => pickers['treasury_ops'] ?? const [];
  List<String> get treasuryMainWallet => pickers['treasury_main_wallet'] ?? const [];
  List<String> get treasuryHistoryFilter => pickers['treasury_history_filter'] ?? const [];
  List<String> get withdrawalAdminFilter => pickers['withdrawal_admin_filter'] ?? const [];
  List<String> get managedWallets => pickers['managed_wallets'] ?? const [];
  List<String> get onchainDepositWithdraw => pickers['onchain_deposit_withdraw'] ?? const [];
  List<String> get treasuryE2e => pickers['treasury_e2e'] ?? const [];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'operatorMode': operatorMode,
        'tronDefaultNetwork': tronDefaultNetwork,
        'pickers': pickers,
      };

  factory ChainPickerOptionsModel.fromJson(Map<String, dynamic> json) {
    final pickersRaw = json['pickers'];
    final Map<String, List<String>> pickers = {};
    if (pickersRaw is Map) {
      pickersRaw.forEach((key, value) {
        if (value is List) {
          pickers[key.toString()] =
              value.map((e) => e.toString()).toList(growable: false);
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
      pickers: pickers,
      networkCatalog: catalog,
    );
  }
}
