class DepositMethod {
  final String chain;
  final String label;
  final String? depositAddress;
  final bool isRecommended;
  final bool depositEnabled;
  final int minConfirmations;
  final String estimatedTime;

  const DepositMethod({
    required this.chain,
    required this.label,
    this.depositAddress,
    required this.isRecommended,
    required this.depositEnabled,
    required this.minConfirmations,
    required this.estimatedTime,
  });

  bool get hasAddress => depositAddress != null && depositAddress!.isNotEmpty;

  String get truncatedAddress {
    final addr = depositAddress ?? '';
    if (addr.length <= 14) return addr;
    return '${addr.substring(0, 8)}...${addr.substring(addr.length - 6)}';
  }
}

class DepositMethodsResponse {
  final String? recommendedChain;
  final List<DepositMethod> methods;

  const DepositMethodsResponse({
    this.recommendedChain,
    required this.methods,
  });
}
