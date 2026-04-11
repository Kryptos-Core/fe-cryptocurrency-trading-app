/// One row from GET /treasury/chain-picker-options `networkCatalog`.
class ChainNetworkCatalogItemModel {
  const ChainNetworkCatalogItemModel({
    required this.code,
    required this.iconKey,
    required this.family,
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
      code: json['code'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? 'evm',
      family: json['family'] as String? ?? 'evm',
      isTestnet: json['isTestnet'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      deposit: cap('deposit'),
      withdraw: cap('withdraw'),
      linkWallet: cap('linkWallet'),
      phaseMessage: json['phaseMessage'] as String?,
    );
  }
}
