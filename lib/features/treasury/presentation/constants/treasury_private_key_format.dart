/// Client-side checks so users do not paste a public address as a private key.
library;

enum TreasuryImportPrivateKeyFormatIssue {
  tronAddressInsteadOfKey,
  evmAddressInsteadOfKey,
}

bool _looksLikeTronBase58Address(String s) {
  if (s.length < 33 || s.length > 36 || !s.startsWith('T')) return false;
  return RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(s);
}

bool _looksLikeEvmAddress(String s) {
  return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(s);
}

/// Returns an issue to show before calling the API, or null if format is not an obvious address mix-up.
TreasuryImportPrivateKeyFormatIssue? detectTreasuryImportPrivateKeyFormatIssue(
  String chain,
  String input,
) {
  final s = input.trim();
  if (s.isEmpty) return null;
  if (chain.startsWith('TRON_') && _looksLikeTronBase58Address(s)) {
    return TreasuryImportPrivateKeyFormatIssue.tronAddressInsteadOfKey;
  }
  if ((chain.startsWith('ETH_') || chain.startsWith('BSC_')) &&
      _looksLikeEvmAddress(s)) {
    return TreasuryImportPrivateKeyFormatIssue.evmAddressInsteadOfKey;
  }
  return null;
}
