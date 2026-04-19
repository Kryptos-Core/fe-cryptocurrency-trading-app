import 'package:crypto_trading_app/core/utils/json_dynamic_parse.dart';

/// One row from GET /treasury/chain-picker-options `networkCatalog`.
class ChainNetworkCatalogItemModel {
  const ChainNetworkCatalogItemModel({
    required this.code,
    required this.iconKey,
    required this.family,
    required this.blockchainKey,
    required this.blockchainLabel,
    required this.networkLabel,
    required this.isTestnet,
    required this.sortOrder,
    required this.deposit,
    required this.withdraw,
    required this.linkWallet,
    this.phaseMessage,
  });

  final String code;
  final String iconKey;
  final String family;
  final String blockchainKey;
  final String blockchainLabel;
  final String networkLabel;
  final bool isTestnet;
  final int sortOrder;
  final bool deposit;
  final bool withdraw;
  final bool linkWallet;
  final String? phaseMessage;

  factory ChainNetworkCatalogItemModel.fromJson(Map<String, dynamic> json) {
    final caps = json['capabilities'];
    bool cap(String k) =>
        caps is Map && (caps[k] == true || caps[k] == 'true');

    return ChainNetworkCatalogItemModel(
      code: json['code']?.toString() ?? '',
      iconKey: json['iconKey']?.toString() ?? 'evm',
      family: json['family']?.toString() ?? 'evm',
      blockchainKey: json['blockchainKey']?.toString() ?? json['iconKey']?.toString() ?? json['family']?.toString() ?? 'evm',
      blockchainLabel: json['blockchainLabel']?.toString() ?? '',
      networkLabel: json['networkLabel']?.toString() ?? '',
      isTestnet: parseJsonBool(json['isTestnet'], false),
      sortOrder: parseJsonInt(json['sortOrder'], 0),
      deposit: cap('deposit'),
      withdraw: cap('withdraw'),
      linkWallet: cap('linkWallet'),
      phaseMessage: json['phaseMessage'] as String?,
    );
  }
}

