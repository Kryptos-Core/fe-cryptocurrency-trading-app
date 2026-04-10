import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';

/// Resolves which API chain code to show in the deposit methods header chip.
///
/// When the server still returns `TRON_MAINNET` for [deposit.recommended_chain] but
/// the active on-chain picker list (sandbox) does not include mainnet, map to the
/// same effective Tron row as the backend (`tronDefaultNetwork`).
String? resolveDepositMethodsHeaderRecommendedChain({
  required String? apiRecommended,
  required List<String> onchainDepositWithdrawCodes,
  String? tronDefaultFromPickerApi,
}) {
  if (apiRecommended == null || apiRecommended.isEmpty) return null;
  final codes = onchainDepositWithdrawCodes;
  if (codes.contains(apiRecommended)) return apiRecommended;
  final tron = (tronDefaultFromPickerApi != null &&
          tronDefaultFromPickerApi.trim().isNotEmpty)
      ? tronDefaultFromPickerApi.trim()
      : treasurySandboxDefaultTronChain();
  if (codes.contains(tron)) return tron;
  if (codes.isNotEmpty) return codes.first;
  return apiRecommended;
}
