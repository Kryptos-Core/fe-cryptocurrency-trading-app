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
  String get selectCurrency => 'Chọn tiền tệ';

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
  String get submitOnchainDeposit => 'Gửi nạp tiền on-chain';

  @override
  String get onchainDepositDesc =>
      'Sau khi gửi token từ ví đến địa chỉ nạp của sàn, dán tx hash vào đây.';

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
  String get amountMustBePositive => 'Số lượng phải > 0';

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
}
