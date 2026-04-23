import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Maps order API [code] values to localized copy.
/// Falls back to the server [message] when the code is unknown.
String localizeOrderApiError(
  AppLocalizations l10n, {
  required String? code,
  required String? message,
}) {
  final normalizedCode = code?.trim().toUpperCase();
  final fallbackMessage = message?.trim() ?? '';
  final isVietnamese = l10n.localeName.toLowerCase().startsWith('vi');

  String localized(String english, String vietnamese) {
    return isVietnamese ? vietnamese : english;
  }

  switch (normalizedCode) {
    case 'INSUFFICIENT_BALANCE':
      return l10n.insufficientBalance;
    case 'PAIR_NOT_FOUND':
      return localized(
          'Trading pair not found.', 'Không tìm thấy cặp giao dịch.');
    case 'ORDER_NOT_FOUND':
      return localized('Order not found.', 'Không tìm thấy lệnh.');
    case 'ORDER_NOT_OPEN':
      return localized('Order is not open.', 'Lệnh không còn ở trạng thái mở.');
    case 'INVALID_PRICE':
      return localized('Invalid price.', 'Giá không hợp lệ.');
    case 'INVALID_AMOUNT':
      return localized('Invalid amount.', 'Số lượng không hợp lệ.');
    case 'INVALID_INPUT':
      return localized('Invalid order input.', 'Dữ liệu lệnh không hợp lệ.');
    case 'INVALID_MARKET_BUY_RESERVE':
      return localized(
        'Invalid market buy reserve.',
        'Khoản dự trữ cho lệnh mua thị trường không hợp lệ.',
      );
    case 'NO_LIQUIDITY':
      return localized('Not enough liquidity.', 'Không đủ thanh khoản.');
    case 'ORDER_CREATE_FAILED':
      return localized('Could not create order.', 'Không thể tạo lệnh.');
    case 'INVALID_STATE':
      return localized('Order is in an invalid state.',
          'Lệnh đang ở trạng thái không hợp lệ.');
    case 'FORBIDDEN':
      return localized(
        'You are not allowed to perform this action.',
        'Bạn không có quyền thực hiện thao tác này.',
      );
    case 'OVERFILL_ATTEMPT':
      return localized('Order would be overfilled.',
          'Lệnh sẽ bị khớp vượt quá số lượng cho phép.');
    case 'WALLET_NOT_FOUND':
      return localized('Wallet not found.', 'Không tìm thấy ví.');
    default:
      return fallbackMessage.isNotEmpty
          ? fallbackMessage
          : l10n.apiErrorGeneric;
  }
}
