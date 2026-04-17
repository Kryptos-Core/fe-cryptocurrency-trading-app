/// Builds the string encoded inside deposit QR codes so wallet apps treat it as a
/// chain-native receive target (not arbitrary text). The **on-chain address** is unchanged;
/// this only adds standard URI prefixes where helpful for scanners (TronLink, EVM wallets, …).
///
/// Copy-to-clipboard should still use the raw platform address from the API.
String buildOnchainDepositQrPayload({
  required String chainApiCode,
  required String rawAddress,
}) {
  final address = rawAddress.trim();
  if (address.isEmpty) return address;

  final upper = chainApiCode.toUpperCase();

  if (upper.startsWith('TRON_')) {
    return 'tron:$address';
  }

  if (upper.startsWith('SOLANA_')) {
    return 'solana:$address';
  }

  if (_isEvmLikeChainApiCode(upper)) {
    final hex = address.startsWith('0x') || address.startsWith('0X')
        ? address
        : '0x$address';
    return 'ethereum:$hex';
  }

  return address;
}

bool _isEvmLikeChainApiCode(String upper) {
  const prefixes = <String>[
    'ETH_',
    'BSC_',
    'BASE_',
    'ARBITRUM_',
    'OPTIMISM_',
    'POLYGON_',
    'AVALANCHE_',
    'GNOSIS_',
    'LINEA_',
    'FANTOM_',
  ];
  for (final p in prefixes) {
    if (upper.startsWith(p)) return true;
  }
  return false;
}
