/// Matches synthetic emails from wallet login (e.g. `a1b2c3d4@eth_sepolia.wallet`).
bool isWalletPlaceholderEmail(String? email) {
  if (email == null) return false;
  return email.trim().toLowerCase().endsWith('.wallet');
}
