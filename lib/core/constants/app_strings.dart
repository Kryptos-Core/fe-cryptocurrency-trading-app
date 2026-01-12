/// Application-wide String Constants
/// Following Single Responsibility Principle (SRP)
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Crypto Trading App';
  static const String appVersion = '1.0.0';

  // Auth Related
  static const String login = 'Đăng nhập';
  static const String register = 'Đăng ký';
  static const String logout = 'Đăng xuất';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String twoFactorAuth = 'Xác thực 2 yếu tố';

  // Trading Related
  static const String buy = 'Mua';
  static const String sell = 'Bán';
  static const String market = 'Thị trường';
  static const String limit = 'Giới hạn';
  static const String price = 'Giá';
  static const String amount = 'Số lượng';
  static const String total = 'Tổng';
  static const String available = 'Khả dụng';
  static const String frozen = 'Đóng băng';

  // Wallet Related
  static const String wallet = 'Ví';
  static const String deposit = 'Nạp tiền';
  static const String withdraw = 'Rút tiền';
  static const String balance = 'Số dư';
  static const String transaction = 'Giao dịch';
  static const String transactionHistory = 'Lịch sử giao dịch';

  // Market Related
  static const String marketPairs = 'Cặp giao dịch';
  static const String orderBook = 'Sổ lệnh';
  static const String recentTrades = 'Giao dịch gần đây';
  static const String chart = 'Biểu đồ';
  static const String volume = 'Khối lượng';
  static const String change24h = 'Thay đổi 24h';
  static const String high24h = 'Cao nhất 24h';
  static const String low24h = 'Thấp nhất 24h';

  // Alert Related
  static const String priceAlert = 'Cảnh báo giá';
  static const String createAlert = 'Tạo cảnh báo';
  static const String deleteAlert = 'Xóa cảnh báo';
  static const String alertTriggered = 'Cảnh báo đã kích hoạt';

  // Error Messages
  static const String errorGeneric = 'Đã có lỗi xảy ra';
  static const String errorNetwork = 'Lỗi kết nối mạng';
  static const String errorServer = 'Lỗi máy chủ';
  static const String errorAuth = 'Lỗi xác thực';
  static const String errorInvalidInput = 'Dữ liệu không hợp lệ';
  static const String errorInsufficientBalance = 'Số dư không đủ';
  static const String errorOrderNotFound = 'Không tìm thấy lệnh';

  // Success Messages
  static const String successLogin = 'Đăng nhập thành công';
  static const String successRegister = 'Đăng ký thành công';
  static const String successOrderCreated = 'Đã tạo lệnh thành công';
  static const String successOrderCancelled = 'Đã hủy lệnh thành công';
  static const String successWithdraw = 'Rút tiền thành công';
  static const String successDeposit = 'Nạp tiền thành công';

  // Validation Messages
  static const String validationEmailRequired = 'Email không được để trống';
  static const String validationEmailInvalid = 'Email không hợp lệ';
  static const String validationPasswordRequired = 'Mật khẩu không được để trống';
  static const String validationPasswordTooShort = 'Mật khẩu phải có ít nhất 8 ký tự';
  static const String validationPasswordMismatch = 'Mật khẩu không khớp';
  static const String validationAmountInvalid = 'Số lượng không hợp lệ';
  static const String validationPriceInvalid = 'Giá không hợp lệ';
}
