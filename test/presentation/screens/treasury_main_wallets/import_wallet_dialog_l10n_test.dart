import 'package:crypto_trading_app/gen_l10n/app_localizations_en.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations_vi.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke check that new import-dialog strings are present (arb → codegen).
void main() {
  test('EN import wallet dialog heading and chain label', () {
    final en = AppLocalizationsEn();
    expect(en.treasuryImportWalletDialogHeading, isNotEmpty);
    expect(en.treasuryImportWalletDialogChainLabel, isNotEmpty);
    expect(en.treasuryImportWalletOtpVerifiedBanner, isNotEmpty);
  });

  test('VI import wallet dialog heading and chain label', () {
    final vi = AppLocalizationsVi();
    expect(vi.treasuryImportWalletDialogHeading, isNotEmpty);
    expect(vi.treasuryImportWalletDialogChainLabel, isNotEmpty);
    expect(vi.treasuryImportWalletOtpVerifiedBanner, isNotEmpty);
  });
}
