import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Maps a [ServerErrorCode] produced by Market Maker remote calls to a
/// localized message. Falls back to the server-provided message (or
/// localized `unknownError`) when the code is unknown.
String localizeMarketMakerError(
  AppLocalizations l10n,
  ServerErrorCode code, {
  String? serverMessage,
}) {
  if (code == ServerErrorCode.unknown) {
    return serverMessage?.isNotEmpty == true ? serverMessage! : l10n.unknownError;
  }
  switch (code) {
    case ServerErrorCode.loadMarketMakerDefaults:
      return serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.marketMakerErrorLoadDefaults;
    case ServerErrorCode.loadMarketMakerConfigs:
      return serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.marketMakerErrorLoadConfigs;
    case ServerErrorCode.saveMarketMakerConfig:
      return serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.marketMakerErrorSaveConfig;
    case ServerErrorCode.deleteMarketMakerConfig:
      return serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.marketMakerErrorDeleteConfig;
    case ServerErrorCode.placeMakerOrders:
      return serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.marketMakerErrorPlaceOrders;
    case ServerErrorCode.loadActivePairs:
      return serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.marketMakerErrorLoadActivePairs;
    case ServerErrorCode.unknown:
      return serverMessage?.isNotEmpty == true ? serverMessage! : l10n.unknownError;
  }
}