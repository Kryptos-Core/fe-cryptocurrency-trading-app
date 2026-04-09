// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Ứng dụng Giao dịch Crypto';

  @override
  String get login => 'Đăng nhập';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get noAccount => 'Chưa có tài khoản?';

  @override
  String get hasAccount => 'Đã có tài khoản?';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get markets => 'Thị trường';

  @override
  String get orders => 'Lệnh';

  @override
  String get wallets => 'Ví';

  @override
  String get currencies => 'Tiền tệ';

  @override
  String get profile => 'Cá nhân';

  @override
  String get retry => 'Thử lại';

  @override
  String get refresh => 'Làm mới';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get submit => 'Gửi';

  @override
  String get back => 'Quay lại';

  @override
  String get close => 'Đóng';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get noMarkets => 'Không có thị trường';

  @override
  String get noWallets => 'Không có ví';

  @override
  String get tradingChart => 'Biểu đồ giao dịch';

  @override
  String get bids => 'Mua (Bids)';

  @override
  String get asks => 'Bán (Asks)';

  @override
  String get realtimeActive => 'Cập nhật theo thời gian thực';

  @override
  String get interval => 'Khung thời gian';

  @override
  String get candles => 'Nến';

  @override
  String get vol => 'KL';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get loginToAccount => 'Đăng nhập vào tài khoản';

  @override
  String get emailRequired => 'Vui lòng nhập email';

  @override
  String get invalidEmail => 'Email không đúng định dạng';

  @override
  String get passwordRequired => 'Mật khẩu là bắt buộc';

  @override
  String get passwordMinLength => 'Mật khẩu cần ít nhất 8 ký tự';

  @override
  String get dashboard => 'Tổng quan';

  @override
  String get marketDetails => 'Chi tiết thị trường';

  @override
  String get marketNotFound => 'Không tìm thấy thị trường';

  @override
  String get lastPrice => 'Giá gần nhất';

  @override
  String get change24h => 'Biến động 24h';

  @override
  String get volume24h => 'Khối lượng 24h';

  @override
  String get marketInformation => 'Thông tin thị trường';

  @override
  String get baseCurrency => 'Tiền tệ cơ sở';

  @override
  String get quoteCurrency => 'Tiền tệ định giá';

  @override
  String get minOrderAmount => 'Khối lượng tối thiểu';

  @override
  String get makerFee => 'Phí Maker';

  @override
  String get takerFee => 'Phí Taker';

  @override
  String get status => 'Trạng thái';

  @override
  String get active => 'Hoạt động';

  @override
  String get inactive => 'Ngừng';

  @override
  String get orderBook => 'Sổ lệnh';

  @override
  String get asksSell => 'Bán (ASKS)';

  @override
  String get bidsBuy => 'Mua (BIDS)';

  @override
  String get waitingForChartData => 'Đang chờ dữ liệu biểu đồ...';

  @override
  String get connectedRealtime => 'Đã kết nối cập nhật thời gian thực';

  @override
  String get connectedNoUpdates => 'Đã kết nối — chưa có cập nhật cho cặp này';

  @override
  String get noRealtimeUpdatesHint =>
      'Cặp này có thể không có dữ liệu real-time (vd. không có trên Binance). Thử BTC/USDT hoặc ETH/USDT.';

  @override
  String get connecting => 'Đang kết nối...';

  @override
  String get offline => 'Ngoại tuyến';

  @override
  String get na => 'N/A';

  @override
  String get wallet => 'Ví';

  @override
  String get walletPortfolioCardTitle => 'Tổng danh mục';

  @override
  String get walletPortfolioEmptyHint =>
      'Chưa có dữ liệu ví. Kéo để làm mới hoặc kiểm tra kết nối.';

  @override
  String get selectCurrency => 'Chọn tiền tệ';

  @override
  String get currencySelectHint => 'Chạm để tìm hoặc chọn tiền tệ';

  @override
  String get searchCurrenciesHint => 'Tìm theo symbol hoặc tên (vd. BTC, USDT)';

  @override
  String get currencyPickerFilter => 'Hiển thị';

  @override
  String get currencyPickerFilterAll => 'Tất cả';

  @override
  String get currencyPickerFilterTradable => 'Có thể giao dịch';

  @override
  String get currencyPickerFilterNonTradable => 'Không giao dịch';

  @override
  String get currencyPickerNoMatches =>
      'Không có tiền tệ phù hợp với tìm kiếm hoặc bộ lọc';

  @override
  String get currencyPickerRemoveRecent => 'Xóa khỏi gần đây';

  @override
  String get available => 'Khả dụng';

  @override
  String get frozen => 'Đóng băng';

  @override
  String get total => 'Tổng';

  @override
  String get actions => 'Thao tác';

  @override
  String get deposit => 'Nạp tiền';

  @override
  String get withdraw => 'Rút tiền';

  @override
  String get transfer => 'Chuyển';

  @override
  String get depositSuccess => 'Nạp tiền thành công!';

  @override
  String get withdrawSuccess => 'Rút tiền thành công!';

  @override
  String get transferSuccess => 'Chuyển tiền thành công!';

  @override
  String get depositFailed => 'Nạp tiền thất bại';

  @override
  String get withdrawFailed => 'Rút tiền thất bại';

  @override
  String get transferFailed => 'Chuyển tiền thất bại';

  @override
  String get noActiveCurrencies => 'Không có tiền tệ nào';

  @override
  String get lastTransaction => 'Giao dịch gần nhất';

  @override
  String get recentTransactions => 'Giao dịch gần đây';

  @override
  String get searchTransactions => 'Tìm theo số tiền, loại, ngày...';

  @override
  String get filterByType => 'Lọc theo loại';

  @override
  String get allTypes => 'Tất cả loại';

  @override
  String get date => 'Ngày';

  @override
  String get type => 'Loại';

  @override
  String get reference => 'Tham chiếu';

  @override
  String get noTransactionsFound => 'Chưa có giao dịch';

  @override
  String get noTransactionsMatch => 'Không có giao dịch phù hợp';

  @override
  String get amount => 'Số lượng';

  @override
  String get toUserId => 'ID người nhận';

  @override
  String get welcomeBack => 'Chào trở lại,';

  @override
  String get memberSince => 'Thành viên từ';

  @override
  String get lastUpdated => 'Cập nhật lần cuối';

  @override
  String get viewAllCurrencies => 'Xem tất cả tiền tệ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get appSettingsPreferences => 'Cài đặt và tùy chọn ứng dụng';

  @override
  String get areYouSureLogout => 'Bạn có chắc muốn đăng xuất?';

  @override
  String get failedToLoadProfile => 'Không tải được hồ sơ';

  @override
  String get goToLogin => 'Đến trang đăng nhập';

  @override
  String get loggedOutSuccess => 'Đã đăng xuất thành công';

  @override
  String get orderBookEmpty => 'Chưa có lệnh';

  @override
  String get placeOrder => 'Đặt lệnh';

  @override
  String get buy => 'Mua';

  @override
  String get sell => 'Bán';

  @override
  String get limitOrder => 'Giới hạn';

  @override
  String get marketOrder => 'Thị trường';

  @override
  String get price => 'Giá';

  @override
  String get pairId => 'Pair ID';

  @override
  String get orderType => 'Loại lệnh';

  @override
  String get orderPlacedSuccess => 'Đặt lệnh thành công';

  @override
  String get insufficientBalance => 'Không đủ số dư';

  @override
  String get tradingPair => 'Cặp giao dịch';

  @override
  String get tradingPairPickerTitle => 'Chọn cặp giao dịch';

  @override
  String get tradingPairQuoteAll => 'Tất cả';

  @override
  String get tradingPairSectionRecent => 'Gần đây';

  @override
  String get tradingPairSectionFavorites => 'Yêu thích';

  @override
  String get tradingPairSelectPairHint => 'Chạm để tìm hoặc chọn cặp';

  @override
  String get tradingPairAddFavorite => 'Thêm yêu thích';

  @override
  String get tradingPairRemoveFavorite => 'Bỏ yêu thích';

  @override
  String get recentTrades => 'Giao dịch gần đây';

  @override
  String get youWillReceive => 'Sẽ nhận';

  @override
  String get estimatedFee => 'Phí ước tính';

  @override
  String get spotWallet => 'Ví spot';

  @override
  String get orderFundsFrom => 'Ví nguồn';

  @override
  String get orderFundsTo => 'Ví đích';

  @override
  String get orderInsufficientBase => 'Không đủ số dư tài sản cơ sở. Khả dụng';

  @override
  String get orderInsufficientQuote =>
      'Không đủ số dư tài sản định giá. Khả dụng';

  @override
  String get syncBinance => 'Đồng bộ Binance';

  @override
  String get syncBinanceDescription =>
      'Đồng bộ tiền tệ và cặp thị trường từ Binance vào cơ sở dữ liệu';

  @override
  String get manualResyncBinance => 'Đồng bộ lại thủ công từ Binance';

  @override
  String get manualResyncBinanceDescription =>
      'Chỉ dùng khi cần làm mới thủ công danh mục thị trường từ Binance.';

  @override
  String get lastManualSync => 'Lần đồng bộ thủ công gần nhất';

  @override
  String get neverSyncedYet => 'Chưa từng';

  @override
  String get syncing => 'Đang đồng bộ...';

  @override
  String get syncSuccess => 'Đồng bộ xong. Tiền tệ và thị trường đã cập nhật.';

  @override
  String get syncFailed => 'Đồng bộ thất bại';

  @override
  String get searchMarketsHint => 'Tìm theo symbol (vd. BTC, USDT)';

  @override
  String get filterBase => 'Cơ sở';

  @override
  String get filterBaseAll => 'Tất cả';

  @override
  String get filterQuote => 'Định giá';

  @override
  String get filterQuoteAll => 'Tất cả';

  @override
  String get marketsSortBy => 'Sắp xếp';

  @override
  String get marketsSortTopVolume => 'Khối lượng cao';

  @override
  String get marketsSortTopGainers => 'Tăng mạnh';

  @override
  String get marketsSortTopLosers => 'Giảm mạnh';

  @override
  String get marketsSortSymbolAsc => 'A-Z';

  @override
  String get marketsSortSymbolDesc => 'Z-A';

  @override
  String get marketsSortNewest => 'Mới nhất';

  @override
  String get marketsSortOldest => 'Cũ nhất';

  @override
  String get marketsFuzzySearch => 'Tìm kiếm thông minh';

  @override
  String get marketsResultSuffix => 'cặp';

  @override
  String get clearFilters => 'Xóa bộ lọc';

  @override
  String get payosTopupVnd => 'Nạp VND qua PayOS';

  @override
  String get payosDepositTitle => 'Nạp tiền VND (PayOS)';

  @override
  String get payosCreateOrder => 'Tạo đơn nạp tiền';

  @override
  String get payosAmountLabel => 'Số tiền (VND)';

  @override
  String get payosMinAmountHint => 'Tối thiểu 10,000';

  @override
  String get payosNoTransactions => 'Chưa có giao dịch nạp tiền nào.';

  @override
  String get payosOrderCode => 'Mã đơn';

  @override
  String get payosEnterAmount => 'Vui lòng nhập số tiền.';

  @override
  String get payosInvalidAmountMin =>
      'Số tiền không hợp lệ. Tối thiểu là 10,000 VND.';

  @override
  String get payosOpenLinkFailed => 'Không thể mở liên kết thanh toán.';

  @override
  String get payosWaitingWebhook => 'Đang chờ webhook PayOS...';

  @override
  String get payosPaymentUpdated =>
      'Thanh toán thành công. Số dư và lịch sử đã được cập nhật.';

  @override
  String get payosOrderProcessing =>
      'Đơn đang xử lý. Hệ thống sẽ tự cập nhật khi PayOS gửi webhook.';

  @override
  String get payosNeedFiatTitle => 'Muốn nạp tiền pháp định thay thế?';

  @override
  String get payosNeedFiatDesc =>
      'Dùng PayOS để nạp VND, sau đó quay lại giao dịch hoặc chuyển tiền.';

  @override
  String get openOnchainWalletFlow => 'Mở luồng ví On-chain';

  @override
  String get fiatWithdrawBankTitle => 'Rút USDT về ngân hàng';

  @override
  String get fiatWithdrawBankSubtitle =>
      'Liên kết STK ngân hàng VN, sau đó tạo yêu cầu rút. Cần tài khoản VERIFIED_USER.';

  @override
  String get fiatWithdrawToBankShort => 'Rút về NH';

  @override
  String get fiatWithdrawBankCode => 'Ngân hàng';

  @override
  String get fiatWithdrawAccountNumber => 'Số tài khoản';

  @override
  String get fiatWithdrawHolderName => 'Tên chủ tài khoản';

  @override
  String get fiatWithdrawSaveBank => 'Gửi duyệt STK';

  @override
  String get fiatWithdrawMyBanks => 'Tài khoản ngân hàng của tôi';

  @override
  String get fiatWithdrawAmount => 'Số tiền (USDT)';

  @override
  String get fiatWithdrawSubmitRequest => 'Gửi yêu cầu rút';

  @override
  String get fiatWithdrawMyRequests => 'Yêu cầu của tôi';

  @override
  String get fiatWithdrawAdminTitle => 'Rút tiền ngân hàng (admin)';

  @override
  String get fiatWithdrawAdminBanks => 'Tài khoản NH';

  @override
  String get fiatWithdrawAdminRequests => 'Yêu cầu rút';

  @override
  String get fiatWithdrawVerify => 'Xác minh';

  @override
  String get fiatWithdrawReject => 'Từ chối';

  @override
  String get fiatWithdrawComplete => 'Hoàn tất CK';

  @override
  String get fiatWithdrawTransferRef => 'Mã tham chiếu CK';

  @override
  String get drawerFiatWithdrawalAdmin => 'Rút NH (admin)';

  @override
  String get drawerFiatWithdrawalAdminSubtitle =>
      'Duyệt STK & rút USDT thủ công';

  @override
  String get onchainWalletsTitle => 'Ví On-chain';

  @override
  String get onchainLinkedWallets => 'Ví đã liên kết';

  @override
  String get addressCopied => 'Đã sao chép địa chỉ';

  @override
  String get copyFullAddress => 'Sao chép địa chỉ đầy đủ';

  @override
  String get linkWallet => 'Liên kết ví';

  @override
  String get linkWalletWeb => 'Liên kết ví (Web)';

  @override
  String get linkFirstWallet => 'Liên kết ví đầu tiên';

  @override
  String get noLinkedWalletsTitle => 'Chưa có ví nào được liên kết';

  @override
  String get noLinkedWalletsMessage =>
      'Hãy kết nối ví Tron, Solana hoặc Sepolia trước để có đích nạp và rút tiền đã xác minh.';

  @override
  String get unlinkWalletTitle => 'Hủy liên kết ví';

  @override
  String confirmUnlinkWallet(String address) {
    return 'Bạn có chắc muốn hủy liên kết $address?';
  }

  @override
  String get walletUnlinkedSuccess => 'Đã hủy liên kết ví thành công';

  @override
  String get failedToUnlinkWallet => 'Hủy liên kết ví thất bại';

  @override
  String walletLabelPrefix(String label) {
    return 'Nhãn: $label';
  }

  @override
  String linkedAtPrefix(String datetime) {
    return 'Liên kết lúc: $datetime';
  }

  @override
  String get unlinkAction => 'Hủy liên kết';

  @override
  String get networkLabel => 'Mạng lưới';

  @override
  String get walletAddressLabel => 'Địa chỉ ví';

  @override
  String get walletAddressRequired => 'Địa chỉ là bắt buộc';

  @override
  String get labelOptional => 'Nhãn (tùy chọn)';

  @override
  String get enableTestMode => 'Bật chế độ thử nghiệm (ký thủ công)';

  @override
  String get requestingChallenge => 'Đang yêu cầu...';

  @override
  String get requestChallengeStep => '1) Yêu cầu thử thách';

  @override
  String get challengeMessageTitle => 'Thông điệp thử thách';

  @override
  String get copyChallengManual => '2) Sao chép thử thách (Thủ công)';

  @override
  String get openExtensionSign => '2) Mở Extension & Ký';

  @override
  String get openWalletSign => '2) Mở ví & Ký';

  @override
  String get openWalletManualSign => '2) Mở ví & ký thủ công';

  @override
  String get signatureLabel => 'Chữ ký';

  @override
  String get pasteSignatureHint => 'Dán chữ ký ví vào đây';

  @override
  String get verifyingLink => 'Đang xác minh...';

  @override
  String get verifyLinkStep => '3) Xác minh liên kết';

  @override
  String get failedToRequestChallenge => 'Không thể yêu cầu thử thách';

  @override
  String challengeReceived(int seconds) {
    return 'Đã nhận thử thách. Hết hạn sau $seconds giây';
  }

  @override
  String get manualModeCopied =>
      'Chế độ thủ công: đã sao chép thử thách. Ký bằng ví thủ công rồi dán chữ ký bên dưới.';

  @override
  String get walletAddressUpdatedMetamask =>
      'Địa chỉ ví đã được cập nhật từ MetaMask. Vui lòng yêu cầu thử thách mới trước khi ký.';

  @override
  String useConnectedAccount(String address) {
    return 'Dùng tài khoản đã kết nối ($address)';
  }

  @override
  String get requestChallengeFirst => 'Vui lòng yêu cầu thử thách trước.';

  @override
  String get signatureRequired => 'Chữ ký là bắt buộc.';

  @override
  String get walletLinkedSuccess => 'Liên kết ví thành công.';

  @override
  String get verifyFailed => 'Xác minh thất bại';

  @override
  String get webModeNotice =>
      'Chế độ Web: luồng này ký qua cửa sổ popup của extension trình duyệt khi có provider.';

  @override
  String get appModeNotice =>
      'Chế độ App: Windows/Mobile dùng ứng dụng ví hoặc ký thủ công tùy thuộc vào mạng và provider.';

  @override
  String get manualSignGuideTitle =>
      'Hướng dẫn ký thủ công (Chế độ thử nghiệm)';

  @override
  String browserSignGuideTitle(String wallet) {
    return 'Hướng dẫn ký trên trình duyệt ($wallet)';
  }

  @override
  String desktopSignGuideTitle(String wallet) {
    return 'Hướng dẫn ký trên Desktop/Mobile ($wallet)';
  }

  @override
  String get walletGuideTestStep1 =>
      'Bước 2 sao chép nội dung thử thách vào clipboard.';

  @override
  String get walletGuideNativeTestStep2 =>
      'Mở ví hoặc công cụ ký thủ công và ký nội dung thử thách chính xác.';

  @override
  String get walletGuideNativeTestStep3 =>
      'Dán chữ ký vào ô Chữ ký, sau đó nhấn Xác minh liên kết.';

  @override
  String get walletGuideWebTestStep2 =>
      'Ký nội dung thử thách chính xác trong extension hoặc ứng dụng ví.';

  @override
  String get walletGuideWebTestStep3 =>
      'Dán chữ ký vào ô Chữ ký và nhấn Xác minh liên kết.';

  @override
  String get walletGuideNativeEthStep1 =>
      'Cài đặt extension MetaMask trên trình duyệt và mở khóa.';

  @override
  String get walletGuideNativeEthStep2 =>
      'Dùng tài khoản trên mạng Sepolia khớp với địa chỉ ví đã nhập.';

  @override
  String get walletGuideNativeEthStep3 =>
      'Nhấn Bước 2 để kích hoạt deep-link; nếu không mở được, ký thủ công trong MetaMask rồi dán chữ ký.';

  @override
  String get walletGuideNativeSolStep1 =>
      'Cài đặt extension hoặc ứng dụng Phantom và mở khóa.';

  @override
  String get walletGuideNativeSolStep2 =>
      'Chuyển ví sang Solana Devnet và dùng địa chỉ đã nhập.';

  @override
  String get walletGuideNativeSolStep3 =>
      'Nhấn Bước 2; nếu deep-link thất bại, ký thử thách thủ công rồi dán chữ ký.';

  @override
  String get walletGuideNativeTronStep1 =>
      'Cài đặt extension/ứng dụng TronLink và mở khóa.';

  @override
  String get walletGuideNativeTronStep2 =>
      'Chuyển sang tài khoản Nile hoặc Shasta khớp với địa chỉ đã nhập.';

  @override
  String get walletGuideNativeTronStep3 =>
      'Nhấn Bước 2; nếu ứng dụng không mở, mở TronLink thủ công, ký thử thách rồi dán chữ ký.';

  @override
  String get walletGuideWebEthStep1 =>
      'Dùng trình duyệt Chrome/Edge có extension MetaMask đã cài và mở khóa.';

  @override
  String get walletGuideWebEthStep2 =>
      'Đảm bảo extension có quyền truy cập site này (localhost hoặc domain của bạn).';

  @override
  String get walletGuideWebEthStep3 =>
      'Nhấn Bước 2 để mở popup MetaMask và xác nhận personal_sign.';

  @override
  String get walletGuideWebSolStep1 =>
      'Dùng trình duyệt có extension Phantom đã bật và mở khóa.';

  @override
  String get walletGuideWebSolStep2 =>
      'Chuyển Phantom sang Solana Devnet và xác nhận địa chỉ ví khớp.';

  @override
  String get walletGuideWebSolStep3 =>
      'Nhấn Bước 2, chấp nhận yêu cầu ký, sau đó tiếp tục xác minh.';

  @override
  String get walletGuideWebTronStep1 =>
      'Dùng trình duyệt có extension TronLink đã bật và mở khóa.';

  @override
  String get walletGuideWebTronStep2 =>
      'Chuyển sang tài khoản Nile hoặc Shasta khớp với địa chỉ đã nhập.';

  @override
  String get walletGuideWebTronStep3 =>
      'Nhấn Bước 2 và xác nhận chữ ký trong popup TronLink.';

  @override
  String get walletWindowsPrecheckReady =>
      'Pre-check Windows: extension đã sẵn sàng, bạn có thể tiếp tục ký.';

  @override
  String get walletWindowsPrecheckRequired =>
      'Pre-check Windows: cần xác nhận extension đã cài trước khi ký.';

  @override
  String get walletWindowsPrecheckCheck =>
      'Kiểm tra extension trên trình duyệt';

  @override
  String get walletWindowsPrecheckRecheck => 'Kiểm tra lại extension';

  @override
  String walletExtensionCheckTitle(String extension) {
    return 'Kiểm tra $extension';
  }

  @override
  String walletExtensionCheckMessage(String extension) {
    return 'Đã mở trình duyệt để bạn kiểm tra $extension. Nếu đã cài và mở khóa extension, chọn Sẵn sàng để tiếp tục liên kết ví.';
  }

  @override
  String get walletExtensionCheckClose => 'Đóng';

  @override
  String walletExtensionInstallAction(String extension) {
    return 'Cài $extension';
  }

  @override
  String get walletExtensionReadyAction => 'Sẵn sàng';

  @override
  String get walletDontAskAgainSession => 'Đừng hỏi lại trong phiên này';

  @override
  String get walletOpenTronLinkExtension => 'Mở quản lý TronLink Extension';

  @override
  String get walletWindowsNativeSignNotice =>
      'Ứng dụng Windows native không thể bật popup ký trực tiếp của extension. Popup ký trực tiếp chỉ hỗ trợ trên web (Chrome/Edge).';

  @override
  String get walletTronLinkExtensionOpened => 'Đã mở trang TronLink extension.';

  @override
  String get walletExtensionOpenFailed => 'Không thể mở trang extension.';

  @override
  String walletExtensionInstallOpenedInfo(String extension) {
    return 'Đã mở trang cài $extension. Cài đặt xong, quay lại và kiểm tra lại.';
  }

  @override
  String get walletExtensionPrecheckSuccess =>
      'Pre-check hoàn tất. Mở extension, ký challenge rồi dán chữ ký vào ô bên dưới.';

  @override
  String get submitOnchainDeposit => 'Gửi nạp tiền on-chain';

  @override
  String get onchainDepositDesc =>
      'Sau khi gửi token từ ví đến địa chỉ nạp của sàn, dán tx hash vào đây.';

  @override
  String onchainDepositTransitioningMinutes(int minutes) {
    return 'Địa chỉ ví đang được cập nhật (còn ~$minutes phút). Mã QR sẽ tự làm mới khi xong.';
  }

  @override
  String get onchainDepositTransitioningUnderOneMinute =>
      'Địa chỉ ví đang được cập nhật (còn dưới 1 phút). Mã QR sẽ tự làm mới khi xong.';

  @override
  String get onchainDepositTransitioningFinalize =>
      'Địa chỉ ví đang hoàn tất kích hoạt. Mã QR sẽ tự làm mới khi xong.';

  @override
  String get onchainDepositTransitioningUnknown =>
      'Địa chỉ ví đang được cập nhật. Mã QR sẽ tự làm mới khi xong.';

  @override
  String get platformDepositAddress => 'Địa chỉ nạp của sàn';

  @override
  String sendAssetsToAddress(String network) {
    return 'Gửi tài sản $network đến địa chỉ này, sau đó gửi tx hash bên dưới.';
  }

  @override
  String get onlyTransferSelectedChain =>
      'Chỉ chuyển trên chain đã chọn. Gửi nhầm chain có thể gây mất vĩnh viễn.';

  @override
  String get refreshAddress => 'Làm mới địa chỉ';

  @override
  String get copyAddress => 'Sao chép địa chỉ';

  @override
  String get hideFullAddress => 'Ẩn địa chỉ đầy đủ';

  @override
  String get showFullAddress => 'Hiện địa chỉ đầy đủ';

  @override
  String get couldNotLoadDepositAddress => 'Không thể tải địa chỉ nạp tiền.';

  @override
  String get transactionHashLabel => 'Hash giao dịch';

  @override
  String get txHashRequired => 'Hash giao dịch là bắt buộc';

  @override
  String get depositAddressCopied => 'Đã sao chép địa chỉ nạp tiền';

  @override
  String get senderWalletNotLinkedError =>
      'Ví người gửi chưa được liên kết. Hãy liên kết ví đó trước khi gửi nạp tiền.';

  @override
  String get depositSubmittedSuccess => 'Gửi nạp tiền thành công';

  @override
  String get amountRequired => 'Số lượng là bắt buộc';

  @override
  String get amountMustBePositive => 'Số lượng phải lớn hơn 0';

  @override
  String get depositPreviewLinked =>
      'Ví người gửi đã liên kết. Số lượng được tự điền từ dữ liệu on-chain.';

  @override
  String get depositPreviewNotLinked =>
      'Ví người gửi chưa liên kết với tài khoản. Hãy liên kết ví đó trước khi gửi.';

  @override
  String depositPreviewLabel(String status, String amount) {
    return 'Xem trước: $status · Số lượng $amount';
  }

  @override
  String get allNetworks => 'Tất cả mạng lưới';

  @override
  String txResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kết quả',
    );
    return '$_temp0';
  }

  @override
  String get sortNewest => 'Mới nhất';

  @override
  String get sortOldest => 'Cũ nhất';

  @override
  String get noTxMatchFilters => 'Không có giao dịch phù hợp với bộ lọc';

  @override
  String get trySwitchingFilters =>
      'Thử chuyển mạng lưới, loại hoặc sắp xếp để tìm giao dịch cần.';

  @override
  String txToAddress(String address) {
    return 'Đến: $address';
  }

  @override
  String get txTypeDeposits => 'Nạp tiền';

  @override
  String get txTypeWithdrawals => 'Rút tiền';

  @override
  String get txTypeTransfers => 'Chuyển khoản';

  @override
  String get noOnchainActivityTitle => 'Chưa có hoạt động on-chain';

  @override
  String get noOnchainActivityDesc =>
      'Các lần nạp tiền bạn gửi sẽ hiện ở đây để xem trạng thái và xác nhận.';

  @override
  String get trySwitchingFiltersDeposit =>
      'Thử chuyển mạng lưới, loại hoặc sắp xếp để tìm giao dịch cần.';

  @override
  String get requestOnchainWithdrawal => 'Yêu cầu rút tiền on-chain';

  @override
  String get withdrawalDestinationDesc =>
      'Đích rút tiền phải là ví đã được xác minh trên cùng mạng lưới.';

  @override
  String get linkedWalletDropdownLabel => 'Ví đã liên kết';

  @override
  String get selectDestinationWallet => 'Vui lòng chọn ví đích đã liên kết';

  @override
  String get withdrawalRequestSubmitted => 'Yêu cầu rút tiền đã được gửi';

  @override
  String get requestFailed => 'Yêu cầu thất bại';

  @override
  String get noVerifiedWalletTitle => 'Không có ví đã xác minh trên mạng này';

  @override
  String get noVerifiedWalletDesc =>
      'Hãy liên kết và xác minh ví ở tab ví đã liên kết trước khi yêu cầu rút tiền.';

  @override
  String get submitting => 'Đang gửi...';

  @override
  String get requestWithdrawalAction => 'Yêu cầu rút tiền';

  @override
  String get noWithdrawalActivityTitle => 'Chưa có hoạt động rút tiền';

  @override
  String get noWithdrawalActivityDesc =>
      'Các lần rút tiền được duyệt sẽ hiện ở đây với trạng thái on-chain mới nhất.';

  @override
  String get tryAnotherFilter =>
      'Thử chip mạng lưới hoặc loại khác để tìm giao dịch phù hợp.';

  @override
  String get payosOpenLinkFallbackTitle => 'Không thể tự mở PayOS';

  @override
  String get payosOpenLinkFallbackDesc =>
      'Link thanh toán đã sẵn sàng. Bạn có thể sao chép link hoặc thử mở lại.';

  @override
  String get payosCopyLink => 'Sao chép link';

  @override
  String get payosOpenInBrowser => 'Mở trên trình duyệt';

  @override
  String get payosLinkCopied => 'Đã sao chép link thanh toán';

  @override
  String get payosTapToOpenCheckout => 'Nhấn để mở trang thanh toán';

  @override
  String get payosPaymentCancelled => 'Thanh toán đã bị hủy hoặc hết hạn.';

  @override
  String get currenciesSearchHint => 'Tìm kiếm tiền tệ...';

  @override
  String get currenciesFilterAll => 'Tất cả';

  @override
  String get currenciesTradable => 'Có thể giao dịch';

  @override
  String get currenciesSortTopVolume => 'Top Khối lượng';

  @override
  String get currenciesSortTopGainers => 'Top Tăng giá';

  @override
  String get currenciesSortTopLosers => 'Top Giảm giá';

  @override
  String get currenciesSortAlphabet => 'A-Z';

  @override
  String get currenciesNoCurrenciesFound => 'Không tìm thấy tiền tệ';

  @override
  String get currenciesNoMatchSearch => 'Không có tiền tệ phù hợp tìm kiếm';

  @override
  String get currenciesDetailTitle => 'Chi tiết tiền tệ';

  @override
  String get currenciesNotFound => 'Không tìm thấy tiền tệ';

  @override
  String get currenciesMarketOverviewTitle => 'Tổng quan thị trường';

  @override
  String get currenciesConfigurationTitle => 'Cấu hình tiền tệ';

  @override
  String get currenciesSymbolLabel => 'Mã';

  @override
  String get currenciesNameLabel => 'Tên';

  @override
  String get currenciesPrecisionScaleLabel => 'Số chữ số thập phân';

  @override
  String get currenciesMinWithdrawLabel => 'Rút tối thiểu';

  @override
  String get currenciesYes => 'Có';

  @override
  String get currenciesNo => 'Không';

  @override
  String get profileTapToChangeAvatar => 'Chạm để đổi ảnh đại diện';

  @override
  String get profileEditName => 'Sửa tên';

  @override
  String get profileUpdated => 'Đã cập nhật hồ sơ';

  @override
  String get profileAvatarUpdated => 'Đã cập nhật ảnh đại diện';

  @override
  String get profileSecurityRequiresApproval => 'Bảo mật (cần xét duyệt)';

  @override
  String get profileEmailVerifiedTooltip => 'Đã xác minh email bằng OTP';

  @override
  String get profileEmailVerifiedLabel => 'Verified';

  @override
  String get profileChangeEmail => 'Đổi email';

  @override
  String get profileChangePassword => 'Đổi mật khẩu';

  @override
  String get profileChangePasswordDirect =>
      'Đổi trực tiếp, không cần xét duyệt';

  @override
  String get profilePasswordChanged => 'Mật khẩu đã được thay đổi';

  @override
  String get profileOtpAdminReviewRequired => 'Cần OTP + xét duyệt từ quản trị';

  @override
  String get profileEnable2faFirstTitle => 'Hãy bật 2FA trước';

  @override
  String get profileEnable2faFirstDesc =>
      'Vào Cài đặt để bật 2FA trước khi đổi email/mật khẩu';

  @override
  String get settingsLanguageTitle => 'Ngôn ngữ';

  @override
  String get settingsSecurityTitle => 'Bảo mật';

  @override
  String get settings2faDescription =>
      'Bật 2FA để bảo vệ các thao tác nhạy cảm như đổi email/mật khẩu.';

  @override
  String get settings2faLabel => 'Xác thực hai bước';

  @override
  String get settings2faEnabled => 'Đang bật';

  @override
  String get settings2faDisabled => 'Đang tắt';

  @override
  String get otpSentToEmail => 'OTP đã được gửi tới email đã xác thực.';

  @override
  String get otpVerificationTitle => 'Xác minh OTP';

  @override
  String get otpEnterCodeHint => 'Nhập OTP 6 chữ số';

  @override
  String get otpVerify => 'Xác minh';

  @override
  String get otpRequiredEnable2faFirst =>
      'Vui lòng bật 2FA trong Cài đặt trước khi đổi email hoặc mật khẩu.';

  @override
  String get contactEmailRequiredForOtpShort =>
      'Hãy thêm email thật trong Hồ sơ → Bảo mật trước khi dùng OTP qua mail.';

  @override
  String get contactEmailRequiredForOtpBody =>
      'Đăng nhập bằng ví đang dùng email tạm cho đến khi bạn xác minh email thật. Chọn Đổi email, nhập địa chỉ, bấm Gửi mã, rồi nhập OTP được gửi tới hộp thư đó.';

  @override
  String get contactEmailGoToProfile => 'Mở Hồ sơ';

  @override
  String get contactEmailVerifyDialogTitle => 'Xác minh email liên hệ';

  @override
  String get contactEmailVerifyDialogSubtitle =>
      'Nhập email thật của bạn. Hệ thống sẽ gửi mã 6 chữ số tới địa chỉ đó.';

  @override
  String get contactEmailSendCode => 'Gửi mã';

  @override
  String get contactEmailVerifySave => 'Xác minh và lưu';

  @override
  String get contactEmailUpdatedSuccess => 'Đã cập nhật email liên hệ.';

  @override
  String get aboutTitle => 'Giới thiệu';

  @override
  String get aboutOpenInBrowser => 'Mở trong trình duyệt';

  @override
  String get aboutPolicyGuideHint =>
      'Chính sách, thông tin ứng dụng và hướng dẫn sử dụng có trong trang web.';

  @override
  String get aboutAppTileTitle => 'Về ứng dụng';

  @override
  String get aboutAppTileSubtitle => 'Chính sách, thông tin, hướng dẫn';

  @override
  String get requestSentPendingApproval =>
      'Yêu cầu đã gửi. Đang chờ xét duyệt.';

  @override
  String get broadcastNotificationTitle => 'Phát thông báo';

  @override
  String get broadcastInfoBanner =>
      'Thông báo này sẽ được gửi đến tất cả người dùng đang hoạt động theo thời gian thực và được lưu trong lịch sử thông báo.';

  @override
  String get broadcastTypeLabel => 'Loại';

  @override
  String get broadcastTypeSystem => 'Hệ thống';

  @override
  String get broadcastTypeAlert => 'Cảnh báo';

  @override
  String get broadcastTypePromo => 'Khuyến mãi';

  @override
  String get broadcastTitleLabel => 'Tiêu đề';

  @override
  String get broadcastTitleHint => 'vd: Bảo trì hệ thống lúc 23:00 tối nay';

  @override
  String get broadcastTitleRequired => 'Tiêu đề là bắt buộc';

  @override
  String get broadcastTitleTooShort => 'Tiêu đề quá ngắn';

  @override
  String get broadcastMessageLabel => 'Nội dung';

  @override
  String get broadcastMessageHint => 'Nhập nội dung thông báo tại đây...';

  @override
  String get broadcastMessageRequired => 'Nội dung thông báo là bắt buộc';

  @override
  String get broadcastMessageTooShort => 'Nội dung quá ngắn';

  @override
  String get broadcastSending => 'Đang gửi...';

  @override
  String get broadcastSendAllUsers => 'Gửi đến tất cả người dùng';

  @override
  String get broadcastSuccess => 'Phát thông báo thành công';

  @override
  String get broadcastFailedTryAgain =>
      'Gửi thông báo thất bại. Vui lòng thử lại.';

  @override
  String get noPermissionMessage =>
      'Bạn không có quyền thực hiện thao tác này.';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get onchainTooltip => 'On-chain';

  @override
  String get notificationsTooltip => 'Thông báo';

  @override
  String get drawerOnchainWallets => 'Ví On-chain';

  @override
  String get drawerSettings => 'Cài đặt';

  @override
  String get drawerUserManagement => 'Quản lý người dùng';

  @override
  String get drawerAdminArea => 'Khu vực quản trị';

  @override
  String get drawerUserMgmtComingSoon =>
      'Màn hình quản lý người dùng — sắp ra mắt';

  @override
  String get drawerBroadcastNotification => 'Phát thông báo';

  @override
  String get drawerBroadcastSubtitle => 'Gửi tới tất cả người dùng';

  @override
  String get drawerManualResync => 'Đồng bộ thủ công Binance';

  @override
  String get drawerManualResyncComingSoon =>
      'Đồng bộ sàn giao dịch thủ công — sắp ra mắt';

  @override
  String get drawerSecurityRequests => 'Yêu cầu bảo mật';

  @override
  String get drawerSecuritySubtitle =>
      'Duyệt/từ chối yêu cầu đổi email & mật khẩu';

  @override
  String get authRequiredTitle => 'Yêu cầu đăng nhập';

  @override
  String get authRequiredSubtitle =>
      'Vui lòng đăng nhập để truy cập tính năng này.';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get welcomeGuest => 'Xin chào, Khách';

  @override
  String get guestSignInDesc =>
      'Đăng nhập để truy cập ví, đặt lệnh và quản lý tài khoản.';

  @override
  String get guestFeaturesTitle => 'Có thể dùng mà không cần đăng nhập';

  @override
  String get guestFeatureLiveMarkets =>
      'Dữ liệu & biểu đồ thị trường trực tiếp';

  @override
  String get guestFeatureCurrencies => 'Các đồng tiền & mạng lưới được hỗ trợ';

  @override
  String get guestFeatureDeposit => 'Phương thức nạp tiền của sàn';

  @override
  String get continueAsGuest => 'Tiếp tục xem không đăng nhập';

  @override
  String get notificationsTitle => 'Thông báo';

  @override
  String get notificationsMarkAllRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get notificationsEmpty => 'Chưa có thông báo nào';

  @override
  String get notificationsJustNow => 'Vừa xong';

  @override
  String notificationsMinAgo(int count) {
    return '$count phút trước';
  }

  @override
  String notificationsHourAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String notificationsDayAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get notificationsDetails => 'Chi tiết';

  @override
  String get notificationsTypeAlert => 'Cảnh báo';

  @override
  String get notificationsTypePromo => 'Khuyến mãi';

  @override
  String get notificationsTypeSystem => 'Hệ thống';

  @override
  String get dashboardTopMarkets => 'Thị trường hàng đầu';

  @override
  String get dashboardMyWallets => 'Ví của tôi';

  @override
  String get dashboardTotalPortfolioValue => 'Tổng giá trị danh mục';

  @override
  String get dashboardSeeAll => 'Xem tất cả';

  @override
  String get dashboardNoMarketsAvailable => 'Không có thị trường nào';

  @override
  String get dashboardNoFundedWallets =>
      'Chưa có ví nào có số dư.\nNạp tiền hoặc giao dịch để xem số dư tại đây.';

  @override
  String get dashboardWallets => 'Ví';

  @override
  String get dashboardActive => 'Đang hoạt động';

  @override
  String get dashboardBankProvidersHealthTitle => 'API ngân hàng (rút fiat)';

  @override
  String get dashboardBankProvidersHealthAllOperational =>
      'Mọi provider hoạt động bình thường';

  @override
  String get dashboardBankProvidersHealthDegraded =>
      'Một số provider không khả dụng';

  @override
  String get dashboardBankProvidersHealthCouldNotCheck =>
      'Không kiểm tra được health';

  @override
  String get dashboardBankProvidersHealthLoading => 'Đang kiểm tra provider…';

  @override
  String dashboardBankProvidersHealthMs(int ms) {
    return '$ms ms';
  }

  @override
  String get securityRequestsTitle => 'Yêu cầu thay đổi bảo mật';

  @override
  String get securityRequestApproved => 'Yêu cầu đã được duyệt';

  @override
  String get securityRequestRejected => 'Yêu cầu đã bị từ chối';

  @override
  String get securityRejectDialogTitle => 'Từ chối yêu cầu';

  @override
  String get securityRejectReasonHint => 'Lý do (không bắt buộc)';

  @override
  String get securityRequestNoPending => 'Không có yêu cầu nào đang chờ';

  @override
  String securityRequestRequested(String date) {
    return 'Yêu cầu lúc: $date';
  }

  @override
  String get securityRequestApprove => 'Duyệt';

  @override
  String get securityRequestReject => 'Từ chối';

  @override
  String get registerCreateAccount => 'Tạo tài khoản';

  @override
  String get registerSignUpSubtitle => 'Đăng ký để bắt đầu';

  @override
  String get registerFirstNameLabel => 'Tên';

  @override
  String get registerFirstNameHelper => 'Chỉ được dùng chữ cái và khoảng trắng';

  @override
  String get registerFirstNameRequired => 'Tên là bắt buộc';

  @override
  String get registerLastNameLabel => 'Họ';

  @override
  String get registerLastNameRequired => 'Họ là bắt buộc';

  @override
  String get registerEmailHint => 'user@example.com';

  @override
  String get registerPasswordLabel => 'Mật khẩu';

  @override
  String get registerPasswordHint =>
      'Tối thiểu 8 ký tự, gồm chữ hoa, thường, số';

  @override
  String get registerPasswordRequired => 'Mật khẩu là bắt buộc';

  @override
  String get registerPasswordMinLength => 'Mật khẩu phải có ít nhất 8 ký tự';

  @override
  String get registerPasswordNeedsUppercase =>
      'Mật khẩu phải có ít nhất 1 chữ hoa';

  @override
  String get registerPasswordNeedsLowercase =>
      'Mật khẩu phải có ít nhất 1 chữ thường';

  @override
  String get registerPasswordNeedsNumber => 'Mật khẩu phải có ít nhất 1 chữ số';

  @override
  String get registerPasswordNeedsSpecial =>
      'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';

  @override
  String get registerConfirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get registerConfirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get registerConfirmPasswordRequired => 'Xác nhận mật khẩu là bắt buộc';

  @override
  String get registerPasswordsNoMatch => 'Mật khẩu không khớp';

  @override
  String get registerWalletDivider => 'Đăng ký bằng ví';

  @override
  String get registerWithTronLink => 'Đăng ký bằng TronLink';

  @override
  String get registerSuccessLoggingIn =>
      'Đăng ký thành công! Đang đăng nhập...';

  @override
  String get registerLoginFailedManual =>
      'Đăng nhập thất bại. Vui lòng đăng nhập thủ công.';

  @override
  String get registerLoginSuccess => 'Đăng nhập thành công!';

  @override
  String get registerWalletSuccess => 'Đăng ký & đăng nhập bằng ví thành công!';

  @override
  String get registerWalletConnectQr => 'WalletConnect (QR)';

  @override
  String registerUnexpectedError(String error) {
    return 'Lỗi không mong đợi: $error';
  }

  @override
  String get walletDetails => 'Chi tiết ví';

  @override
  String get walletNotFound => 'Không tìm thấy ví';

  @override
  String get walletAvailableBalance => 'Số dư khả dụng';

  @override
  String get walletFrozen => 'Đóng băng';

  @override
  String get walletTotal => 'Tổng';

  @override
  String get walletAvailable => 'Khả dụng';

  @override
  String get walletTransactionHistory => 'Lịch sử giao dịch';

  @override
  String get walletNoTransactions => 'Không có giao dịch nào';

  @override
  String walletBalanceAfter(String amount) {
    return 'Số dư: $amount';
  }

  @override
  String get walletUsdValue => 'Giá trị USD';

  @override
  String get totalPortfolioValue => 'Tổng giá trị danh mục';

  @override
  String get noWalletsFound => 'Không tìm thấy ví nào';

  @override
  String get myWallets => 'Ví của tôi';

  @override
  String get cashWalletSectionTitle => 'Ví Tiền';

  @override
  String get cashWalletSectionSubtitle =>
      'Nhận toàn bộ tiền nạp • Dùng để mua coin';

  @override
  String get coinAssetsSectionTitle => 'Tài sản';

  @override
  String get coinAssetsSectionSubtitle => 'Coin sở hữu từ giao dịch';

  @override
  String get depositOnchainHint =>
      'Tiền sẽ được quy đổi sang USDT và cộng vào Ví Tiền';

  @override
  String get treasuryTitle => 'Nạp tiền & ví quản lý';

  @override
  String get treasuryManageSubtitle =>
      'Địa chỉ nạp mặc định, chain ưu tiên và ví công ty cho luồng hiển thị cho người dùng.';

  @override
  String get treasuryToolbarTooltip =>
      'Nạp tiền & ví quản lý — địa chỉ nạp mặc định và chain ưu tiên';

  @override
  String get treasuryManagedScopeBanner =>
      'Danh sách này cho địa chỉ nạp mặc định & ví risk. Ví vận hành nằm ở Cấu hình thanh toán → Ví vận hành.';

  @override
  String get treasuryOpsScopeBanner =>
      'Ví dùng để cấp vốn / gom về ví chính. Địa chỉ nạp cho user: màn Nạp & ví quản lý.';

  @override
  String get paymentConfigTitle => 'Cấu hình thanh toán';

  @override
  String get paymentConfigMethodsTab => 'Phương thức';

  @override
  String get paymentConfigTreasuryWalletsTab => 'Ví vận hành';

  @override
  String get paymentConfigHistoryTab => 'Lịch sử';

  @override
  String get paymentConfigAddMethod => 'Thêm phương thức';

  @override
  String get paymentConfigEditConfigTitle => 'Chỉnh sửa cấu hình';

  @override
  String get paymentConfigEmptyMessage =>
      'Chưa có cấu hình nào.\nNhấn \"Thêm phương thức\" để tạo mới.';

  @override
  String get paymentConfigActivateDialogTitle => 'Kích hoạt cấu hình';

  @override
  String paymentConfigActivateTarget(String name) {
    return 'Kích hoạt: $name';
  }

  @override
  String get paymentConfigActivateWarning =>
      'Hệ thống sẽ vào trạng thái TRANSITIONING. Trader sẽ nhận banner cảnh báo trong grace period.';

  @override
  String get paymentConfigGracePeriodLabel => 'Grace period (phút)';

  @override
  String get paymentConfigGracePeriodHelper =>
      'Thời gian chờ trước khi config mới có hiệu lực';

  @override
  String get paymentConfigActivateAction => 'Kích hoạt';

  @override
  String paymentConfigActivationStartedMinutes(int minutes) {
    return 'Đã bắt đầu grace period $minutes phút';
  }

  @override
  String paymentConfigActivationAt(String time) {
    return 'Kích hoạt lúc: $time';
  }

  @override
  String get paymentConfigActivateFailed => 'Lỗi kích hoạt cấu hình';

  @override
  String get paymentConfigDeactivateDialogTitle => 'Vô hiệu hóa cấu hình';

  @override
  String paymentConfigDeactivateDialogContent(String name) {
    return 'Bạn có chắc muốn vô hiệu hóa \"$name\"?\nThao tác này có hiệu lực ngay lập tức.';
  }

  @override
  String get paymentConfigDeactivateAction => 'Vô hiệu hóa';

  @override
  String get paymentConfigDeactivatedSuccess => 'Đã vô hiệu hóa';

  @override
  String paymentConfigTransitioningRemaining(int minutes) {
    return 'Còn ~$minutes phút trước khi kích hoạt';
  }

  @override
  String get paymentConfigGraceUnderOneMinute =>
      'Còn dưới 1 phút trước khi kích hoạt';

  @override
  String get paymentConfigGraceFinalizePending =>
      'Hết thời gian chờ — đang hoàn tất kích hoạt…';

  @override
  String get paymentConfigGraceUnknown => 'Đang trong thời gian chờ kích hoạt';

  @override
  String paymentConfigVersionAndSort(int version, int sortOrder) {
    return 'Phiên bản: v$version · Sắp xếp: $sortOrder';
  }

  @override
  String paymentConfigActivatedAt(String datetime) {
    return 'Kích hoạt: $datetime';
  }

  @override
  String get paymentConfigEditAction => 'Chỉnh sửa';

  @override
  String get paymentConfigEditTypeLocked =>
      'Không đổi loại/mạng khi sửa — tạo phương thức mới nếu cần.';

  @override
  String get paymentConfigDetailLoadFailed =>
      'Không tải được cấu hình để chỉnh sửa.';

  @override
  String get paymentConfigStatusActiveUpper => 'ĐANG HOẠT ĐỘNG';

  @override
  String get paymentConfigStatusTransitioningUpper => 'ĐANG CHUYỂN ĐỔI';

  @override
  String get paymentConfigStatusInactiveUpper => 'KHÔNG HOẠT ĐỘNG';

  @override
  String get paymentConfigMethodTypeLabel => 'Loại phương thức';

  @override
  String get paymentConfigNetworkLabel => 'Mạng';

  @override
  String get paymentConfigDisplayNameLabel => 'Tên hiển thị';

  @override
  String get paymentConfigDisplayNameHint => 'VD: PayOS Ngân hàng MB';

  @override
  String get paymentConfigRequired => 'Bắt buộc';

  @override
  String get paymentConfigGracePeriodEffectHelper =>
      'Thời gian chờ khi kích hoạt trước khi có hiệu lực';

  @override
  String get paymentConfigCredentialsSectionTitle => 'Thông tin xác thực';

  @override
  String get paymentConfigHideAction => 'Ẩn';

  @override
  String get paymentConfigShowAction => 'Hiện';

  @override
  String get paymentConfigMainnetWarning =>
      'MAINNET — cấu hình này ảnh hưởng đến tiền thực. Kiểm tra kỹ trước khi kích hoạt.';

  @override
  String get paymentConfigMainnetSubtitle =>
      'Bật nếu là mạng mainnet (tiền thực)';

  @override
  String get paymentConfigRateLabel => 'Tỉ giá (1 VND → X USDT)';

  @override
  String get paymentConfigCreateConfigAction => 'Tạo cấu hình';

  @override
  String get paymentConfigSaveChangesAction => 'Lưu thay đổi';

  @override
  String get paymentConfigCreatedSuccess => 'Đã tạo cấu hình';

  @override
  String get paymentConfigUpdatedSuccess => 'Đã cập nhật cấu hình';

  @override
  String get paymentConfigUnknownError => 'Có lỗi xảy ra';

  @override
  String get paymentConfigMaskedHelper => 'Ẩn — nhấn \"Hiện\" để xem';

  @override
  String get paymentConfigRuntimeTab => 'Nền tảng';

  @override
  String get paymentConfigRuntimeSaveAll => 'Lưu cấu hình runtime';

  @override
  String get paymentConfigRuntimeLoadFailed =>
      'Không tải được cấu hình nền tảng.';

  @override
  String get paymentConfigRuntimeSaved => 'Đã lưu cấu hình runtime.';

  @override
  String get paymentConfigRuntimeIntro =>
      'Các giá trị này có hiệu lực mà không cần deploy lại API. Biến môi trường vẫn là mặc định khi chưa lưu trong cơ sở dữ liệu.';

  @override
  String get paymentConfigRuntimeSectionCore => 'Lõi hệ thống';

  @override
  String get paymentConfigRuntimeSectionTech => 'Hạ tầng & RPC';

  @override
  String get paymentConfigRuntimeSectionFinance => 'Tài chính & giới hạn';

  @override
  String get paymentConfigRuntimeSourceEnv => 'Mặc định (env)';

  @override
  String get paymentConfigRuntimeSourceDb => 'Cơ sở dữ liệu';

  @override
  String get paymentConfigRuntimeTypeString => 'chuỗi';

  @override
  String get paymentConfigRuntimeTypeInteger => 'số nguyên';

  @override
  String get paymentConfigRuntimeTypeBoolean => 'boolean';

  @override
  String get paymentConfigRuntimeTypeFloat => 'số thực';

  @override
  String get runtimeSettingWalletSyncIntervalName => 'Chu kỳ đồng bộ ví (ms)';

  @override
  String get runtimeSettingWalletSyncIntervalDesc =>
      'Khoảng thời gian cho worker đồng bộ ví (milliseconds).';

  @override
  String get runtimeSettingWalletReconciliationThresholdName =>
      'Ngưỡng chênh lệch đối soát';

  @override
  String get runtimeSettingWalletReconciliationThresholdDesc =>
      'Chênh lệch số dư tuyệt đối được coi là chấp nhận được khi đối soát.';

  @override
  String get runtimeSettingTronNileFullHostName => 'URL RPC Tron Nile';

  @override
  String get runtimeSettingTronNileFullHostDesc =>
      'HTTP API full node cho testnet TRON Nile.';

  @override
  String get runtimeSettingTronShastaFullHostName => 'URL RPC Tron Shasta';

  @override
  String get runtimeSettingTronShastaFullHostDesc =>
      'HTTP API full node cho testnet TRON Shasta.';

  @override
  String get runtimeSettingTronDefaultNetworkName => 'Mạng Tron mặc định';

  @override
  String get runtimeSettingTronDefaultNetworkDesc =>
      'TRON_NILE hoặc TRON_SHASTA. Đổi giá trị có thể cần khởi động lại API cho một số tiến trình.';

  @override
  String get runtimeSettingSolanaDevnetUrlName => 'URL RPC Solana Devnet';

  @override
  String get runtimeSettingSolanaDevnetUrlDesc =>
      'Endpoint JSON RPC cho Solana devnet.';

  @override
  String get runtimeSettingEthSepoliaRpcUrlName => 'URL RPC Ethereum Sepolia';

  @override
  String get runtimeSettingEthSepoliaRpcUrlDesc =>
      'URL JSON-RPC cho testnet Sepolia.';

  @override
  String get runtimeSettingEthSepoliaChainIdName => 'Chain ID Ethereum Sepolia';

  @override
  String get runtimeSettingEthSepoliaChainIdDesc =>
      'Chain ID EIP-155 cho Sepolia (ví dụ 11155111).';

  @override
  String get runtimeSettingBlockchainAllowTestSignatureName =>
      'Cho phép bỏ qua chữ ký thử (test)';

  @override
  String get runtimeSettingBlockchainAllowTestSignatureDesc =>
      'Khi bật (áp dụng quy tắc ngoài production), liên kết có thể chấp nhận payload TEST_SIG::. Trên production, chỉnh từ UI bị chặn trừ khi ALLOW_UI_TEST_SIGNATURE=true.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxName =>
      'Giới hạn rút tự động toàn cục (native)';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxDesc =>
      'Số native tối đa mặc định cho các lệnh rút được xử lý tự động.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxEthSepoliaName =>
      'Giới hạn rút tự động — ETH Sepolia';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxEthSepoliaDesc =>
      'Trần theo chuỗi cho ETH_SEPOLIA; để trống sẽ dùng giới hạn toàn cục.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetName =>
      'Giới hạn rút tự động — Solana devnet';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetDesc =>
      'Trần theo chuỗi cho SOLANA_DEVNET; để trống sẽ dùng giới hạn toàn cục.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronNileName =>
      'Giới hạn rút tự động — Tron Nile';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronNileDesc =>
      'Trần theo chuỗi cho TRON_NILE; để trống sẽ dùng giới hạn toàn cục.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronShastaName =>
      'Giới hạn rút tự động — Tron Shasta';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronShastaDesc =>
      'Trần theo chuỗi cho TRON_SHASTA; để trống sẽ dùng giới hạn toàn cục.';

  @override
  String get runtimeSettingBlockchainWithdrawEthSymbolName =>
      'Ký hiệu rút — Ethereum';

  @override
  String get runtimeSettingBlockchainWithdrawEthSymbolDesc =>
      'Ký hiệu tiền tệ cho các chuỗi họ ETH (phải tồn tại trong DB).';

  @override
  String get runtimeSettingBlockchainWithdrawSolSymbolName =>
      'Ký hiệu rút — Solana';

  @override
  String get runtimeSettingBlockchainWithdrawSolSymbolDesc =>
      'Ký hiệu tiền tệ cho rút Solana devnet.';

  @override
  String get runtimeSettingBlockchainWithdrawTronSymbolName =>
      'Ký hiệu rút — Tron';

  @override
  String get runtimeSettingBlockchainWithdrawTronSymbolDesc =>
      'Ký hiệu tiền tệ cho rút Tron (ví dụ TRX).';

  @override
  String get runtimeSettingPlatformCashCurrencySymbolName =>
      'Ký hiệu tiền mặt nền tảng';

  @override
  String get runtimeSettingPlatformCashCurrencySymbolDesc =>
      'Ký hiệu sổ cái nội bộ cho nhánh tiền mặt của nạp (thường là USDT).';

  @override
  String get runtimeSettingBlockchainDepositTrxToUsdtRateName =>
      'Tỉ giá dự phòng TRX → USDT';

  @override
  String get runtimeSettingBlockchainDepositTrxToUsdtRateDesc =>
      'Dùng khi oracle giá không khả dụng; 1 TRX = X USDT.';

  @override
  String get runtimeSettingBlockchainDepositEthToUsdtRateName =>
      'Tỉ giá dự phòng ETH → USDT';

  @override
  String get runtimeSettingBlockchainDepositEthToUsdtRateDesc =>
      'Dùng khi oracle giá không khả dụng.';

  @override
  String get runtimeSettingBlockchainDepositSolToUsdtRateName =>
      'Tỉ giá dự phòng SOL → USDT';

  @override
  String get runtimeSettingBlockchainDepositSolToUsdtRateDesc =>
      'Dùng khi oracle giá không khả dụng.';

  @override
  String get treasuryCreateWalletFab => 'Tạo ví giao dịch';

  @override
  String get treasuryCreateWalletDialogTitle => 'Tạo ví giao dịch';

  @override
  String get treasuryCreateWalletCta => 'Tạo ví';

  @override
  String get treasuryChainLabel => 'Chain';

  @override
  String get treasuryPurposeLabel => 'Mục đích';

  @override
  String get treasuryTypeLabel => 'Loại';

  @override
  String get treasuryLabelOptional => 'Nhãn (tuỳ chọn)';

  @override
  String get treasuryFilterAll => 'Tất cả';

  @override
  String get treasuryNoWalletsYet =>
      'Chưa có ví giao dịch. Nhấn \"Tạo ví giao dịch\" để bắt đầu.';

  @override
  String get treasuryOpsGuideTitle => 'Gợi ý';

  @override
  String get treasuryOpsGuideSummary =>
      'Gom về: chuyển về ví chính. Cấp vốn: lấy từ ví chính sang ví này.';

  @override
  String get treasuryOpsPublicAddressLabel => 'Địa chỉ công khai (public)';

  @override
  String get treasuryOpsAddressCopiedSnack => 'Đã sao chép địa chỉ công khai.';

  @override
  String get treasuryStatusActive => 'ACTIVE';

  @override
  String get treasuryStatusInactive => 'INACTIVE';

  @override
  String get treasuryBalanceLabel => 'Số dư';

  @override
  String get treasurySweepAction => 'Gom về';

  @override
  String get treasurySweepTooltip => 'Gom tiền từ ví này về ví chính';

  @override
  String get treasurySweepDialogTitle => 'Sweep về ví chính';

  @override
  String get treasurySweepTargetLabel => 'Sweep về';

  @override
  String get treasuryFundAction => 'Cấp vốn';

  @override
  String get treasuryFundTooltip => 'Nạp tiền từ ví chính vào ví này';

  @override
  String get treasurySweepQueued =>
      'Đã nhận yêu cầu gom về. Số dư trên thẻ sẽ cập nhật khi giao dịch trên chuỗi hoàn tất.';

  @override
  String get treasurySweepFailed => 'Sweep thất bại';

  @override
  String get treasuryFundDialogTitle => 'Fund từ ví chính';

  @override
  String get treasuryAmountLabel => 'Số lượng';

  @override
  String get treasuryAmountHint => 'Ví dụ: 0.5';

  @override
  String get treasuryCancelAction => 'Hủy';

  @override
  String get treasuryConfirmAction => 'Xác nhận';

  @override
  String get treasuryFundQueued =>
      'Đã nhận yêu cầu cấp vốn. Số dư trên thẻ sẽ cập nhật khi giao dịch trên chuỗi hoàn tất.';

  @override
  String get treasuryWalletPendingOnChainBadge => 'Đang xử lý trên chuỗi…';

  @override
  String get treasuryQueuedBalanceHint =>
      'Số dư trên thẻ vẫn là số cũ — chưa có tiền mới cho đến khi chuỗi xác nhận.';

  @override
  String get treasuryPendingOnChainTooltipGeneric =>
      'Lệnh Fund/Sweep đang chạy trên chuỗi. Số dư hiển thị chưa phản ánh giao dịch mới.';

  @override
  String treasuryPendingOnChainTooltipWithId(String operationId) {
    return 'Lệnh $operationId đang PENDING/PROCESSING trên chuỗi. Số dư ví chưa đổi cho đến khi hoàn tất.';
  }

  @override
  String get treasuryFundFailed => 'Fund thất bại';

  @override
  String get treasuryOperationsTitle => 'Lệnh vận hành (Fund / Sweep)';

  @override
  String get treasuryNoOperations => 'Chưa có lệnh nào';

  @override
  String get treasuryTransactionsTitle => 'Giao dịch on-chain';

  @override
  String get treasuryNoTransactions => 'Chưa có giao dịch';

  @override
  String get treasurySearchHint => 'Tx hash, mã lệnh, địa chỉ…';

  @override
  String get treasuryHistorySearchLabel => 'Tìm kiếm';

  @override
  String get treasuryHistoryIdLabel => 'Mã lệnh';

  @override
  String get treasuryHistoryTxHash => 'Tx hash';

  @override
  String get treasuryHistoryFrom => 'Gửi từ';

  @override
  String get treasuryHistoryTo => 'Đến';

  @override
  String get treasuryHistoryTypeFund => 'Cấp vốn';

  @override
  String get treasuryHistoryTypeSweep => 'Gom về';

  @override
  String get treasuryHistoryStatusPending => 'Đang chờ';

  @override
  String get treasuryHistoryStatusProcessing => 'Đang xử lý';

  @override
  String get treasuryHistoryStatusConfirming => 'Đang xác nhận chuỗi';

  @override
  String get treasuryHistoryStatusCompleted => 'Hoàn tất';

  @override
  String get treasuryHistoryStatusFailed => 'Thất bại';

  @override
  String get treasuryHistoryLoadMore => 'Tải thêm';

  @override
  String get apiErrorGeneric => 'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String apiErrorTxWalletNonZeroBalance(String maxAmount, String symbol) {
    return 'Hãy gom về trước — số dư on-chain tối đa $maxAmount $symbol mới được xóa ví.';
  }

  @override
  String get apiErrorTxWalletNonZeroBalanceShort =>
      'Hãy gom về trước — cần giảm số dư on-chain trước khi xóa ví này.';

  @override
  String get apiErrorTxWalletUsdtNonZero =>
      'Chuyển hết USDT TRC-20 ra khỏi ví này trước khi xóa.';

  @override
  String get apiErrorTxWalletDefaultDepositDelete =>
      'Bỏ ví khỏi mặc định nạp tiền cho người dùng trước khi xóa.';

  @override
  String get apiErrorTxWalletOperationInFlight =>
      'Chờ các lệnh Cấp vốn hoặc Gom về đang chạy xong rồi mới xóa ví.';

  @override
  String get apiErrorTxWalletExists =>
      'Đã có ví giao dịch với chain và mục đích này.';

  @override
  String get apiErrorTreasuryWalletInactive =>
      'Ví giao dịch này đang không hoạt động.';

  @override
  String get apiErrorTreasuryWalletLocked =>
      'Đang có thao tác kho bạc khác trên ví này. Thử lại sau.';

  @override
  String get apiErrorDefaultUserDepositDeactivate =>
      'Không thể vô hiệu hóa ví nạp tiền mặc định hiện tại.';

  @override
  String get treasuryWalletCreatedSuccess => 'Đã tạo ví giao dịch';

  @override
  String get treasuryOpsDeleteWalletTooltip => 'Xóa ví giao dịch này';

  @override
  String get treasuryOpsDeleteWalletTitle => 'Xóa ví vận hành?';

  @override
  String get treasuryOpsDeleteWalletBody =>
      'Xóa ví Fund/Sweep khỏi hệ thống. Cần gom về gần hết số dư, chờ xong mọi lệnh Fund/Sweep đang chạy, và bỏ ví khỏi mặc định nạp tiền (nếu đang là mặc định).';

  @override
  String get treasuryOpsDeleteWalletSuccessSnack => 'Đã xóa ví giao dịch.';

  @override
  String get treasuryOpsDeleteWalletAction => 'Xóa';

  @override
  String recommendedChainUpdated(String chain) {
    return 'Đã cập nhật chain ưu tiên thành $chain';
  }

  @override
  String get managedWalletsSection => 'Ví';

  @override
  String managedWalletsTotalCount(int count) {
    return '$count ví';
  }

  @override
  String get managedWalletsNewWallet => 'Ví mới';

  @override
  String get managedWalletsActiveDefaults => 'Địa chỉ nạp tiền mặc định';

  @override
  String get managedWalletsNotConfigured => 'Chưa cấu hình';

  @override
  String get managedWalletsRecommendedChainTitle =>
      'Chain ưu tiên cho người dùng';

  @override
  String get managedWalletsRecommendedChainDesc =>
      'Người dùng sẽ thấy chain này là tùy chọn nạp tiền chính.';

  @override
  String get managedWalletsRecommendedChainLabel => 'Chain ưu tiên';

  @override
  String get managedWalletsSelectChain => 'Chọn chain';

  @override
  String get managedWalletsNoWallets => 'Chưa có ví nào';

  @override
  String get managedWalletsNoWalletsDesc =>
      'Hãy tạo ví Tron ở Cấu hình thanh toán → Ví vận hành (mục đích DEPOSIT hoặc BOTH), sau đó chọn ví mặc định nhận nạp theo từng chain tại đây.';

  @override
  String get managedWalletsCreateFirst => 'Tạo ví đầu tiên';

  @override
  String get walletSetAsDefault => 'Đã đặt làm địa chỉ nạp tiền mặc định';

  @override
  String get walletDeactivated => 'Đã vô hiệu hóa ví';

  @override
  String get deactivateWalletTitle => 'Vô hiệu hóa ví';

  @override
  String get deactivateWalletContent =>
      'Ví này sẽ bị vô hiệu hóa và không thể nhận hoặc gửi tiền nữa. Thao tác này không thể hoàn tác.';

  @override
  String get deactivateWalletAction => 'Vô hiệu hóa';

  @override
  String get managedWalletOnchainBalance => 'Số dư on-chain';

  @override
  String get managedWalletSetDefault => 'Đặt làm mặc định';

  @override
  String get managedWalletDefaultDeposit => 'Nạp tiền mặc định';

  @override
  String get managedWalletClearDefaultDeposit => 'Gỡ mặc định';

  @override
  String get managedWalletClearDefaultDepositTitle => 'Gỡ ví nạp mặc định?';

  @override
  String get managedWalletClearDefaultDepositBody =>
      'Chain này sẽ không còn địa chỉ nạp mặc định cho đến khi bạn chọn ví khác. Nạp on-chain cho mạng này tạm dừng cho đến lúc đó.';

  @override
  String get managedWalletClearDefaultDepositAction => 'Gỡ mặc định';

  @override
  String get managedWalletClearDefaultDepositSuccess =>
      'Đã gỡ địa chỉ nạp mặc định.';

  @override
  String get managedWalletSendTrx => 'Gửi TRX';

  @override
  String get managedWalletTxHistory => 'Lịch sử giao dịch';

  @override
  String get managedWalletNoTx => 'Chưa có giao dịch nào';

  @override
  String get sendTrxTitle => 'Gửi TRX';

  @override
  String get sendTrxConfirmTitle => 'Xác nhận gửi';

  @override
  String sendTrxConfirmContent(String amount, String address) {
    return 'Gửi $amount TRX tới\n$address?';
  }

  @override
  String get sendTrxConfirm => 'Xác nhận';

  @override
  String get sendTrxRecipientLabel => 'Địa chỉ nhận';

  @override
  String get sendTrxRecipientHint => 'T...';

  @override
  String get sendTrxAddressRequired => 'Địa chỉ là bắt buộc';

  @override
  String get sendTrxInvalidAddress => 'Địa chỉ không hợp lệ';

  @override
  String get sendTrxAmountLabel => 'Số lượng (TRX)';

  @override
  String get sendTrxAmountHint => '0.00';

  @override
  String get sendTrxAmountRequired => 'Số lượng là bắt buộc';

  @override
  String get sendTrxAmountInvalid => 'Nhập số lượng hợp lệ';

  @override
  String get sendTrxSending => 'Đang gửi...';

  @override
  String get sendTrxSend => 'Gửi';

  @override
  String get sendTrxSuccess => 'Giao dịch đã được gửi thành công';

  @override
  String get createWalletTitle => 'Tạo ví kho quỹ';

  @override
  String get createWalletBlockchainLabel => 'Blockchain';

  @override
  String get createWalletLabelField => 'Nhãn (không bắt buộc)';

  @override
  String get createWalletLabelHint => 'vd: Quỹ chính, Dự phòng AML';

  @override
  String get createWalletGenerating => 'Đang tạo...';

  @override
  String get createWalletGenerate => 'Tạo ví';

  @override
  String get createWalletSecurityNote =>
      'Một ví Tron mới sẽ được tạo. Khóa riêng tư được mã hóa và lưu trữ an toàn. Bạn sẽ không bao giờ được hiển thị khóa riêng tư.';

  @override
  String get createWalletSuccess => 'Đã tạo ví!';

  @override
  String get createWalletAddressLabel => 'Địa chỉ ví';

  @override
  String get createWalletAddressCopied => 'Đã sao chép địa chỉ';

  @override
  String get createWalletDone => 'Xong';

  @override
  String get createWalletFailed => 'Không thể tạo ví';

  @override
  String get walletBadgeDefault => 'MẶC ĐỊNH';

  @override
  String get walletBadgeInactive => 'KHÔNG HOẠT ĐỘNG';

  @override
  String get depositMethodsTitle => 'Phương thức nạp tiền của sàn';

  @override
  String get depositMethodRecommended => 'Khuyến nghị';

  @override
  String get depositMethodUnavailable => 'Chưa mở nạp';

  @override
  String get copyAddressTooltip => 'Sao chép địa chỉ';

  @override
  String get marketMakerHubTitle => 'Khu vực Market Maker';

  @override
  String get marketMakerHubDrawerSubtitle =>
      'Dashboard · Cấu hình · Lệnh Maker';

  @override
  String get marketMakerConfigCardTitle => 'Cấu hình Market Maker';

  @override
  String get marketMakerConfigCardSubtitle =>
      'Quản lý spread, stop-loss và giới hạn vị thế theo cặp giao dịch.';

  @override
  String get marketMakerPlaceOrdersCardTitle => 'Đặt lệnh Maker';

  @override
  String get marketMakerPlaceOrdersCardSubtitle =>
      'Đặt cặp lệnh BUY/SELL quanh giá thị trường bằng batch orders.';

  @override
  String get marketMakerPositionDashboardCardTitle => 'Dashboard vị thế';

  @override
  String get marketMakerPositionDashboardCardSubtitle =>
      'Theo dõi lệnh mở, vị thế và P/L chưa thực hiện theo thời gian thực.';

  @override
  String get marketMakerDashboardComingSoon => 'Dashboard vị thế — sắp ra mắt';

  @override
  String get marketMakerFieldPair => 'Cặp giao dịch';

  @override
  String get marketMakerFieldSpreadBps => 'Spread (bps)';

  @override
  String get marketMakerFieldSpreadAlertBps => 'Ngưỡng cảnh báo spread (bps)';

  @override
  String get marketMakerFieldOrderAmount => 'Khối lượng lệnh';

  @override
  String get marketMakerFieldStopLossOptional => 'Stop-loss % (tùy chọn)';

  @override
  String get marketMakerFieldMaxPositionBaseOptional =>
      'Vị thế tối đa – base (tùy chọn)';

  @override
  String get marketMakerFieldActiveConfig => 'Kích hoạt cấu hình';

  @override
  String get marketMakerFieldOrderAmountOverrideOptional =>
      'Ghi đè khối lượng lệnh (tùy chọn)';

  @override
  String get marketMakerFieldRefreshCycleKeyOptional =>
      'Khóa chu kỳ làm mới (idempotency, tùy chọn)';

  @override
  String get marketMakerButtonSaveConfig => 'Lưu cấu hình';

  @override
  String get marketMakerButtonDelete => 'Xóa';

  @override
  String get marketMakerButtonPlaceTwoSidedOrders => 'Đặt lệnh maker hai chiều';

  @override
  String get marketMakerValidationSpreadBps => 'Spread (bps) không hợp lệ';

  @override
  String get marketMakerValidationAlertThreshold =>
      'Ngưỡng cảnh báo không hợp lệ';

  @override
  String get marketMakerValidationOrderAmount => 'Khối lượng lệnh không hợp lệ';

  @override
  String get marketMakerNoActivePairs =>
      'Không có cặp giao dịch đang hoạt động';

  @override
  String marketMakerLastUpdated(String when) {
    return 'Cập nhật lần cuối: $when';
  }

  @override
  String get marketMakerSnackSavedConfig => 'Đã lưu cấu hình market maker';

  @override
  String get marketMakerSnackSaveFailed => 'Lưu thất bại';

  @override
  String get marketMakerSnackDeletedConfig => 'Đã xóa cấu hình market maker';

  @override
  String get marketMakerSnackDeleteFailed => 'Xóa thất bại';

  @override
  String get marketMakerSnackPlaceOrdersFailed => 'Đặt lệnh maker thất bại';

  @override
  String get marketMakerOrdersResultReplayed => 'Đã phát lại';

  @override
  String get marketMakerOrdersResultRefreshed => 'Đã làm mới';

  @override
  String marketMakerOrdersPlacedSummary(String action, String cancelled,
      String placed, String buyPrice, String sellPrice) {
    return '$action: đã hủy $cancelled, đặt $placed (MUA: $buyPrice, BÁN: $sellPrice)';
  }

  @override
  String get marketMakerPlaceOrdersFormHint =>
      'Dùng cấu hình đã lưu cho cặp đã chọn. Có thể ghi đè khối lượng hoặc khóa idempotency.';

  @override
  String get adminCurrenciesTitle => 'Quản lý - Tiền tệ';

  @override
  String get adminCurrenciesCreateTitle => 'Tạo coin mới';

  @override
  String get adminCurrenciesDeleteTitle => 'Xoá coin';

  @override
  String get adminCurrenciesDeleteConfirmMessage =>
      'Bạn có chắc muốn xoá coin này?';

  @override
  String adminCurrenciesEditTitle(String symbol) {
    return 'Chỉnh sửa $symbol';
  }

  @override
  String get adminCurrenciesEdit => 'Chỉnh sửa';

  @override
  String get adminCurrenciesCancel => 'Huỷ';

  @override
  String get adminCurrenciesCreateAction => 'Tạo';

  @override
  String get adminCurrenciesSaveAction => 'Lưu';

  @override
  String get adminCurrenciesDeleteAction => 'Xoá';

  @override
  String get adminCurrenciesHide => 'Ẩn';

  @override
  String get adminCurrenciesShow => 'Hiển thị';

  @override
  String get adminCurrenciesTradableLabel => 'Giao dịch';

  @override
  String get adminCurrenciesActiveLabel => 'Hoạt động';

  @override
  String get adminCurrenciesStatusLabel => 'Trạng thái';

  @override
  String get adminCurrenciesNameInputLabel => 'Tên';

  @override
  String get adminCurrenciesPrecisionScaleLabel => 'Số chữ số thập phân';

  @override
  String get adminCurrenciesMinWithdrawLabel => 'Rút tối thiểu';

  @override
  String get adminCurrenciesFieldRequired => 'Bắt buộc';

  @override
  String get adminCurrenciesRetryAction => 'Thử lại';

  @override
  String get adminCurrenciesCreateNewCoin => 'Tạo coin mới';

  @override
  String get adminCurrenciesNoData => 'Không có dữ liệu';

  @override
  String get adminCurrenciesSymbolLabel => 'Mã';

  @override
  String get adminCurrenciesCreateSuccess => 'Đã tạo coin thành công!';

  @override
  String get adminCurrenciesUpdateSuccess => 'Đã cập nhật coin thành công!';

  @override
  String get adminCurrenciesDeleteSuccess => 'Đã xoá coin thành công!';

  @override
  String get depositDetailStatus => 'Trạng thái';

  @override
  String get depositDetailOrderCode => 'Mã đơn';

  @override
  String get depositDetailCopied => 'Đã sao chép';

  @override
  String get depositDetailCreatedAt => 'Tạo lúc';

  @override
  String get depositDetailUpdatedAt => 'Cập nhật lúc';

  @override
  String get depositDetailUserId => 'ID người dùng';

  @override
  String get depositDetailViewUser => 'Xem người dùng';

  @override
  String get depositStatusPaid => 'Đã thanh toán';

  @override
  String get depositStatusPending => 'Đang chờ';

  @override
  String get depositStatusCancelled => 'Đã hủy';

  @override
  String get withdrawalDetailInfoTitle => 'Thông tin rút tiền';

  @override
  String get withdrawalDetailAmount => 'Số lượng';

  @override
  String get withdrawalDetailChain => 'Chain';

  @override
  String get withdrawalDetailStatus => 'Trạng thái';

  @override
  String get withdrawalDetailCopied => 'Đã sao chép';

  @override
  String get withdrawalDetailAddress => 'Địa chỉ';

  @override
  String get withdrawalDetailTxHash => 'Hash giao dịch';

  @override
  String get withdrawalDetailCreatedAt => 'Tạo lúc';

  @override
  String get withdrawalDetailUpdatedAt => 'Cập nhật lúc';

  @override
  String get withdrawalDetailUserId => 'ID người dùng';

  @override
  String get withdrawalDetailViewUser => 'Xem người dùng';

  @override
  String get withdrawalStatusCompleted => 'Hoàn thành';

  @override
  String get withdrawalStatusConfirming => 'Đang xác nhận';

  @override
  String get withdrawalStatusPending => 'Đang chờ';

  @override
  String get withdrawalStatusFailed => 'Thất bại';

  @override
  String get withdrawalDetailTitle => 'Chi tiết rút tiền';

  @override
  String get withdrawalNotFound => 'Không tìm thấy yêu cầu rút tiền';

  @override
  String get withdrawalApprovedSnack => 'Đã phê duyệt rút tiền';

  @override
  String get withdrawalApproveButton => 'Phê duyệt';

  @override
  String get withdrawalRejectButton => 'Từ chối';

  @override
  String get withdrawalRejectDialogTitle => 'Từ chối rút tiền';

  @override
  String get withdrawalRejectReasonHint => 'Lý do (tùy chọn)';

  @override
  String get withdrawalRejectedSnack => 'Đã từ chối rút tiền';

  @override
  String get withdrawalUserInfoTitle => 'Thông tin người dùng';

  @override
  String get withdrawalBalanceLabel => 'Số dư';

  @override
  String get withdrawalTransactionTitle => 'Thông tin giao dịch';

  @override
  String get withdrawalNetworkLabel => 'Mạng lưới';

  @override
  String get withdrawalAmountLabel => 'Số lượng';

  @override
  String get withdrawalDestinationLabel => 'Đích đến';

  @override
  String get withdrawalTimeLabel => 'Thời gian';

  @override
  String get withdrawalTxHashLabel => 'Tx Hash';

  @override
  String get withdrawalStatusRequested => 'Đã yêu cầu';

  @override
  String get withdrawalStatusApproved => 'Đã phê duyệt';

  @override
  String get withdrawalStatusSent => 'Đã gửi';

  @override
  String get withdrawalStatusLabel => 'Trạng thái';

  @override
  String get withdrawalStatusRejected => 'Đã từ chối';

  @override
  String get adminCurrenciesSearchHint => 'Tìm kiếm tiền tệ...';

  @override
  String get adminCurrenciesFilterAll => 'Tất cả';

  @override
  String get adminCurrenciesFilterActive => 'Hoạt động';

  @override
  String get adminCurrenciesFilterInactive => 'Ngừng';

  @override
  String get adminCurrenciesTradingLabel => 'Giao dịch';

  @override
  String get adminCurrenciesFilterTradable => 'Có thể giao dịch';

  @override
  String get adminCurrenciesFilterPaused => 'Tạm dừng';

  @override
  String get adminCurrenciesNoCoinsFound => 'Không tìm thấy coin';

  @override
  String get adminCurrenciesCreateCoin => 'Tạo coin';

  @override
  String adminCurrenciesDeleteConfirmWithPair(String symbol, String name) {
    return 'Bạn có chắc muốn xoá \"$symbol — $name\"?\nThao tác này không thể hoàn tác.';
  }

  @override
  String adminCurrenciesListMeta(String precision, String minWithdraw) {
    return 'Độ chính xác: $precision · Rút tối thiểu: $minWithdraw';
  }

  @override
  String get adminCurrenciesTradableBadgeOn => 'GD';

  @override
  String get adminCurrenciesTradableBadgeOff => 'Tắt';

  @override
  String get adminCurrenciesTradingPausedTooltip => 'Tạm dừng giao dịch';

  @override
  String adminShowingCount(int shown, int total, String label) {
    return 'Hiển thị $shown trong $total $label';
  }

  @override
  String get adminRetryButton => 'Thử lại';

  @override
  String payosTransitioningBanner(int minutes) {
    return 'Phương thức thanh toán PayOS sẽ được kích hoạt trong $minutes phút';
  }

  @override
  String payosTransitioningGraceMinutes(int minutes) {
    return 'Kích hoạt trong $minutes phút';
  }

  @override
  String get payosTransitioningUnderOneMinute =>
      'PayOS sẽ được kích hoạt trong chưa đầy một phút';

  @override
  String get payosTransitioningFinalizePending =>
      'Đang hoàn tất kích hoạt PayOS — vui lòng chờ';

  @override
  String get dismiss => 'Bỏ qua';

  @override
  String get snackbarOk => 'Đồng ý';

  @override
  String get adminUserDetailTabWallets => 'Ví';

  @override
  String get adminUserDetailTabAdjust => 'Điều chỉnh';

  @override
  String get adminUserDetailTabOrders => 'Lệnh';

  @override
  String get adminUserDetailTabOnchain => 'On-chain';

  @override
  String get adminUserDetailTabSecurity => 'Bảo mật';

  @override
  String get adminUserDetailCreatedAtLabel => 'Tạo lúc';

  @override
  String get withdrawalManagementTitle => 'Quản lý rút tiền';

  @override
  String get withdrawalManagementTabPending => 'Đang chờ';

  @override
  String get withdrawalManagementTabAll => 'Tất cả';

  @override
  String get withdrawalApproveAllSmallTitle => 'Phê duyệt tất cả';

  @override
  String get withdrawalApproveAllSmallContent =>
      'Phê duyệt tất cả lần rút tiền đang chờ?';

  @override
  String get withdrawalApproveAllProcess => 'Đang xử lý...';

  @override
  String get withdrawalProcessedSnack => 'Xử lý lần rút tiền thành công';

  @override
  String withdrawalStatsPendingCount(int count) {
    return '$count đang chờ';
  }

  @override
  String get adminFilterAll => 'Tất cả';

  @override
  String get withdrawalSearchHint =>
      'Tìm theo ID người dùng hoặc địa chỉ ví...';

  @override
  String get withdrawalNoRequests => 'Không có yêu cầu rút tiền';

  @override
  String get drawerTransactionMonitoring => 'Giám sát giao dịch';

  @override
  String get adminTabOrders => 'Lệnh';

  @override
  String get adminTabDeposits => 'Nạp tiền';

  @override
  String get adminTabWithdrawals => 'Rút tiền';

  @override
  String get orderStatusOpen => 'Đang mở';

  @override
  String get orderStatusPartial => 'Đã điền một phần';

  @override
  String get orderStatusFilled => 'Đã điền đầy đủ';

  @override
  String get orderStatusCancelled => 'Đã hủy';

  @override
  String get orderStatusRejected => 'Đã từ chối';

  @override
  String get filterByUserId => 'Lọc theo ID người dùng';

  @override
  String get adminPairIdFilterHint =>
      'pair_id (UUID) hoặc ký hiệu OG/USDT — lọc & khớp lại';

  @override
  String get adminReconcileMatchingButton => 'Khớp lại lệnh';

  @override
  String get adminReconcileMatchingPairRequired =>
      'Nhập pair_id (UUID) hoặc ký hiệu BASE/QUOTE.';

  @override
  String get adminOrderPairIdLabel => 'pair_id';

  @override
  String get adminOrderPairIdCopyTooltip => 'Sao chép pair_id vào ô khớp lại';

  @override
  String get adminOrderPairIdCopied => 'Đã sao chép pair_id';

  @override
  String get adminReconcileMatchingConfirmTitle => 'Chạy khớp lại lệnh?';

  @override
  String adminReconcileMatchingConfirmMessage(String pairId) {
    return 'Thử khớp lại mọi lệnh đang mở trên cặp: $pairId';
  }

  @override
  String get adminReconcileMatchingRun => 'Chạy';

  @override
  String get adminReconcileMatchingCancel => 'Hủy';

  @override
  String adminReconcileMatchingSuccess(int trades, int open, String reason) {
    return 'Hoàn tất. Giao dịch khớp: $trades, còn mở: $open, kết quả: $reason';
  }

  @override
  String get adminReconcileReasonAllMatched => 'đã khớp hết';

  @override
  String get adminReconcileReasonNoProgress => 'không còn khớp được';

  @override
  String get adminReconcileReasonMaxRounds => 'dừng (giới hạn an toàn)';

  @override
  String get adminOrdersEmpty => 'Không có lệnh';

  @override
  String adminOrdersCountLabel(int count) {
    return '$count lệnh';
  }

  @override
  String get adminDepositsEmpty => 'Không có lần nạp tiền';

  @override
  String adminDepositsCountLabel(int count) {
    return '$count lần nạp tiền';
  }

  @override
  String get adminWithdrawalsEmpty => 'Không có lần rút tiền';

  @override
  String adminWithdrawalsCountLabel(int count) {
    return '$count lần rút tiền';
  }

  @override
  String get orderDetailTypeLimitLabel => 'Giới hạn';

  @override
  String get orderDetailTypeMarketLabel => 'Thị trường';

  @override
  String get adminOrderListBuyPriceLabel => 'Giá mua';

  @override
  String get adminOrderListSellPriceLabel => 'Giá bán';

  @override
  String get adminOrderListMarketPriceHint => '(Lệnh thị trường)';

  @override
  String get adminUserLabel => 'Người dùng';

  @override
  String get orderDetailAmount => 'Số lượng';

  @override
  String get orderDetailPrice => 'Giá';

  @override
  String get adminOrderCodeLabel => 'Mã lệnh';

  @override
  String get adminTxHashLabel => 'Hash giao dịch';

  @override
  String get orderDetailSideBuy => 'Mua';

  @override
  String get orderDetailSideSell => 'Bán';

  @override
  String get orderDetailOrderId => 'ID lệnh';

  @override
  String get orderDetailCopied => 'Đã sao chép';

  @override
  String get orderDetailPair => 'Cặp';

  @override
  String get orderDetailSide => 'Chiều';

  @override
  String get orderDetailType => 'Loại';

  @override
  String get orderDetailTimeInForce => 'Hiệu lực lệnh';

  @override
  String get orderDetailFilledAmount => 'Khớp';

  @override
  String get orderDetailAvgPrice => 'Giá khớp TB';

  @override
  String get orderDetailRemainingAmount => 'Còn lại';

  @override
  String get orderDetailFilledPct => '% khớp';

  @override
  String get orderDetailCreatedAt => 'Tạo lúc';

  @override
  String get orderDetailUpdatedAt => 'Cập nhật lúc';

  @override
  String get orderDetailUserId => 'ID người dùng';

  @override
  String get orderDetailViewUser => 'Xem người dùng';

  @override
  String get depositDetailTitle => 'Chi tiết nạp tiền';

  @override
  String get depositDetailAmount => 'Số tiền';

  @override
  String get drawerSectionGeneral => 'Chung';

  @override
  String get drawerSectionAdministration => 'Quản trị';

  @override
  String get drawerSectionAdminUsers => 'Người dùng quản trị';

  @override
  String get drawerSectionAdminOps => 'Vận hành quản trị';

  @override
  String get drawerTransactionMonitoringSubtitle => 'Lệnh, nạp tiền, rút tiền';

  @override
  String get drawerCoinManagement => 'Quản lý coin';

  @override
  String get drawerCoinManagementSubtitleCrud => 'Tạo, sửa, xóa';

  @override
  String get drawerCoinManagementSubtitleView => 'Chỉ xem tiền tệ';

  @override
  String get drawerSectionAdminSystem => 'Hệ thống quản trị';

  @override
  String get drawerSectionFinance => 'Tài chính';

  @override
  String get drawerPaymentConfig => 'Cấu hình thanh toán';

  @override
  String get drawerPaymentConfigSubtitle => 'Phương thức, ví, kích hoạt';

  @override
  String get drawerTreasuryMainWalletsTitle => 'Ví Hot Wallet Hệ Thống';

  @override
  String get drawerTreasuryMainWalletsSubtitle => 'Quản lý khóa, duyệt, MFA';

  @override
  String get treasuryMainWalletsTitle => 'Quản lý Hot Wallet Hệ Thống';

  @override
  String get treasuryMainWalletsTabActive => 'Ví đang hoạt động';

  @override
  String get treasuryMainWalletsTabPending => 'Chờ duyệt';

  @override
  String get treasuryMainWalletsEmptyActive =>
      'Chưa có ví chính đang hoạt động.';

  @override
  String get treasuryMainWalletsEmptyPending =>
      'Không có ví nào đang chờ duyệt.';

  @override
  String get treasuryMainWalletChipDefault => 'Mặc định';

  @override
  String get treasuryMainWalletLabelNone => 'Không có';

  @override
  String get treasuryMainWalletTooltipSetDefault => 'Đặt làm mặc định';

  @override
  String get treasuryMainWalletTooltipApprove => 'Duyệt';

  @override
  String get treasuryMainWalletTooltipReject => 'Từ chối';

  @override
  String get treasuryMainWalletUnknownTime => 'Không rõ';

  @override
  String treasuryMainWalletCardSubtitle(
      String balance, String symbol, String label) {
    return 'Số dư: $balance $symbol\nNhãn: $label';
  }

  @override
  String treasuryMainWalletPendingSubtitle(String dateTime) {
    return 'Thêm lúc: $dateTime';
  }

  @override
  String treasuryTrc20UsdtBalanceLine(String balance) {
    return 'Tether USDT (TRC-20): $balance';
  }

  @override
  String treasuryMainWalletBalanceLine(String balance, String symbol) {
    return 'Số dư: $balance $symbol';
  }

  @override
  String treasuryMainWalletLabelLine(String label) {
    return 'Nhãn: $label';
  }

  @override
  String get treasuryMainWalletPublicAddressLabel =>
      'Địa chỉ công khai (public)';

  @override
  String get treasuryMainWalletCopyAddressTooltip =>
      'Sao chép địa chỉ công khai';

  @override
  String get treasuryMainWalletCopiedAddressSnack =>
      'Đã sao chép địa chỉ công khai.';

  @override
  String get treasuryMainWalletRevealPrivateKeyTooltip =>
      'Private key (OTP email)';

  @override
  String get treasuryMainWalletMenuCopyPrivateKey => 'Sao chép private key';

  @override
  String get treasuryMainWalletMenuEditLabel => 'Sửa nhãn';

  @override
  String get treasuryMainWalletMenuDelete => 'Yêu cầu xóa (cần Risk duyệt)';

  @override
  String get treasuryMainWalletRevealKeyTitle => 'Sao chép private key';

  @override
  String get treasuryMainWalletRevealKeyHint =>
      'Gửi OTP về email, nhập mã, rồi sao chép khóa.';

  @override
  String get treasuryMainWalletRevealKeyCopy => 'Hiện và sao chép';

  @override
  String get treasuryMainWalletCopiedPrivateKeySnack =>
      'Đã sao chép private key vào clipboard.';

  @override
  String get treasuryMainWalletEditLabelTitle => 'Sửa nhãn';

  @override
  String get treasuryMainWalletEditLabelSave => 'Lưu';

  @override
  String get treasuryMainWalletLabelUpdatedSnack => 'Đã cập nhật nhãn.';

  @override
  String get treasuryMainWalletDeleteTitle => 'Gửi yêu cầu xóa ví?';

  @override
  String get treasuryMainWalletDeleteBody =>
      'Risk Officer phải phê duyệt trước khi ví bị xóa khỏi hệ thống. Không thể yêu cầu xóa ví mặc định nếu còn ví active khác trên cùng chain.';

  @override
  String get treasuryMainWalletDeleteSuccessSnack =>
      'Đã gửi yêu cầu xóa — chờ Risk phê duyệt.';

  @override
  String get treasuryMainWalletDeleteAction => 'Gửi yêu cầu';

  @override
  String get treasuryMainWalletChipPendingDeletion => 'Chờ duyệt xóa';

  @override
  String get treasuryMainWalletPendingDeletionHint =>
      'Đang chờ Risk phê duyệt xóa. Ví không dùng cho Cấp vốn/Gom trong lúc này.';

  @override
  String get treasuryMainWalletTooltipApproveDeletion =>
      'Phê duyệt xóa (gỡ ví khỏi hệ thống)';

  @override
  String get treasuryMainWalletTooltipRejectDeletion =>
      'Từ chối xóa (khôi phục ví)';

  @override
  String get treasuryChainTronNile => 'TRON — Testnet Nile';

  @override
  String get treasuryChainTronMainnet => 'TRON — Mainnet';

  @override
  String get treasuryChainBscTestnet => 'BNB Smart Chain — Testnet';

  @override
  String get treasuryChainBscMainnet => 'BNB Smart Chain — Mainnet';

  @override
  String get treasuryChainSolanaDevnet => 'Solana — Devnet';

  @override
  String get treasuryChainSolanaMainnet => 'Solana — Mainnet';

  @override
  String get treasuryChainTronShasta => 'TRON — Testnet Shasta';

  @override
  String get treasuryChainEthSepolia => 'Ethereum — Sepolia';

  @override
  String get treasuryChainEthMainnet => 'Ethereum — Mainnet';

  @override
  String treasuryImportWalletDialogTitle(String chainName) {
    return 'Nhập ví chính ($chainName)';
  }

  @override
  String get treasuryImportWalletLabelOptional => 'Nhãn (tuỳ chọn)';

  @override
  String get treasuryImportWalletPrivateKey => 'Khóa bí mật';

  @override
  String get treasuryImportWalletMfaCode => 'Mã MFA';

  @override
  String get treasuryImportWalletSendOtp => 'Gửi OTP';

  @override
  String get treasuryImportWalletImport => 'Nhập ví';

  @override
  String get treasuryImportWalletMfaSentSnack =>
      'Đã gửi mã MFA tới email của bạn.';

  @override
  String treasuryImportWalletMfaFailedSnack(String error) {
    return 'Gửi MFA thất bại: $error';
  }

  @override
  String get treasuryImportWalletRequiredSnack =>
      'Cần nhập khóa bí mật và mã MFA.';

  @override
  String get treasuryImportWalletOtpStepHint =>
      'Nhấn Gửi OTP, nhập mã trong email, rồi Xác nhận mã. Chỉ sau khi mã đúng bạn mới nhập nhãn và khóa bí mật.';

  @override
  String get treasuryImportWalletConfirmOtp => 'Xác nhận mã';

  @override
  String get treasuryImportWalletOtpEmpty => 'Nhập mã OTP trong email.';

  @override
  String treasuryImportWalletOtpVerifyFailed(String message) {
    return 'Không xác nhận được: $message';
  }

  @override
  String get treasuryImportWalletPrivateKeyRequired => 'Cần nhập khóa bí mật.';

  @override
  String get treasuryImportWalletMistakeTronAddress =>
      'Chuỗi này giống địa chỉ TRON (bắt đầu bằng T), không phải private key. Hãy dán khóa hex 64 ký tự khi xuất từ ví.';

  @override
  String get treasuryImportWalletMistakeEvmAddress =>
      'Chuỗi này giống địa chỉ ví EVM (0x…), không phải private key. Hãy dán khóa hex 64 ký tự khi xuất từ ví.';

  @override
  String get treasuryImportWalletSuccessSnack =>
      'Đã thêm ví vào danh sách chờ duyệt.';

  @override
  String treasuryImportWalletErrorSnack(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get treasuryImportWalletMfaExpiredOnImport =>
      'Mã email đã hết hạn hoặc đã dùng. Nhấn Gửi OTP để lấy mã mới, xác nhận mã, rồi nhập ví lại.';

  @override
  String get treasuryImportWalletMfaExpiredOnImportSnack =>
      'Mã OTP hết hạn hoặc không hợp lệ. Nhấn Gửi OTP để lấy mã mới.';

  @override
  String get drawerWithdrawalManagement => 'Quản lý rút tiền';

  @override
  String get drawerWithdrawalManagementSubtitle => 'Duyệt và xử lý yêu cầu';

  @override
  String get drawerManagedWalletsTitle => 'Nạp tiền & ví quản lý';

  @override
  String get drawerManagedWalletsSubtitle =>
      'Địa chỉ nạp mặc định, chain ưu tiên, ví công ty';

  @override
  String get drawerBlockchainHubTitle => 'Trung tâm on-chain';

  @override
  String get drawerBlockchainHubSubtitle =>
      'Nạp/rút on-chain, công cụ blockchain';

  @override
  String get drawerSectionTreasuryDeposits => 'Kho quỹ & nạp tiền';

  @override
  String managedWalletOwnerHint(String userIdShort) {
    return 'Chủ ví: $userIdShort';
  }

  @override
  String get drawerSectionAccount => 'Tài khoản';

  @override
  String get profileFirstName => 'Tên';

  @override
  String get profileLastName => 'Họ';

  @override
  String get ordersPayosUsdtHint =>
      'Dùng PayOS để nạp VND và mua USDT để giao dịch.';

  @override
  String get priceHintExample => 'vd: 65000';

  @override
  String get amountHintExample => 'vd: 0.01';

  @override
  String get maxAmountButton => 'TỐI ĐA';

  @override
  String amountMaxDecimals(int max) {
    return 'Số lượng tối đa $max chữ số thập phân';
  }

  @override
  String get priceMustBePositive => 'Giá phải lớn hơn 0';

  @override
  String priceMaxDecimals(int max) {
    return 'Giá tối đa $max chữ số thập phân';
  }

  @override
  String get tickerBid => 'Giá mua';

  @override
  String get tickerAsk => 'Giá bán';

  @override
  String get ticker24hHigh => 'Đỉnh 24h';

  @override
  String get ticker24hLow => 'Đáy 24h';

  @override
  String get tickerVolume => 'Khối lượng';

  @override
  String get orderColumnSide => 'Chiều';

  @override
  String get orderColumnTime => 'Thời gian';

  @override
  String timeSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String timeMinutesShort(int minutes) {
    return '${minutes}p';
  }

  @override
  String timeHoursShort(int hours) {
    return '${hours}g';
  }

  @override
  String get ordersSelectPairFirst => 'Vui lòng chọn cặp giao dịch trước';

  @override
  String get myOrdersEmpty => 'Chưa có lệnh mở';

  @override
  String ordersMyOrdersWithCount(int count) {
    return 'Lệnh của tôi ($count)';
  }

  @override
  String get orderBookColumnSize => 'Khối lượng';

  @override
  String get orderBookColumnCount => 'Số lệnh';

  @override
  String get marketPriceAbbrev => 'TT';

  @override
  String get orderFilledQuantity => 'Đã khớp';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsSeedColor => 'Màu chủ đạo';

  @override
  String get walletDebugTitle => 'Gỡ lỗi ví';

  @override
  String get adminUserListRoleAll => 'Tất cả vai trò';

  @override
  String get adminUserListRoleTrader => 'Trader';

  @override
  String get adminUserListRoleVerified => 'Người dùng đã xác minh';

  @override
  String get adminUserListRoleMarketMaker => 'Market maker';

  @override
  String get adminUserListRoleSupport => 'Hỗ trợ';

  @override
  String get adminUserListRoleRiskOfficer => 'Kiểm soát rủi ro';

  @override
  String get adminUserListRoleAdmin => 'Quản trị viên';

  @override
  String get adminUserListRoleFinanceManager => 'Quản lý tài chính';

  @override
  String get adminUserListRoleGuest => 'Khách';

  @override
  String get adminUserListStatusActive => 'Hoạt động';

  @override
  String get adminUserListStatusBanned => 'Bị khóa';

  @override
  String get adminUserListStatusPending => 'Chờ duyệt';

  @override
  String get adminUserListTitle => 'Danh sách người dùng quản trị';

  @override
  String get adminUserListSearchHint => 'Tìm theo tên, email hoặc ID';

  @override
  String get adminUserListRoleLabel => 'Vai trò';

  @override
  String get adminUserListStatusLabel => 'Trạng thái';

  @override
  String adminUserListTotalUsers(int count) {
    return 'Tổng người dùng: $count';
  }

  @override
  String get adminUserListNoUsersFound => 'Không tìm thấy người dùng';

  @override
  String get adminUserListSelectUserPlaceholder =>
      'Chọn người dùng để xem chi tiết';

  @override
  String get adminUserDetailNoteLabel => 'Ghi chú';

  @override
  String get adminWalletAdjustSelectUserRequired => 'Vui lòng chọn người dùng';

  @override
  String get adminWalletAdjustError => 'Điều chỉnh thất bại';

  @override
  String get adminWalletAdjustUserIdRequired => 'ID người dùng là bắt buộc';

  @override
  String get adminWalletAdjustTitle => 'Điều chỉnh ví';

  @override
  String get adminWalletAdjustDepositWithdrawTab => 'Nạp/Rút';

  @override
  String get adminWalletAdjustHistoryTab => 'Lịch sử';

  @override
  String get adminWalletAdjustUseUserMgmt => 'Dùng quản lý người dùng';

  @override
  String get adminWalletAdjustUseUserMgmtSubtitle =>
      'Chọn người dùng từ danh sách quản trị';

  @override
  String get adminWalletAdjustOpen => 'Mở';

  @override
  String get adminWalletAdjustOperationType => 'Loại thao tác';

  @override
  String get adminWalletAdjustInfo => 'Thông tin điều chỉnh';

  @override
  String get adminWalletAdjustSelectUserHint => 'Nhập ID người dùng';

  @override
  String get adminWalletAdjustAmountLabel => 'Số tiền';

  @override
  String get adminWalletAdjustAmountHint => 'Nhập số tiền điều chỉnh';

  @override
  String get adminWalletAdjustAmountRequired => 'Số tiền là bắt buộc';

  @override
  String get adminWalletAdjustAmountInvalid => 'Số tiền không hợp lệ';

  @override
  String get adminWalletAdjustAmountMustBePositive => 'Số tiền phải lớn hơn 0';

  @override
  String get adminWalletAdjustNoteLabel => 'Ghi chú';

  @override
  String get adminWalletAdjustReasonHint => 'Lý do điều chỉnh';

  @override
  String get adminWalletAdjustDepositTab => 'Nạp';

  @override
  String get adminWalletAdjustWithdrawTab => 'Rút';

  @override
  String get adminWalletAdjustProcessing => 'Đang xử lý...';

  @override
  String get adminWalletAdjustDepositBalance => 'Nạp vào số dư';

  @override
  String get adminWalletAdjustWithdrawBalance => 'Rút khỏi số dư';

  @override
  String get adminWalletHistoryUserIdLabel => 'ID người dùng';

  @override
  String get adminWalletSearchUserIdHint => 'Tìm theo ID người dùng';

  @override
  String get adminWalletSearchButton => 'Tìm kiếm';

  @override
  String get adminWalletSearchByUserList => 'Tìm từ danh sách người dùng';

  @override
  String get adminWalletNoAdjustmentHistory => 'Không có lịch sử điều chỉnh';

  @override
  String get adminWalletTargetLabel => 'Đối tượng';

  @override
  String get adminWalletActorLabel => 'Người thao tác';

  @override
  String get homeLogoutConfirmTitle => 'Xác nhận đăng xuất';

  @override
  String get homeLogoutConfirmContent => 'Bạn có chắc muốn đăng xuất không?';

  @override
  String get homeLogoutCancel => 'Hủy';

  @override
  String get homeLogoutConfirm => 'Đăng xuất';

  @override
  String get homeFailedToLoadUser => 'Tải thông tin người dùng thất bại';

  @override
  String get homeGoToLogin => 'Đi tới đăng nhập';

  @override
  String get homeAppTitle => 'Trang chủ';

  @override
  String get homeWelcomeBack => 'Chào mừng trở lại';

  @override
  String get homeCryptoPlatform => 'Nền tảng giao dịch tiền mã hóa';

  @override
  String get homeAuthReady => 'Xác thực sẵn sàng';

  @override
  String get homeLastUpdated => 'Cập nhật lần cuối';

  @override
  String get wcLoginTitleWeb => 'Đăng nhập bằng ví (Web)';

  @override
  String get wcLoginTitleNative => 'Đăng nhập WalletConnect';

  @override
  String get wcReownDesktopUnsupportedBody =>
      'Chọn mạng, bấm «Tạo mã QR», quét bằng ví trên điện thoại và ký khi được hỏi.';

  @override
  String get wcReownMissingProjectId =>
      'Thiếu WALLETCONNECT_PROJECT_ID (hoặc REOWN_PROJECT_ID) trong .env';

  @override
  String wcReownInitFailed(String error) {
    return 'Không khởi tạo Reown: $error';
  }

  @override
  String get wcReownSessionNoEvmAddress =>
      'Session không có địa chỉ EVM (eip155). Chọn ví EVM / Sepolia.';

  @override
  String get wcReownNoSignature => 'Ví không trả về chữ ký.';

  @override
  String wcReownLoginError(String error) {
    return 'Lỗi đăng nhập WC: $error';
  }

  @override
  String get wcReownQrDescription =>
      'Mở QR, kết nối ví trên điện thoại, rồi ký message đăng nhập (Sepolia).';

  @override
  String get wcReownOpenQrButton => 'Mở QR WalletConnect (Reown)';

  @override
  String get wcAdvancedLegacyQrTitle => 'Khác: QR từ server';

  @override
  String get wcAdvancedLegacyQrSubtitle => 'Khi không dùng nút Reown phía trên';

  @override
  String get wcManualFlowIntroWeb =>
      'Tạo QR, quét bằng ví, ký đúng message rồi hoàn tất trên web.';

  @override
  String get wcManualFlowIntroNative =>
      'Tạo QR, quét bằng ví trên điện thoại; ứng dụng sẽ hoàn tất khi server nhận chữ ký.';

  @override
  String get wcNetworkLabel => 'Mạng';

  @override
  String get wcCreateQr => 'Tạo mã QR';

  @override
  String get wcCreateQrNew => 'Tạo mã QR mới';

  @override
  String get wcRelayDisabledBanner =>
      'Relay WalletConnect chưa bật trên server (thiếu project id). QR này không dùng để quét — cấu hình WALLETCONNECT_PROJECT_ID trên API, khởi động lại, tạo QR mới. Hoặc ký message rồi dán địa chỉ + chữ ký bên dưới.';

  @override
  String get wcQrFooterLoginShort =>
      'Quét bằng ví trên điện thoại, ký đúng message bên dưới.';

  @override
  String get wcMessageToSign => 'Message cần ký';

  @override
  String get wcCopyMessage => 'Sao chép message';

  @override
  String get wcMessageCopied => 'Đã sao chép message';

  @override
  String get wcCompletingLogin => 'Đang hoàn tất đăng nhập…';

  @override
  String get wcSignedWalletAddress => 'Địa chỉ ví đã ký';

  @override
  String get wcSignatureField => 'Chữ ký (signature)';

  @override
  String get wcVerifyAndLogin => 'Xác thực & đăng nhập';

  @override
  String get wcWebRecommendExtension =>
      'Tron: dùng TronLink trên Chrome. EVM: mở mục QR bên dưới.';

  @override
  String get wcWebAdvancedWcTitle => 'QR WalletConnect / dán chữ ký';

  @override
  String get wcWebAdvancedWcSubtitle =>
      'Máy tính, ví mobile hoặc không dùng extension';

  @override
  String get wcWebTronLinkExtension => 'TronLink (Chrome)';

  @override
  String get wcEnterAddressAndSignature => 'Nhập địa chỉ ví và chữ ký.';

  @override
  String get wcSessionExpiredCreateNew => 'Phiên đã hết hạn. Tạo mã QR mới.';

  @override
  String get desktopTronlinkDialogTitle => 'TronLink';

  @override
  String get desktopTronlinkDialogBody =>
      'Chỉ dùng TronLink trên Chrome (web). Trên app này: đăng nhập email hoặc mở bản web.';

  @override
  String get desktopTronlinkDialogOk => 'Đã hiểu';

  @override
  String get wcLinkDialogTitle => 'Liên kết ví điện tử';

  @override
  String get wcLinkDialogSubtitle => 'Kết nối bằng WalletConnect • Bảo mật cao';

  @override
  String get wcQrScanHintEvm =>
      'Mở Trust Wallet hoặc MetaMask Mobile → Scan QR';

  @override
  String get wcQrScanHintSolana =>
      'Solana: mở Phantom hoặc Solflare Mobile → Scan QR (MetaMask chủ yếu cho Ethereum; WC Solana cần ví hỗ trợ Solana).';

  @override
  String get wcQrCopyUri => 'Copy URI';

  @override
  String get wcQrUriCopied => 'Đã copy WalletConnect URI';

  @override
  String get wcQrWalletLinkedCard => 'Ví đã được liên kết thành công!';

  @override
  String get wcSessionExpiredFiveMin => 'Session đã hết hạn (5 phút)';

  @override
  String get wcQrCreateNew => 'Tạo QR mới';

  @override
  String get wcStatusIdle => 'Chờ khởi tạo';

  @override
  String get wcStatusPending => 'Chờ scan QR';

  @override
  String get wcStatusConnected => 'Ví đã kết nối, đang chờ ký…';

  @override
  String get wcStatusSigned => 'Đã ký thành công!';

  @override
  String get wcStatusExpired => 'Session hết hạn';

  @override
  String get wcStatusFailed => 'Có lỗi xảy ra';

  @override
  String get wcLinkChooseBlockchain => 'Chọn blockchain';

  @override
  String get wcTooltipTronlinkChrome => 'Dùng TronLink Extension (Chrome)';

  @override
  String get wcTooltipWalletConnect => 'WalletConnect';

  @override
  String get wcTronChromeExtensionWebOnly =>
      'TronLink được xử lý qua Chrome Extension — chỉ khả dụng trên Web.';

  @override
  String get wcTronChromeOnlyLong =>
      'Tron chỉ hỗ trợ qua TronLink Extension trên Chrome. Vui lòng truy cập trang web trên Chrome để liên kết ví Tron.';

  @override
  String get wcCreateQrButton => 'Tạo QR Code kết nối';

  @override
  String get wcCancelReselect => 'Huỷ và chọn lại';

  @override
  String get wcPrivateKeyStaysInWallet =>
      'Private key không bao giờ rời khỏi ví của bạn.';

  @override
  String get wcCreatingSession => 'Đang tạo phiên kết nối…';

  @override
  String get wcSessionCreateFailed =>
      'Không thể tạo phiên WalletConnect. Thử lại.';

  @override
  String get wcSessionExpiredNewQr =>
      'Session đã hết hạn. Vui lòng tạo QR Code mới.';

  @override
  String get wcSessionWcFailedRetry =>
      'WalletConnect thất bại (kết nối hoặc ký). Hãy tạo QR mới hoặc thử lại.';

  @override
  String get wcWcSupportsEvmSolanaTron =>
      'WalletConnect hỗ trợ ETH Sepolia và Solana Devnet. Với Tron, hãy dùng extension TronLink trên Chrome.';

  @override
  String get wcSignWithTronlinkExtension => 'Ký bằng TronLink Extension';

  @override
  String get wcTronlinkSignFailed => 'TronLink signing thất bại.';

  @override
  String get wcTronlinkSignMessage => 'TronLink liên kết ví';

  @override
  String get wcOpenWalletOnPhone => 'Mở bằng ví trên điện thoại';

  @override
  String wcWalletNotInstalled(String name) {
    return '$name chưa được cài đặt';
  }

  @override
  String wcDownloadFromStore(String store) {
    return 'Tải xuống từ $store';
  }

  @override
  String wcOpenWalletNamed(String name) {
    return 'Mở $name';
  }

  @override
  String get wcStoreGooglePlay => 'Google Play';

  @override
  String get wcStoreAppStore => 'App Store';

  @override
  String get wcLinkedWalletAddedToList =>
      'Ví đã được thêm vào danh sách liên kết.';

  @override
  String get onchainOperatorSandboxBanner =>
      'Hệ thống đang chế độ Sandbox (on-chain). Chỉ dùng testnet — không phải tiền mainnet thật.';

  @override
  String get onchainSandboxShort => 'Sandbox';
}
