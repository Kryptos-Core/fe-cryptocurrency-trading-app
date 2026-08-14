// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crypto Trading App';

  @override
  String get walletConnectDescription => 'Cryptocurrency trading';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get markets => 'Markets';

  @override
  String get orders => 'Orders';

  @override
  String get wallets => 'Wallets';

  @override
  String get currencies => 'Currencies';

  @override
  String get profile => 'Profile';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get submit => 'Submit';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get comingSoonTitle => 'Feature coming soon';

  @override
  String get comingSoonDesc =>
      'This feature is under construction and will be available soon.';

  @override
  String get chartNoData => 'No data';

  @override
  String get chartZoomIn => 'Zoom in';

  @override
  String get chartZoomOut => 'Zoom out';

  @override
  String get chartShowIndicators => 'Show indicators';

  @override
  String get chartRsi => 'RSI';

  @override
  String get chartMacd => 'MACD';

  @override
  String get chartSignal => 'Signal';

  @override
  String get chartHistogram => 'Histogram';

  @override
  String get chartOpen => 'Open';

  @override
  String get chartHigh => 'High';

  @override
  String get chartLow => 'Low';

  @override
  String get chartClose => 'Close';

  @override
  String get chartVolume => 'Volume';

  @override
  String chartCandleAt(String time) {
    return 'Candle at $time';
  }

  @override
  String get noMarkets => 'No markets';

  @override
  String get noWallets => 'No wallets';

  @override
  String get tradingChart => 'Trading Chart';

  @override
  String get bids => 'Bids (Buy)';

  @override
  String get asks => 'Asks (Sell)';

  @override
  String get realtimeActive => 'Real-time updates active';

  @override
  String get interval => 'Interval';

  @override
  String get candles => 'Candles';

  @override
  String get vol => 'Vol';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get loginToAccount => 'Login to your account';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get marketDetails => 'Market Details';

  @override
  String get marketNotFound => 'Market not found';

  @override
  String get lastPrice => 'Last Price';

  @override
  String get change24h => '24h Change';

  @override
  String get volume24h => 'Volume (24h)';

  @override
  String get marketInformation => 'Market Information';

  @override
  String get baseCurrency => 'Base Currency';

  @override
  String get quoteCurrency => 'Quote Currency';

  @override
  String get minOrderAmount => 'Min Order Amount';

  @override
  String get makerFee => 'Maker Fee';

  @override
  String get takerFee => 'Taker Fee';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get orderBook => 'Order Book';

  @override
  String get asksSell => 'ASKS (Sell)';

  @override
  String get bidsBuy => 'BIDS (Buy)';

  @override
  String get waitingForChartData => 'Waiting for chart data...';

  @override
  String get connectedRealtime => 'Connected to real-time updates';

  @override
  String get connectedNoUpdates => 'Connected — no updates for this pair';

  @override
  String get noRealtimeUpdatesHint =>
      'This pair may not have real-time data (e.g. not on Binance). Try BTC/USDT or ETH/USDT.';

  @override
  String get connecting => 'Connecting...';

  @override
  String get offline => 'Offline';

  @override
  String get na => 'N/A';

  @override
  String get wallet => 'Wallet';

  @override
  String get walletPortfolioCardTitle => 'Total portfolio';

  @override
  String get walletPortfolioEmptyHint =>
      'No wallet data yet. Pull to refresh or check your connection.';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get currencySelectHint => 'Tap to search or choose a currency';

  @override
  String get searchCurrenciesHint =>
      'Search by symbol or name (e.g. BTC, USDT)';

  @override
  String get currencyPickerFilter => 'Show';

  @override
  String get currencyPickerFilterAll => 'All';

  @override
  String get currencyPickerFilterTradable => 'Tradable';

  @override
  String get currencyPickerFilterNonTradable => 'Non-tradable';

  @override
  String get currencyPickerNoMatches =>
      'No currencies match your search or filter';

  @override
  String get currencyPickerRemoveRecent => 'Remove from recent';

  @override
  String get available => 'Available';

  @override
  String get frozen => 'Frozen';

  @override
  String get total => 'Total';

  @override
  String get actions => 'Actions';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get transfer => 'Transfer';

  @override
  String get depositSuccess => 'Deposit successful!';

  @override
  String get withdrawSuccess => 'Withdraw successful!';

  @override
  String get transferSuccess => 'Transfer successful!';

  @override
  String get depositFailed => 'Deposit failed';

  @override
  String get withdrawFailed => 'Withdraw failed';

  @override
  String get transferFailed => 'Transfer failed';

  @override
  String get noActiveCurrencies => 'No active currencies found';

  @override
  String get lastTransaction => 'Last Transaction';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get searchTransactions => 'Search by amount, type, date...';

  @override
  String get filterByType => 'Filter by type';

  @override
  String get allTypes => 'All types';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get reference => 'Reference';

  @override
  String get noTransactionsFound => 'No transactions yet';

  @override
  String get noTransactionsMatch => 'No transactions match your search';

  @override
  String get amount => 'Amount';

  @override
  String get direction => 'Direction';

  @override
  String get toUserId => 'To User ID';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get memberSince => 'Member since';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get viewAllCurrencies => 'View all available currencies';

  @override
  String get settings => 'Settings';

  @override
  String get appSettingsPreferences => 'App settings and preferences';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get loggedOutSuccess => 'Logged out successfully';

  @override
  String get orderBookEmpty => 'No orders yet';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get buy => 'Buy';

  @override
  String get sell => 'Sell';

  @override
  String get limitOrder => 'Limit';

  @override
  String get marketOrder => 'Market';

  @override
  String get price => 'Price';

  @override
  String get pairId => 'Pair ID';

  @override
  String get orderType => 'Order type';

  @override
  String get orderPlacedSuccess => 'Order placed successfully';

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String get tradingPair => 'Trading pair';

  @override
  String get tradingPairPickerTitle => 'Select trading pair';

  @override
  String get tradingPairQuoteAll => 'All';

  @override
  String get tradingPairSectionRecent => 'Recent';

  @override
  String get tradingPairSectionFavorites => 'Favorites';

  @override
  String get tradingPairSelectPairHint => 'Tap to search or choose a pair';

  @override
  String get tradingPairAddFavorite => 'Add to favorites';

  @override
  String get tradingPairRemoveFavorite => 'Remove from favorites';

  @override
  String get recentTrades => 'Recent trades';

  @override
  String get youWillReceive => 'You will receive';

  @override
  String get estimatedFee => 'Estimated fee';

  @override
  String get spotWallet => 'Spot wallet';

  @override
  String get orderFundsFrom => 'From wallet';

  @override
  String get orderFundsTo => 'To wallet';

  @override
  String get orderInsufficientBase => 'Insufficient base balance. Available';

  @override
  String get orderInsufficientQuote => 'Insufficient quote balance. Available';

  @override
  String get syncBinance => 'Sync Binance';

  @override
  String get syncBinanceDescription =>
      'Sync currencies and market pairs from Binance into the app database';

  @override
  String get manualResyncBinance => 'Manual re-sync from Binance';

  @override
  String get manualResyncBinanceDescription =>
      'Use this only when you need to manually refresh market catalog from Binance.';

  @override
  String get lastManualSync => 'Last manual sync';

  @override
  String get neverSyncedYet => 'Never';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncSuccess =>
      'Sync completed. Currencies and markets are up to date.';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get exchangeSyncForceRefresh =>
      'Force refresh from Binance (bypass 1h cache)';

  @override
  String exchangeSyncResultSummary(int pairsCreated, int pairsSkipped,
      int currenciesCreated, int currenciesSkipped) {
    return '+$pairsCreated pairs created, $pairsSkipped unchanged; +$currenciesCreated currencies, $currenciesSkipped unchanged.';
  }

  @override
  String get exchangeSyncWarningsTitle => 'Sync completed with warnings';

  @override
  String get exchangeSyncClose => 'OK';

  @override
  String get searchMarketsHint => 'Search by symbol (e.g. BTC, USDT)';

  @override
  String get filterBase => 'Base';

  @override
  String get filterBaseAll => 'All';

  @override
  String get filterQuote => 'Quote';

  @override
  String get filterQuoteAll => 'All';

  @override
  String get marketsSortBy => 'Sort';

  @override
  String get marketsSortTopVolume => 'Top Volume';

  @override
  String get marketsSortTopGainers => 'Top Gainers';

  @override
  String get marketsSortTopLosers => 'Top Losers';

  @override
  String get marketsSortSymbolAsc => 'A-Z';

  @override
  String get marketsSortSymbolDesc => 'Z-A';

  @override
  String get marketsSortNewest => 'Newest';

  @override
  String get marketsSortOldest => 'Oldest';

  @override
  String get marketsFuzzySearch => 'Smart search';

  @override
  String get marketsResultSuffix => 'pairs';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get payosTopupVnd => 'Top up VND via PayOS';

  @override
  String get payosDepositTitle => 'VND Deposit (PayOS)';

  @override
  String get payosCreateOrder => 'Create deposit order';

  @override
  String get payosAmountLabel => 'Amount (VND)';

  @override
  String get payosMinAmountHint => 'Minimum 10,000';

  @override
  String get payosNoTransactions => 'No deposit transactions yet.';

  @override
  String get payosOrderCode => 'Order code';

  @override
  String get payosEnterAmount => 'Please enter an amount.';

  @override
  String payosInvalidAmountMin(int minVnd) {
    return 'Invalid amount. Minimum is $minVnd VND.';
  }

  @override
  String payosInvalidAmountMax(int maxVnd) {
    return 'Invalid amount. Maximum is $maxVnd VND.';
  }

  @override
  String payosMinAmountHintDynamic(String minFormatted) {
    return 'Minimum $minFormatted';
  }

  @override
  String get payosOpenLinkFailed => 'Could not open payment link.';

  @override
  String get payosWaitingWebhook => 'Waiting for PayOS webhook...';

  @override
  String get payosPaymentUpdated =>
      'Payment successful. Balance and history have been updated.';

  @override
  String get payosOrderProcessing =>
      'Order is being processed. The system will auto-update when PayOS webhook arrives.';

  @override
  String get payosNeedFiatTitle => 'Fiat (VND)?';

  @override
  String get payosNeedFiatDesc => 'PayOS — then return to trade here.';

  @override
  String get payosDepositRatePreviewTitle => 'Current exchange rate';

  @override
  String payosDepositRateOneUsdt(String vndFormatted) {
    return '1 USDT ~ $vndFormatted VND';
  }

  @override
  String payosDepositSpreadBps(String bps) {
    return 'Spread: $bps bps';
  }

  @override
  String payosDepositYouReceive(String amount, String currency) {
    return 'You receive $amount $currency';
  }

  @override
  String payosUsdtMarketPrice(String value) {
    return 'USDT market: $value VND';
  }

  @override
  String get payosMarketPricesTooltip => 'Market prices';

  @override
  String get marketPricesScreenTitle => 'Market prices';

  @override
  String marketPricesUsdLine(String price) {
    return 'USD: $price';
  }

  @override
  String marketPricesVndAmount(String value) {
    return '$value VND';
  }

  @override
  String get marketPricesEmpty => 'No market prices available.';

  @override
  String get openOnchainWalletFlow => 'Open On-chain Wallet Flow';

  @override
  String get fiatWithdrawBankTitle => 'Withdraw to bank (USDT)';

  @override
  String get fiatWithdrawBankSubtitle =>
      'Link a Vietnamese bank account, then request withdrawal. Requires verified user role.';

  @override
  String get fiatWithdrawToBankShort => 'Bank withdraw';

  @override
  String get fiatWithdrawBankCode => 'Bank';

  @override
  String get fiatWithdrawAccountNumber => 'Account number';

  @override
  String get fiatWithdrawHolderName => 'Account holder name';

  @override
  String get fiatWithdrawSaveBank => 'Submit bank for review';

  @override
  String get fiatWithdrawMyBanks => 'My bank accounts';

  @override
  String get fiatWithdrawAmount => 'Amount (USDT)';

  @override
  String get fiatWithdrawSubmitRequest => 'Submit withdrawal';

  @override
  String get fiatWithdrawMyRequests => 'My requests';

  @override
  String get fiatWithdrawAdminTitle => 'Fiat bank withdrawals';

  @override
  String get fiatWithdrawAdminBanks => 'Bank accounts';

  @override
  String get fiatWithdrawAdminRequests => 'Withdrawal requests';

  @override
  String get fiatWithdrawVerify => 'Verify';

  @override
  String get fiatWithdrawReject => 'Reject';

  @override
  String get fiatWithdrawComplete => 'Complete transfer';

  @override
  String get fiatWithdrawTransferRef => 'Transfer reference';

  @override
  String get drawerFiatWithdrawalAdmin => 'Fiat bank (admin)';

  @override
  String get drawerFiatWithdrawalAdminSubtitle =>
      'Verify bank accounts & approve USDT payouts';

  @override
  String get onchainWalletsTitle => 'On-chain Wallets';

  @override
  String get onchainLinkedWallets => 'Linked Wallets';

  @override
  String get addressCopied => 'Address copied';

  @override
  String get copyFullAddress => 'Copy full address';

  @override
  String get linkWallet => 'Link Wallet';

  @override
  String get linkWalletWeb => 'Link Wallet (Web)';

  @override
  String get linkFirstWallet => 'Link Your First Wallet';

  @override
  String get noLinkedWalletsTitle => 'No linked wallets yet';

  @override
  String get noLinkedWalletsMessage =>
      'Connect a Tron, Solana, or BSC (Chapel) wallet first so deposit and withdrawal flows have a verified destination.';

  @override
  String get unlinkWalletTitle => 'Unlink wallet';

  @override
  String confirmUnlinkWallet(String address) {
    return 'Are you sure you want to unlink $address?';
  }

  @override
  String get walletUnlinkedSuccess => 'Wallet unlinked successfully';

  @override
  String get failedToUnlinkWallet => 'Failed to unlink wallet';

  @override
  String walletLabelPrefix(String label) {
    return 'Label: $label';
  }

  @override
  String linkedAtPrefix(String datetime) {
    return 'Linked at: $datetime';
  }

  @override
  String get unlinkAction => 'Unlink';

  @override
  String get networkLabel => 'Network';

  @override
  String get walletAddressLabel => 'Wallet address';

  @override
  String get walletAddressRequired => 'Address is required';

  @override
  String get labelOptional => 'Label (optional)';

  @override
  String get enableTestMode => 'Enable test mode (manual signature fallback)';

  @override
  String get requestingChallenge => 'Requesting...';

  @override
  String get requestChallengeStep => '1) Request Challenge';

  @override
  String get challengeMessageTitle => 'Challenge message';

  @override
  String get copyChallengManual => '2) Copy Challenge (Manual)';

  @override
  String get openExtensionSign => '2) Open Extension & Sign';

  @override
  String get openWalletSign => '2) Open Wallet & Sign';

  @override
  String get openWalletManualSign => '2) Open Wallet (Manual Sign)';

  @override
  String get signatureLabel => 'Signature';

  @override
  String get pasteSignatureHint => 'Paste wallet signature here';

  @override
  String get verifyingLink => 'Verifying...';

  @override
  String get verifyLinkStep => '3) Verify Link';

  @override
  String get failedToRequestChallenge => 'Failed to request challenge';

  @override
  String challengeReceived(int seconds) {
    return 'Challenge received. Expires in ${seconds}s';
  }

  @override
  String get manualModeCopied =>
      'Manual mode: challenge copied. Sign it in wallet manually, then paste signature below.';

  @override
  String get walletAddressUpdatedMetamask =>
      'Wallet address updated from MetaMask. Request a new challenge before signing.';

  @override
  String useConnectedAccount(String address) {
    return 'Use connected account ($address)';
  }

  @override
  String get requestChallengeFirst => 'Please request challenge first.';

  @override
  String get signatureRequired => 'Signature is required.';

  @override
  String get walletLinkedSuccess => 'Wallet linked successfully.';

  @override
  String get verifyFailed => 'Verify failed';

  @override
  String get webModeNotice =>
      'Web mode: this flow signs via browser extension popup when provider is available.';

  @override
  String get appModeNotice =>
      'App mode: Windows/Mobile uses wallet app or manual-sign fallback depending on network/provider availability.';

  @override
  String get manualSignGuideTitle => 'Manual signing guide (Test mode)';

  @override
  String browserSignGuideTitle(String wallet) {
    return 'Browser signing guide ($wallet)';
  }

  @override
  String desktopSignGuideTitle(String wallet) {
    return 'Desktop/Mobile signing guide ($wallet)';
  }

  @override
  String get walletGuideTestStep1 =>
      'Step 2 copies the challenge text to your clipboard.';

  @override
  String get walletGuideNativeTestStep2 =>
      'Open your wallet or signer tool manually and sign the exact challenge text.';

  @override
  String get walletGuideNativeTestStep3 =>
      'Paste the resulting signature into the Signature field, then click Verify Link.';

  @override
  String get walletGuideWebTestStep2 =>
      'Sign the exact challenge text in your extension or wallet app.';

  @override
  String get walletGuideWebTestStep3 =>
      'Paste signature into the Signature field and click Verify Link.';

  @override
  String get walletGuideNativeEthStep1 =>
      'Install MetaMask browser extension and unlock it.';

  @override
  String get walletGuideNativeEthStep2 =>
      'Use an account on BNB Smart Chain (Chapel testnet) that matches the wallet address you entered.';

  @override
  String get walletGuideNativeEthStep3 =>
      'Click Step 2 to trigger deep-link; if nothing opens, sign manually in MetaMask and paste signature below.';

  @override
  String get walletGuideNativeSolStep1 =>
      'Install Phantom extension or desktop app and unlock it.';

  @override
  String get walletGuideNativeSolStep2 =>
      'Switch wallet to Solana Devnet and use the same address you entered.';

  @override
  String get walletGuideNativeSolStep3 =>
      'Click Step 2; if deep-link fails, sign the challenge manually and paste signature below.';

  @override
  String get walletGuideNativeTronStep1 =>
      'Install TronLink extension/app and unlock it.';

  @override
  String get walletGuideNativeTronStep2 =>
      'Switch to Nile or Shasta account matching your entered address.';

  @override
  String get walletGuideNativeTronStep3 =>
      'Click Step 2; if app does not open, open TronLink manually, sign challenge, then paste signature below.';

  @override
  String get walletGuideWebEthStep1 =>
      'Use Chrome/Edge profile where MetaMask extension is installed and unlocked.';

  @override
  String get walletGuideWebEthStep2 =>
      'Ensure extension has site access on this app host (localhost or your domain).';

  @override
  String get walletGuideWebEthStep3 =>
      'Click Step 2 to open MetaMask popup and confirm personal_sign.';

  @override
  String get walletGuideWebSolStep1 =>
      'Use browser profile with Phantom extension enabled and unlocked.';

  @override
  String get walletGuideWebSolStep2 =>
      'Switch Phantom to Solana Devnet and confirm wallet address matches.';

  @override
  String get walletGuideWebSolStep3 =>
      'Click Step 2, approve the signature request, then continue verify.';

  @override
  String get walletGuideWebTronStep1 =>
      'Use browser profile with TronLink extension enabled and unlocked.';

  @override
  String get walletGuideWebTronStep2 =>
      'Switch to Nile or Shasta account that matches your entered address.';

  @override
  String get walletGuideWebTronStep3 =>
      'Click Step 2 and confirm signature in TronLink popup.';

  @override
  String get walletWindowsPrecheckReady =>
      'Windows pre-check: extension is ready, you can continue signing.';

  @override
  String get walletWindowsPrecheckRequired =>
      'Windows pre-check: confirm extension is installed before signing.';

  @override
  String get walletWindowsPrecheckCheck => 'Check extension in browser';

  @override
  String get walletWindowsPrecheckRecheck => 'Re-check extension';

  @override
  String walletExtensionCheckTitle(String extension) {
    return 'Check $extension';
  }

  @override
  String walletExtensionCheckMessage(String extension) {
    return 'Browser has been opened so you can check $extension. If installed and unlocked, click Ready to continue wallet linking.';
  }

  @override
  String get walletExtensionCheckClose => 'Close';

  @override
  String walletExtensionInstallAction(String extension) {
    return 'Install $extension';
  }

  @override
  String get walletExtensionReadyAction => 'Ready';

  @override
  String get walletDontAskAgainSession => 'Don\'t ask again in this session';

  @override
  String get walletOpenTronLinkExtension => 'Open TronLink Extension Manager';

  @override
  String get walletWindowsNativeSignNotice =>
      'Windows native app cannot trigger extension signing popup directly. Direct popup signing is available only on web (Chrome/Edge).';

  @override
  String get walletTronLinkExtensionOpened => 'Opened TronLink extension page.';

  @override
  String get walletExtensionOpenFailed => 'Could not open extension page.';

  @override
  String walletExtensionInstallOpenedInfo(String extension) {
    return 'Opened $extension install page. After installation, return and run check again.';
  }

  @override
  String get walletExtensionPrecheckSuccess =>
      'Pre-check completed. Open extension, sign challenge, then paste signature below.';

  @override
  String get submitOnchainDeposit => 'On-chain deposit';

  @override
  String get onchainDepositDesc =>
      'Send assets to the platform address or scan the QR code. Confirmation happens automatically; watch status in recent transactions below.';

  @override
  String get onchainAutoConfirmBanner =>
      'Deposits are confirmed automatically in the background; this can take a few minutes. Status appears in recent transactions below.';

  @override
  String get onchainDepositMonitorTitle => 'Your on-chain activity';

  @override
  String get onchainDepositMonitorDesc =>
      'Deposits and other on-chain movements are detected automatically. Use filters below; copy hashes or addresses when you need to search a block explorer or contact support.';

  @override
  String get onchainFieldInternalId => 'Internal reference';

  @override
  String get onchainFieldFromAddress => 'From address';

  @override
  String get onchainFieldToAddress => 'To address';

  @override
  String get onchainFieldConfirmations => 'Confirmations';

  @override
  String get onchainFieldCreatedAt => 'Created';

  @override
  String get onchainFieldConfirmedAt => 'Confirmed';

  @override
  String get onchainValueNotAvailable => 'Not yet available';

  @override
  String onchainCreditConversionLine(
      String credited, String native, String rate) {
    return 'Credited: $credited · rate 1 $native = $rate USDT';
  }

  @override
  String onchainDepositTransitioningMinutes(int minutes) {
    return 'Wallet addresses are updating (~$minutes min left). This list will refresh when ready.';
  }

  @override
  String get onchainDepositTransitioningUnderOneMinute =>
      'Wallet addresses are updating (under one minute left). This list will refresh when ready.';

  @override
  String get onchainDepositTransitioningFinalize =>
      'Wallet addresses are finishing activation. This list will refresh when ready.';

  @override
  String get onchainDepositTransitioningUnknown =>
      'Wallet addresses are updating. This list will refresh when ready.';

  @override
  String get platformDepositAddress => 'Platform deposit address';

  @override
  String sendAssetsToAddress(String network) {
    return 'Send $network assets to this address or scan the QR code.';
  }

  @override
  String get onlyTransferSelectedChain =>
      'Only transfer on the selected chain. Sending from wrong chain may cause permanent loss.';

  @override
  String get refreshAddress => 'Refresh address';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get hideFullAddress => 'Hide full address';

  @override
  String get showFullAddress => 'Show full address';

  @override
  String get couldNotLoadDepositAddress => 'Could not load deposit address.';

  @override
  String get transactionHashLabel => 'Transaction hash';

  @override
  String get txHashRequired => 'Tx hash is required';

  @override
  String get depositAddressCopied => 'Deposit address copied';

  @override
  String get senderWalletNotLinkedError =>
      'Sender wallet is not linked. Link that wallet before submitting deposit.';

  @override
  String get depositSubmittedSuccess => 'Deposit submitted successfully';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get amountMustBePositive => 'Amount must be positive';

  @override
  String get depositPreviewLinked =>
      'Sender wallet is linked. Amount auto-filled from on-chain data.';

  @override
  String get depositPreviewNotLinked =>
      'Sender wallet is not linked to your account. Link that wallet before submit.';

  @override
  String depositPreviewLabel(String status, String amount) {
    return 'Preview: $status · Amount $amount';
  }

  @override
  String get allNetworks => 'All networks';

  @override
  String txResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get noTxMatchFilters => 'No transactions match these filters';

  @override
  String get trySwitchingFilters =>
      'Try switching network, type, or sort to surface the transactions you need.';

  @override
  String txToAddress(String address) {
    return 'To: $address';
  }

  @override
  String get txTypeDeposits => 'Deposits';

  @override
  String get txTypeWithdrawals => 'Withdrawals';

  @override
  String get txTypeTransfers => 'Transfers';

  @override
  String get txTypeFund => 'Hot wallet funding';

  @override
  String get txTypeSweep => 'Treasury sweep';

  @override
  String get txTypeUnknown => 'Other';

  @override
  String get noOnchainActivityTitle => 'No on-chain activity yet';

  @override
  String get noOnchainActivityDesc =>
      'When the platform detects an on-chain transfer involving your account, it will appear here with full details, status, and confirmations.';

  @override
  String get trySwitchingFiltersDeposit =>
      'Try switching network, type, or sort to surface the transactions you need.';

  @override
  String get requestOnchainWithdrawal => 'Request on-chain withdrawal';

  @override
  String get withdrawalDestinationDesc =>
      'Withdrawal destination must be a verified linked wallet on the same network.';

  @override
  String get linkedWalletDropdownLabel => 'Linked wallet';

  @override
  String get selectDestinationWallet =>
      'Please select destination linked wallet';

  @override
  String get selectNetworkFirst => 'Please select a network first';

  @override
  String get withdrawalRequestSubmitted => 'Withdrawal request submitted';

  @override
  String get requestFailed => 'Request failed';

  @override
  String get noVerifiedWalletTitle => 'No verified wallet on this network';

  @override
  String get noVerifiedWalletDesc =>
      'Link and verify a wallet in the linked-wallets tab before requesting a withdrawal here.';

  @override
  String get submitting => 'Submitting...';

  @override
  String get requestWithdrawalAction => 'Request Withdrawal';

  @override
  String get noWithdrawalActivityTitle => 'No withdrawal activity yet';

  @override
  String get noWithdrawalActivityDesc =>
      'Approved withdrawals will show up here with their latest on-chain status.';

  @override
  String get tryAnotherFilter =>
      'Try another network or type chip to quickly bring matching transactions back.';

  @override
  String get payosOpenLinkFallbackTitle => 'Unable to open PayOS automatically';

  @override
  String get payosOpenLinkFallbackDesc =>
      'Your payment link is ready. You can copy it or try opening it again.';

  @override
  String get payosCopyLink => 'Copy link';

  @override
  String get payosOpenInBrowser => 'Open in browser';

  @override
  String get payosLinkCopied => 'Payment link copied';

  @override
  String get payosTapToOpenCheckout => 'Tap to open checkout';

  @override
  String get payosPaymentCancelled => 'Payment was cancelled or expired.';

  @override
  String get currenciesSearchHint => 'Search currencies...';

  @override
  String get currenciesFilterAll => 'All';

  @override
  String get currenciesTradable => 'Tradable';

  @override
  String get currenciesPaused => 'Paused';

  @override
  String get currenciesSortTopVolume => 'Top Volume';

  @override
  String get currenciesSortTopGainers => 'Top Gainers';

  @override
  String get currenciesSortTopLosers => 'Top Losers';

  @override
  String get currenciesSortAlphabet => 'A-Z';

  @override
  String get currenciesSortLabel => 'Sort';

  @override
  String get currenciesClearFilters => 'Clear filters';

  @override
  String currenciesResultCounter(int shown, int total) {
    return '$shown of $total currencies';
  }

  @override
  String get currenciesEmptyFiltered =>
      'No currencies match the current filters';

  @override
  String get currenciesRetryAction => 'Retry';

  @override
  String get currenciesLoadingMore => 'Loading more...';

  @override
  String get currenciesNoCurrenciesFound => 'No currencies found';

  @override
  String get currenciesNoMatchSearch => 'No currencies match your search';

  @override
  String get currenciesDetailTitle => 'Currency Details';

  @override
  String get currenciesNotFound => 'Currency not found';

  @override
  String get currenciesMarketOverviewTitle => 'Market Overview';

  @override
  String get currenciesConfigurationTitle => 'Currency Configuration';

  @override
  String get currenciesDetailStatusTitle => 'Status';

  @override
  String get currenciesDetailBackToMarkets => 'Back to Markets';

  @override
  String get currenciesDetailActiveLabel => 'Active status';

  @override
  String get currenciesDetailTradableLabel => 'Tradable status';

  @override
  String get currenciesSymbolLabel => 'Symbol';

  @override
  String get currenciesNameLabel => 'Name';

  @override
  String get currenciesPrecisionScaleLabel => 'Precision Scale';

  @override
  String get currenciesMinWithdrawLabel => 'Min Withdraw';

  @override
  String get currenciesYes => 'Yes';

  @override
  String get currenciesNo => 'No';

  @override
  String get profileTapToChangeAvatar => 'Tap to change avatar';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileAvatarUpdated => 'Avatar updated';

  @override
  String get profileSecurityRequiresApproval => 'Security (requires approval)';

  @override
  String get profileEmailVerifiedTooltip => 'Email verified with OTP';

  @override
  String get profileEmailVerifiedLabel => 'Verified';

  @override
  String get profileChangeEmail => 'Change email';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileChangePasswordDirect =>
      'Change directly, no approval required';

  @override
  String get profilePasswordChanged => 'Password has been changed';

  @override
  String get profileOtpAdminReviewRequired => 'OTP + admin review required';

  @override
  String get profileEnable2faFirstTitle => 'Enable 2FA first';

  @override
  String get profileEnable2faFirstDesc =>
      'Go to Settings to enable 2FA before changing email/password';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsSecurityTitle => 'Security';

  @override
  String get settings2faDescription =>
      'Enable 2FA to protect sensitive actions like changing email/password.';

  @override
  String get settings2faLabel => 'Two-factor authentication';

  @override
  String get settings2faEnabled => 'Enabled';

  @override
  String get settings2faDisabled => 'Disabled';

  @override
  String get otpSentToEmail => 'OTP sent to your verified email.';

  @override
  String get otpVerificationTitle => 'OTP verification';

  @override
  String get otpEnterCodeHint => 'Enter 6-digit OTP';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpRequiredEnable2faFirst =>
      'Please enable 2FA in Settings before changing email or password.';

  @override
  String get contactEmailRequiredForOtpShort =>
      'Add a real email in Profile → Security before using email OTP.';

  @override
  String get contactEmailRequiredForOtpBody =>
      'Wallet sign-in uses a placeholder address until you verify a real one. Open Change email, enter your address, tap Send code, then enter the OTP sent to that inbox.';

  @override
  String get contactEmailGoToProfile => 'Open Profile';

  @override
  String get contactEmailVerifyDialogTitle => 'Verify contact email';

  @override
  String get contactEmailVerifyDialogSubtitle =>
      'Enter your real email. We will send a 6-digit code there.';

  @override
  String get contactEmailSendCode => 'Send code';

  @override
  String get contactEmailVerifySave => 'Verify and save';

  @override
  String get contactEmailUpdatedSuccess => 'Contact email updated.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutOpenInBrowser => 'Open in browser';

  @override
  String get aboutPolicyGuideHint =>
      'Policy, app information, and user guide are available in browser.';

  @override
  String get aboutAppTileTitle => 'About app';

  @override
  String get aboutAppTileSubtitle => 'Policy, app info, user guide';

  @override
  String get requestSentPendingApproval => 'Request sent. Pending approval.';

  @override
  String get broadcastNotificationTitle => 'Broadcast Notification';

  @override
  String get broadcastInfoBanner =>
      'This notification will be delivered to all active users in real-time and persisted in their notification history.';

  @override
  String get broadcastTypeLabel => 'Type';

  @override
  String get broadcastTypeSystem => 'System';

  @override
  String get broadcastTypeAlert => 'Alert';

  @override
  String get broadcastTypePromo => 'Promo';

  @override
  String get broadcastTitleLabel => 'Title';

  @override
  String get broadcastTitleHint => 'e.g. System maintenance tonight at 23:00';

  @override
  String get broadcastTitleRequired => 'Title is required';

  @override
  String get broadcastTitleTooShort => 'Title too short';

  @override
  String get broadcastMessageLabel => 'Message';

  @override
  String get broadcastMessageHint => 'Write your notification message here...';

  @override
  String get broadcastMessageRequired => 'Message body is required';

  @override
  String get broadcastMessageTooShort => 'Message too short';

  @override
  String get broadcastSending => 'Sending...';

  @override
  String get broadcastSendAllUsers => 'Send to all users';

  @override
  String get broadcastSuccess => 'Notification broadcast successfully';

  @override
  String get broadcastFailedTryAgain =>
      'Failed to send notification. Please try again.';

  @override
  String get noPermissionMessage =>
      'You do not have permission to perform this action.';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get onchainTooltip => 'On-chain';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get drawerOnchainWallets => 'On-chain Wallets';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerUserManagement => 'User Management';

  @override
  String get drawerAdminArea => 'Admin area';

  @override
  String get drawerUserMgmtComingSoon => 'User management screen — coming soon';

  @override
  String get drawerBroadcastNotification => 'Broadcast Notification';

  @override
  String get drawerBroadcastSubtitle => 'Send to all users';

  @override
  String get drawerManualResync => 'Manual re-sync Binance';

  @override
  String get drawerAdminMarketsTitle => 'Market catalog (sync)';

  @override
  String get drawerAdminMarketsSubtitle => 'Restore Binance pairs & currencies';

  @override
  String get adminMarketsScreenTitle => 'Market catalog';

  @override
  String get adminMarketsIntro =>
      'Pulls currencies and spot pairs from Binance into the database. Use after db:clean or when the Markets list is empty.';

  @override
  String get adminMarketsLastResult => 'Last sync result';

  @override
  String get adminMarketsBinanceLimitsLink => 'Binance API rate limits';

  @override
  String get drawerSecurityRequests => 'Security requests';

  @override
  String get drawerSecuritySubtitle =>
      'Approve/reject email & password changes';

  @override
  String get authRequiredTitle => 'Sign in required';

  @override
  String get authRequiredSubtitle => 'Please sign in to access this feature.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeGuest => 'Welcome, Guest';

  @override
  String get guestSignInDesc =>
      'Sign in to access your wallet, place orders, and manage your account.';

  @override
  String get guestFeaturesTitle => 'Available without signing in';

  @override
  String get guestFeatureLiveMarkets => 'Live market data & charts';

  @override
  String get guestFeatureCurrencies => 'Supported currencies & networks';

  @override
  String get guestFeatureDeposit => 'Platform deposit methods';

  @override
  String get continueAsGuest => 'Continue without signing in';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsJustNow => 'Just now';

  @override
  String notificationsMinAgo(int count) {
    return '${count}m ago';
  }

  @override
  String notificationsHourAgo(int count) {
    return '${count}h ago';
  }

  @override
  String notificationsDayAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get notificationsDetails => 'Details';

  @override
  String get notificationsTypeAlert => 'Alert';

  @override
  String get notificationsTypePromo => 'Promo';

  @override
  String get notificationsTypeSystem => 'System';

  @override
  String get dashboardTopMarkets => 'Top Markets';

  @override
  String get dashboardMyWallets => 'My Wallets';

  @override
  String get dashboardTotalPortfolioValue => 'Total Portfolio Value';

  @override
  String get dashboardSeeAll => 'See All';

  @override
  String get dashboardNoMarketsAvailable => 'No markets available';

  @override
  String get dashboardNoFundedWallets =>
      'No funded wallets yet.\nDeposit or trade to see balances here.';

  @override
  String get dashboardWallets => 'Wallets';

  @override
  String get dashboardActive => 'Active';

  @override
  String get dashboardBankProvidersHealthTitle => 'Bank payout APIs';

  @override
  String get dashboardBankProvidersHealthAllOperational =>
      'All providers operational';

  @override
  String get dashboardBankProvidersHealthDegraded =>
      'Some providers unavailable';

  @override
  String get dashboardBankProvidersHealthCouldNotCheck => 'Health check failed';

  @override
  String get dashboardBankProvidersHealthLoading => 'Checking providers…';

  @override
  String dashboardBankProvidersHealthMs(int ms) {
    return '$ms ms';
  }

  @override
  String get securityRequestsTitle => 'Security change requests';

  @override
  String get securityRequestApproved => 'Request approved';

  @override
  String get securityRequestRejected => 'Request rejected';

  @override
  String get securityRejectDialogTitle => 'Reject request';

  @override
  String get securityRejectReasonHint => 'Optional reason';

  @override
  String get securityRequestNoPending => 'No pending requests';

  @override
  String securityRequestRequested(String date) {
    return 'Requested: $date';
  }

  @override
  String get securityRequestApprove => 'Approve';

  @override
  String get securityRequestReject => 'Reject';

  @override
  String get registerCreateAccount => 'Create Account';

  @override
  String get registerSignUpSubtitle => 'Sign up to get started';

  @override
  String get registerFirstNameLabel => 'First Name';

  @override
  String get registerFirstNameHelper => 'Only letters and spaces allowed';

  @override
  String get registerFirstNameRequired => 'First name is required';

  @override
  String get registerLastNameLabel => 'Last Name';

  @override
  String get registerLastNameRequired => 'Last name is required';

  @override
  String get registerEmailHint => 'user@example.com';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint =>
      'Min 8 characters with uppercase, lowercase, number';

  @override
  String get registerPasswordRequired => 'Password is required';

  @override
  String get registerPasswordMinLength =>
      'Password must be at least 8 characters';

  @override
  String get registerPasswordNeedsUppercase =>
      'Password must contain uppercase letter';

  @override
  String get registerPasswordNeedsLowercase =>
      'Password must contain lowercase letter';

  @override
  String get registerPasswordNeedsNumber => 'Password must contain a number';

  @override
  String get registerPasswordNeedsSpecial =>
      'Password must contain a special character';

  @override
  String get registerConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registerConfirmPasswordHint => 'Re-enter your password';

  @override
  String get registerConfirmPasswordRequired => 'Confirm password is required';

  @override
  String get registerPasswordsNoMatch => 'Passwords do not match';

  @override
  String get registerWalletDivider => 'Register with wallet';

  @override
  String get registerWithTronLink => 'Register with TronLink';

  @override
  String get registerSuccessLoggingIn =>
      'Registration successful! Logging in...';

  @override
  String get registerLoginFailedManual =>
      'Login failed. Please try logging in manually.';

  @override
  String get registerLoginSuccess => 'Login successful!';

  @override
  String get registerWalletSuccess => 'Wallet registration & login successful!';

  @override
  String get registerWalletConnectQr => 'WalletConnect (QR)';

  @override
  String registerUnexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get walletDetails => 'Wallet Details';

  @override
  String get walletNotFound => 'Wallet not found';

  @override
  String get walletAvailableBalance => 'Available Balance';

  @override
  String get walletFrozen => 'Frozen';

  @override
  String get walletTotal => 'Total';

  @override
  String get walletAvailable => 'Available';

  @override
  String get walletTransactionHistory => 'Transaction History';

  @override
  String get walletNoTransactions => 'No transactions found';

  @override
  String walletBalanceAfter(String amount) {
    return 'Balance: $amount';
  }

  @override
  String get walletUsdValue => 'USD Value';

  @override
  String get totalPortfolioValue => 'Total Portfolio Value';

  @override
  String get noWalletsFound => 'No wallets found';

  @override
  String get myWallets => 'My Wallets';

  @override
  String get cashWalletSectionTitle => 'Cash Wallet';

  @override
  String get cashWalletSectionSubtitle =>
      'Receives all deposits • Use to buy coins';

  @override
  String get coinAssetsSectionTitle => 'Assets';

  @override
  String get coinAssetsSectionSubtitle => 'Coins from trading';

  @override
  String get depositOnchainHint => 'Credited as USDT to your cash wallet';

  @override
  String get treasuryTitle => 'User deposits & managed wallets';

  @override
  String get treasuryManageSubtitle =>
      'Default deposit addresses, priority chain, and company wallets for user-facing flows.';

  @override
  String get treasuryToolbarTooltip =>
      'User deposits & managed wallets — default addresses and priority chain';

  @override
  String get treasuryManagedScopeBanner =>
      'This list is for deposit defaults and risk-managed wallets. Operational wallets: Payment configuration → Operational wallets.';

  @override
  String get treasuryOpsScopeBanner =>
      'Fund from main or sweep back to main. User deposit addresses: Deposits & managed wallets.';

  @override
  String get paymentConfigTitle => 'Payment Configuration';

  @override
  String get paymentConfigMethodsTab => 'Methods';

  @override
  String get paymentConfigMasterWalletTab => 'Master wallet';

  @override
  String get paymentConfigTreasuryWalletsTab => 'Operational wallets';

  @override
  String get paymentConfigHistoryTab => 'History';

  @override
  String get paymentConfigAddMethod => 'Add method';

  @override
  String get paymentConfigEditConfigTitle => 'Edit configuration';

  @override
  String get paymentConfigEmptyMessage =>
      'No configurations yet.\nTap \"Add method\" to create one.';

  @override
  String get paymentConfigActivateDialogTitle => 'Activate configuration';

  @override
  String paymentConfigActivateTarget(String name) {
    return 'Activate: $name';
  }

  @override
  String get paymentConfigActivateWarning =>
      'The system will move to TRANSITIONING. Traders will see a warning banner during the grace period.';

  @override
  String get paymentConfigGracePeriodLabel => 'Grace period (minutes)';

  @override
  String get paymentConfigGracePeriodHelper =>
      'Wait time before the new config becomes effective';

  @override
  String get paymentConfigActivateAction => 'Activate';

  @override
  String paymentConfigActivationStartedMinutes(int minutes) {
    return 'Grace period of $minutes minutes started';
  }

  @override
  String paymentConfigActivationAt(String time) {
    return 'Activates at: $time';
  }

  @override
  String get paymentConfigActivateFailed => 'Failed to activate configuration';

  @override
  String get paymentConfigDeactivateDialogTitle => 'Deactivate configuration';

  @override
  String paymentConfigDeactivateDialogContent(String name) {
    return 'Are you sure you want to deactivate \"$name\"?\nThis action takes effect immediately.';
  }

  @override
  String get paymentConfigDeactivateAction => 'Deactivate';

  @override
  String get paymentConfigDeactivatedSuccess => 'Deactivated';

  @override
  String paymentConfigTransitioningRemaining(int minutes) {
    return '~$minutes minutes remaining before activation';
  }

  @override
  String get paymentConfigGraceUnderOneMinute =>
      'Less than one minute remaining before activation';

  @override
  String get paymentConfigGraceFinalizePending =>
      'Grace period ended — finishing activation…';

  @override
  String get paymentConfigGraceUnknown => 'Grace period in progress';

  @override
  String paymentConfigVersionAndSort(int version, int sortOrder) {
    return 'Version: v$version · Order: $sortOrder';
  }

  @override
  String paymentConfigActivatedAt(String datetime) {
    return 'Activated: $datetime';
  }

  @override
  String get paymentConfigEditAction => 'Edit';

  @override
  String get paymentConfigEditTypeLocked =>
      'Type and network cannot be changed when editing.';

  @override
  String get paymentConfigDetailLoadFailed =>
      'Could not load configuration for editing.';

  @override
  String get paymentConfigStatusActiveUpper => 'ACTIVE';

  @override
  String get paymentConfigStatusTransitioningUpper => 'TRANSITIONING';

  @override
  String get paymentConfigStatusInactiveUpper => 'INACTIVE';

  @override
  String get paymentConfigMethodTypeLabel => 'Method type';

  @override
  String get paymentConfigNetworkLabel => 'Network';

  @override
  String get paymentConfigDisplayNameLabel => 'Display name';

  @override
  String get paymentConfigDisplayNameHint => 'Example: PayOS MB Bank';

  @override
  String get paymentConfigRequired => 'Required';

  @override
  String get paymentConfigGracePeriodEffectHelper =>
      'Wait time after activation before taking effect';

  @override
  String get paymentConfigCredentialsSectionTitle => 'Credentials';

  @override
  String get paymentConfigHideAction => 'Hide';

  @override
  String get paymentConfigShowAction => 'Show';

  @override
  String get paymentConfigMainnetWarning =>
      'MAINNET - this configuration affects real funds. Review carefully before activation.';

  @override
  String get paymentConfigMainnetSubtitle =>
      'Enable if this is a mainnet network (real funds)';

  @override
  String get paymentConfigRateLabel => 'Rate (1 VND -> X USDT)';

  @override
  String get paymentConfigCreateConfigAction => 'Create configuration';

  @override
  String get paymentConfigSaveChangesAction => 'Save changes';

  @override
  String get paymentConfigCreatedSuccess => 'Configuration created';

  @override
  String get paymentConfigUpdatedSuccess => 'Configuration updated';

  @override
  String get paymentConfigUnknownError => 'An error occurred';

  @override
  String get paymentConfigMaskedHelper => 'Hidden - tap \"Show\" to reveal';

  @override
  String get systemConfigScreenTitle => 'System Configuration';

  @override
  String get drawerSystemConfig => 'System Configuration';

  @override
  String get drawerSystemConfigSubtitle =>
      'Environment variables, RPC, limits, engine';

  @override
  String get systemConfigRefreshHint => 'Pull down to refresh';

  @override
  String get paymentConfigRuntimeTab => 'Platform';

  @override
  String get paymentConfigRuntimeSaveAll => 'Save runtime settings';

  @override
  String get paymentConfigRuntimeLoadFailed =>
      'Could not load platform settings.';

  @override
  String get paymentConfigRuntimeSaved => 'Runtime settings saved.';

  @override
  String get paymentConfigRuntimeIntro =>
      'These values apply without redeploying the API. Environment variables still act as defaults when a key is not stored in the database.';

  @override
  String get paymentConfigRuntimeSectionCore => 'Core';

  @override
  String get paymentConfigRuntimeSectionTech => 'Infrastructure & RPC';

  @override
  String get paymentConfigRuntimeSectionFinance => 'Finance & Limits';

  @override
  String get paymentConfigRuntimeSectionOps => 'Ops & Engine';

  @override
  String get paymentConfigRuntimeSectionAuthSecurity => 'Auth / Security';

  @override
  String get paymentConfigRuntimeSectionAuthSecurityDesc =>
      'Email verification toggle and other auth/security settings — admin only.';

  @override
  String get runtimeSettingEmailVerificationRequiredName =>
      'Email verification required (OTP gating)';

  @override
  String get runtimeSettingEmailVerificationRequiredDesc =>
      'When ON: every operation below requires a one-time code sent by email — Change password, Change contact email, Request security change. When OFF: all of the above OTP steps are skipped. Does NOT affect TOTP authenticator codes or import/reveal of treasury main wallets — see the toggle below. Only disable in trusted/internal (sandbox) environments.';

  @override
  String get runtimeSettingTreasuryWalletTotpRequiredName =>
      'TOTP required for treasury main wallet import / reveal';

  @override
  String get runtimeSettingTreasuryWalletTotpRequiredDesc =>
      'When ON (default): importing a treasury main wallet and revealing its private key both require a TOTP code from an authenticator app (Google Authenticator, Authy…). When OFF: TOTP is bypassed. On production on-chain mode (ONCHAIN_OPERATOR_MODE=production), TOTP is ALWAYS required regardless of this flag — it cannot be disabled to protect real wallets. Only disable in sandbox.';

  @override
  String get paymentConfigRuntimeSectionOpsDesc =>
      'Matching engine, Go aggregator, outbox alerts, rollout strategy, and market read — for ops team.';

  @override
  String get paymentConfigRuntimeSectionTechDesc =>
      'RPC URLs, API endpoints, and blockchain infra configuration — for tech team.';

  @override
  String get paymentConfigRuntimeSectionFinanceDesc =>
      'Withdraw limits, transfer limits, rate fallbacks, and MM defaults — for finance team.';

  @override
  String get paymentConfigRuntimeSectionCoreDesc =>
      'Default symbols, market sources, and wallet config — for ops team.';

  @override
  String get paymentConfigRuntimeNoPermission =>
      'You do not have permission to edit platform settings.';

  @override
  String get paymentConfigRuntimeSourceEnv => 'Default (env)';

  @override
  String get paymentConfigRuntimeSourceDb => 'Database';

  @override
  String get paymentConfigRuntimeTypeString => 'string';

  @override
  String get paymentConfigRuntimeTypeInteger => 'integer';

  @override
  String get paymentConfigRuntimeTypeBoolean => 'boolean';

  @override
  String get paymentConfigRuntimeTypeFloat => 'float';

  @override
  String get paymentConfigRuntimeValueHint => 'Current value';

  @override
  String get paymentConfigRuntimeTechKeySection => 'System variable';

  @override
  String get paymentConfigRuntimeValueOn => 'On';

  @override
  String get paymentConfigRuntimeValueOff => 'Off';

  @override
  String get runtimeSettingWalletSyncIntervalName =>
      'Wallet sync interval (ms)';

  @override
  String get runtimeSettingWalletSyncIntervalDesc =>
      'Interval for wallet sync workers (milliseconds).';

  @override
  String get runtimeSettingWalletReconciliationThresholdName =>
      'Reconciliation discrepancy threshold';

  @override
  String get runtimeSettingWalletReconciliationThresholdDesc =>
      'Absolute balance discrepancy treated as acceptable for reconciliation.';

  @override
  String get runtimeSettingTronNileFullHostName => 'Tron Nile RPC URL';

  @override
  String get runtimeSettingTronNileFullHostDesc =>
      'Full node HTTP API for TRON Nile testnet.';

  @override
  String get runtimeSettingTronShastaFullHostName => 'Tron Shasta RPC URL';

  @override
  String get runtimeSettingTronShastaFullHostDesc =>
      'Full node HTTP API for TRON Shasta testnet.';

  @override
  String get runtimeSettingTronDefaultNetworkName => 'Default Tron network';

  @override
  String get runtimeSettingTronDefaultNetworkDesc =>
      'TRON_NILE or TRON_SHASTA. Changing may require API restart for some processes.';

  @override
  String get runtimeSettingSolanaDevnetUrlName => 'Solana Devnet RPC URL';

  @override
  String get runtimeSettingSolanaDevnetUrlDesc =>
      'JSON RPC endpoint for Solana devnet.';

  @override
  String get runtimeSettingBlockchainAllowTestSignatureName =>
      'Allow test signature bypass';

  @override
  String get runtimeSettingBlockchainAllowTestSignatureDesc =>
      'When true (non-production rules apply), linking may accept TEST_SIG:: payloads. Editing from UI is blocked in production unless ALLOW_UI_TEST_SIGNATURE=true.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxName =>
      'Global auto-approve withdraw max (native)';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxDesc =>
      'Default max native amount for auto-processed withdrawals.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetName =>
      'Auto max withdraw — Solana devnet';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetDesc =>
      'Per-chain cap for SOLANA_DEVNET; falls back to global when empty.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronNileName =>
      'Auto max withdraw — Tron Nile';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronNileDesc =>
      'Per-chain cap for TRON_NILE; falls back to global when empty.';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronShastaName =>
      'Auto max withdraw — Tron Shasta';

  @override
  String get runtimeSettingBlockchainWithdrawAutoMaxTronShastaDesc =>
      'Per-chain cap for TRON_SHASTA; falls back to global when empty.';

  @override
  String get runtimeSettingBlockchainWithdrawEthSymbolName =>
      'Withdraw symbol — Ethereum';

  @override
  String get runtimeSettingBlockchainWithdrawEthSymbolDesc =>
      'Currency symbol used for ETH-family chains (must exist in DB).';

  @override
  String get runtimeSettingBlockchainWithdrawSolSymbolName =>
      'Withdraw symbol — Solana';

  @override
  String get runtimeSettingBlockchainWithdrawSolSymbolDesc =>
      'Currency symbol used for Solana devnet withdrawals.';

  @override
  String get runtimeSettingBlockchainWithdrawTronSymbolName =>
      'Withdraw symbol — Tron';

  @override
  String get runtimeSettingBlockchainWithdrawTronSymbolDesc =>
      'Currency symbol used for Tron withdrawals (e.g. TRX).';

  @override
  String get runtimeSettingPlatformCashCurrencySymbolName =>
      'Platform cash symbol';

  @override
  String get runtimeSettingPlatformCashCurrencySymbolDesc =>
      'Internal ledger symbol for cash leg of deposits (typically USDT).';

  @override
  String get runtimeSettingBlockchainDepositTrxToUsdtRateName =>
      'Fallback rate TRX → USDT';

  @override
  String get runtimeSettingBlockchainDepositTrxToUsdtRateDesc =>
      'Used when price oracle unavailable; 1 TRX = X USDT.';

  @override
  String get runtimeSettingBlockchainDepositEthToUsdtRateName =>
      'Fallback rate ETH → USDT';

  @override
  String get runtimeSettingBlockchainDepositEthToUsdtRateDesc =>
      'Used when price oracle unavailable.';

  @override
  String get runtimeSettingBlockchainDepositSolToUsdtRateName =>
      'Fallback rate SOL → USDT';

  @override
  String get runtimeSettingBlockchainDepositSolToUsdtRateDesc =>
      'Used when price oracle unavailable.';

  @override
  String get treasuryCreateWalletFab => 'Create wallet';

  @override
  String get treasuryCreateWalletDialogTitle => 'Create transaction wallet';

  @override
  String get treasuryCreateWalletCta => 'Create wallet';

  @override
  String get treasuryCreateWalletNoChainListFromApi =>
      'Could not load networks from the server. Check your connection and tap Retry.';

  @override
  String get treasuryCreateWalletNetworkTronTrc20Testnet =>
      'Tron (testnet, TRC-20)';

  @override
  String get treasuryCreateWalletNetworkSolanaSplDevnet =>
      'Solana (devnet, SPL)';

  @override
  String get treasuryCreateWalletNetworkBscMetaMaskChapel =>
      'BNB Smart Chain Chapel (MetaMask)';

  @override
  String get treasuryChainLabel => 'Chain';

  @override
  String get treasuryPurposeLabel => 'Purpose';

  @override
  String get treasuryTypeLabel => 'Type';

  @override
  String get treasuryLabelOptional => 'Label (optional)';

  @override
  String get treasuryFilterAll => 'All';

  @override
  String get treasuryNoWalletsYet =>
      'No transaction wallets yet. Tap \"Create wallet\" to start.';

  @override
  String get treasuryOpsGuideTitle => 'Tip';

  @override
  String get treasuryOpsGuideSummary =>
      'Sweep: move funds to the main wallet. Fund: send from main to this wallet.';

  @override
  String get treasuryOpsPublicAddressLabel => 'Public address';

  @override
  String get treasuryOpsAddressCopiedSnack =>
      'Public address copied to clipboard.';

  @override
  String get treasuryStatusActive => 'ACTIVE';

  @override
  String get treasuryStatusInactive => 'INACTIVE';

  @override
  String get treasuryBalanceLabel => 'Balance';

  @override
  String get treasurySweepAction => 'Sweep to main';

  @override
  String get treasurySweepTooltip =>
      'Sweep funds from this wallet to the main wallet';

  @override
  String get treasurySweepDialogTitle => 'Sweep to main wallet';

  @override
  String get treasurySweepTargetLabel => 'Sweep to';

  @override
  String get treasuryOpsAssetLabel => 'Asset';

  @override
  String get treasuryOpsUsdtTrc20Short => 'USDT';

  @override
  String get treasuryOpsSweepUsdtHint =>
      'Transfers all USDT (TRC-20) on this wallet to the selected main wallet.';

  @override
  String get treasuryOpsNativeAssetOptionHint => 'Network native coin';

  @override
  String get treasuryFundAction => 'Fund wallet';

  @override
  String get treasuryFundTooltip => 'Fund this wallet from the main wallet';

  @override
  String get treasurySweepQueued => 'Sweep sent — pending confirmation.';

  @override
  String get treasurySweepFailed => 'Sweep failed';

  @override
  String get treasuryFundDialogTitle => 'Fund from main wallet';

  @override
  String get treasuryAmountLabel => 'Amount';

  @override
  String get treasuryAmountHint => 'Example: 0.5';

  @override
  String get treasuryCancelAction => 'Cancel';

  @override
  String get treasuryConfirmAction => 'Confirm';

  @override
  String get treasuryFundQueued => 'Funding sent — pending confirmation.';

  @override
  String get treasuryWalletPendingOnChainBadge => 'Processing on-chain…';

  @override
  String get treasuryQueuedBalanceHint =>
      'Balance updates after the transaction confirms.';

  @override
  String get treasuryPendingOnChainTooltipGeneric =>
      'A Fund or Sweep is processing on-chain. The balance on this card has not updated yet.';

  @override
  String treasuryPendingOnChainTooltipWithId(String operationId) {
    return 'Operation $operationId is pending on-chain. The balance will not reflect new funds until it completes.';
  }

  @override
  String get treasuryFundFailed => 'Fund failed';

  @override
  String get treasuryOperationsTitle => 'Treasury operations';

  @override
  String get treasuryNoOperations => 'No operations yet';

  @override
  String get treasuryTransactionsTitle => 'On-chain transactions';

  @override
  String get treasuryNoTransactions => 'No transactions yet';

  @override
  String get treasurySearchHint => 'Tx hash, operation id, address…';

  @override
  String get treasuryHistorySearchLabel => 'Search';

  @override
  String get treasuryHistoryIdLabel => 'ID';

  @override
  String get treasuryHistoryTxHash => 'Tx hash';

  @override
  String get treasuryHistoryFrom => 'From';

  @override
  String get treasuryHistoryTo => 'To';

  @override
  String get treasuryHistoryTypeFund => 'Fund';

  @override
  String get treasuryHistoryTypeSweep => 'Sweep';

  @override
  String get treasuryHistoryStatusPending => 'Queued';

  @override
  String get treasuryHistoryStatusQueuedHint =>
      'Waiting in line — another fund/sweep on this wallet may be running.';

  @override
  String get apiErrorTreasuryWalletBusy =>
      'Waiting for the previous treasury operation on this wallet to finish.';

  @override
  String get apiErrorTreasuryWalletBusyTimeout =>
      'Timed out waiting for the treasury wallet lock (over 15 minutes).';

  @override
  String get treasuryHistoryStatusProcessing => 'Processing';

  @override
  String get treasuryHistoryStatusConfirming => 'Confirming';

  @override
  String get treasuryHistoryStatusCompleted => 'Completed';

  @override
  String get treasuryHistoryStatusFailed => 'Failed';

  @override
  String get treasuryHistoryLoadMore => 'Load more';

  @override
  String get treasuryOpsManualMenu => 'Manual actions';

  @override
  String get treasuryOpsManualRetry => 'Retry job';

  @override
  String get treasuryOpsManualAbort => 'Mark as failed';

  @override
  String get treasuryOpsManualSettle => 'Confirm with tx hash';

  @override
  String get treasuryOpsManualRetryTitle => 'Retry treasury job';

  @override
  String get treasuryOpsManualRetryMessage =>
      'Releases the wallet lock and queues the worker again. Use when a fund/sweep job is stuck.';

  @override
  String get treasuryOpsManualSweepMainWalletHint =>
      'Main wallet ID (sweep only, if not default)';

  @override
  String get treasuryOpsManualAbortTitle => 'Abort operation';

  @override
  String get treasuryOpsManualAbortMessage =>
      'Marks this operation as failed so you can run a new fund or sweep. Use if the job will never complete.';

  @override
  String get treasuryOpsManualAbortReason => 'Reason (optional)';

  @override
  String get treasuryOpsManualSettleTitle => 'Confirm on-chain transaction';

  @override
  String get treasuryOpsManualSettleMessage =>
      'If funds already moved on-chain but the order is still queued or processing, enter the transaction hash to close the order.';

  @override
  String get treasuryOpsManualTxHash => 'Transaction hash';

  @override
  String get treasuryOpsManualMainWalletOptional =>
      'Main wallet ID (optional, sweep to non-default)';

  @override
  String get treasuryOpsManualSuccess => 'Updated';

  @override
  String get apiErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String apiErrorTxWalletNonZeroBalance(String maxAmount, String symbol) {
    return 'Sweep funds first (on-chain balance must be at most $maxAmount $symbol)';
  }

  @override
  String get apiErrorTxWalletNonZeroBalanceShort =>
      'Sweep funds first — reduce on-chain balance before deleting this wallet.';

  @override
  String get apiErrorTxWalletUsdtNonZero =>
      'Move TRC-20 USDT off this wallet before deleting it.';

  @override
  String get apiErrorTxWalletDefaultDepositDelete =>
      'Unset this wallet as the user deposit default before deleting it.';

  @override
  String get apiErrorTxWalletOperationInFlight =>
      'Wait for pending Fund or Sweep operations to finish before deleting this wallet.';

  @override
  String get apiErrorTxWalletExists =>
      'A transaction wallet with this chain and purpose already exists.';

  @override
  String get apiErrorTreasuryWalletInactive =>
      'This transaction wallet is inactive.';

  @override
  String get apiErrorTreasuryWalletLocked =>
      'Another treasury operation is running on this wallet. Try again shortly.';

  @override
  String get apiErrorDefaultUserDepositDeactivate =>
      'You cannot deactivate the current default user deposit wallet.';

  @override
  String get apiErrorTronUsdtDestinationNotActivated =>
      'The destination TRON wallet is not activated yet. Deposit TRX to that address before sending USDT.';

  @override
  String get apiErrorTronAccountPreflightUnavailable =>
      'Could not check the destination TRON wallet status right now. Please try again later.';

  @override
  String get treasuryWalletCreatedSuccess => 'Transaction wallet created';

  @override
  String get treasuryOpsDeleteWalletTooltip => 'Delete this transaction wallet';

  @override
  String get treasuryOpsDeleteWalletTitle => 'Delete transaction wallet?';

  @override
  String get treasuryOpsDeleteWalletBody =>
      'Removes this Fund/Sweep wallet from the system. You must sweep funds first (near-zero balance), finish any pending Fund/Sweep, and unset it as the user deposit default if applicable.';

  @override
  String get treasuryOpsDeleteWalletSuccessSnack =>
      'Transaction wallet deleted.';

  @override
  String get treasuryOpsDeleteWalletAction => 'Delete';

  @override
  String recommendedChainUpdated(String chain) {
    return 'Recommended chain updated to $chain';
  }

  @override
  String get managedWalletsSection => 'Wallets';

  @override
  String managedWalletsTotalCount(int count) {
    return '$count total';
  }

  @override
  String get managedWalletsNewWallet => 'New Wallet';

  @override
  String get managedWalletsActiveDefaults => 'Active Deposit Defaults';

  @override
  String get managedWalletsNotConfigured => 'Not configured';

  @override
  String get managedWalletsRecommendedChainTitle =>
      'Recommended Chain for Users';

  @override
  String get managedWalletsRecommendedChainDesc =>
      'Users will see this chain as the primary deposit option.';

  @override
  String get managedWalletsRecommendedChainLabel => 'Recommended Chain';

  @override
  String get managedWalletsSelectChain => 'Select chain';

  @override
  String get managedWalletsNoWallets => 'No wallets yet';

  @override
  String get managedWalletsNoWalletsDesc =>
      'Create Tron operational wallets under Payment configuration → Treasury (purpose DEPOSIT or BOTH), then pick the default deposit address per chain here.';

  @override
  String get managedWalletsCreateFirst => 'Create First Wallet';

  @override
  String get walletSetAsDefault => 'Wallet set as default deposit address';

  @override
  String get walletDeactivated => 'Wallet deactivated';

  @override
  String get deactivateWalletTitle => 'Deactivate Wallet';

  @override
  String get deactivateWalletContent =>
      'This wallet will be deactivated and can no longer receive or send funds. This cannot be undone.';

  @override
  String get deactivateWalletAction => 'Deactivate';

  @override
  String get managedWalletOnchainBalance => 'On-chain Balance';

  @override
  String get managedWalletSetDefault => 'Set as Default';

  @override
  String get managedWalletDefaultDeposit => 'Default Deposit';

  @override
  String get managedWalletClearDefaultDeposit => 'Remove default';

  @override
  String get managedWalletClearDefaultDepositTitle => 'Remove default deposit?';

  @override
  String get managedWalletClearDefaultDepositBody =>
      'This chain will have no default deposit address until you set another wallet. On-chain deposits for this network stay disabled until then.';

  @override
  String get managedWalletClearDefaultDepositAction => 'Remove';

  @override
  String get managedWalletClearDefaultDepositSuccess =>
      'Default deposit address removed.';

  @override
  String get managedWalletSendTrx => 'Send TRX';

  @override
  String get managedWalletTxHistory => 'Transaction History';

  @override
  String get managedWalletNoTx => 'No transactions yet';

  @override
  String get sendTrxTitle => 'Send TRX';

  @override
  String get sendTrxConfirmTitle => 'Confirm Send';

  @override
  String sendTrxConfirmContent(String amount, String address) {
    return 'Send $amount TRX to\n$address?';
  }

  @override
  String get sendTrxConfirm => 'Confirm';

  @override
  String get sendTrxRecipientLabel => 'Recipient Address';

  @override
  String get sendTrxRecipientHint => 'T...';

  @override
  String get sendTrxAddressRequired => 'Address is required';

  @override
  String get sendTrxInvalidAddress => 'Invalid address';

  @override
  String get sendTrxAmountLabel => 'Amount (TRX)';

  @override
  String get sendTrxAmountHint => '0.00';

  @override
  String get sendTrxAmountRequired => 'Amount is required';

  @override
  String get sendTrxAmountInvalid => 'Enter a valid amount';

  @override
  String get sendTrxSending => 'Sending...';

  @override
  String get sendTrxSend => 'Send';

  @override
  String get sendTrxSuccess => 'Transaction sent successfully';

  @override
  String get createWalletTitle => 'Create Treasury Wallet';

  @override
  String get createWalletBlockchainLabel => 'Blockchain';

  @override
  String get createWalletLabelField => 'Label (optional)';

  @override
  String get createWalletLabelHint => 'e.g. Main Fund, AML Reserve';

  @override
  String get createWalletGenerating => 'Generating...';

  @override
  String get createWalletGenerate => 'Generate Wallet';

  @override
  String get createWalletSecurityNote =>
      'A new Tron wallet will be generated. The private key is encrypted and stored securely. You will never be shown the private key.';

  @override
  String get createWalletSuccess => 'Wallet Created!';

  @override
  String get createWalletAddressLabel => 'Wallet Address';

  @override
  String get createWalletAddressCopied => 'Address copied';

  @override
  String get createWalletDone => 'Done';

  @override
  String get createWalletFailed => 'Failed to create wallet';

  @override
  String get walletBadgeDefault => 'DEFAULT';

  @override
  String get walletBadgeInactive => 'INACTIVE';

  @override
  String get depositMethodsTitle => 'Platform Deposit Methods';

  @override
  String get depositMethodRecommended => 'Recommended';

  @override
  String get depositMethodUnavailable => 'Not available';

  @override
  String get copyAddressTooltip => 'Copy address';

  @override
  String get marketMakerHubTitle => 'Market Maker';

  @override
  String get marketMakerHubDrawerSubtitle =>
      'Dashboard · Config · Maker orders';

  @override
  String get marketMakerConfigCardTitle => 'Market Maker configuration';

  @override
  String get marketMakerConfigCardSubtitle =>
      'Manage spread, stop-loss, and position limits per trading pair.';

  @override
  String get marketMakerPlaceOrdersCardTitle => 'Place maker orders';

  @override
  String get marketMakerPlaceOrdersCardSubtitle =>
      'Place BUY/SELL order pairs around market price using batch orders.';

  @override
  String get marketMakerPositionDashboardCardTitle => 'Position dashboard';

  @override
  String get marketMakerPositionDashboardCardSubtitle =>
      'Monitor open orders, positions, and unrealized P/L in real time.';

  @override
  String get marketMakerDashboardComingSoon =>
      'Position dashboard — coming soon';

  @override
  String get marketMakerFieldPair => 'Pair';

  @override
  String get marketMakerFieldSpreadBps => 'Spread (bps)';

  @override
  String get marketMakerFieldSpreadAlertBps => 'Spread alert threshold (bps)';

  @override
  String get marketMakerFieldOrderAmount => 'Order amount';

  @override
  String get marketMakerFieldStopLossOptional => 'Stop-loss % (optional)';

  @override
  String get marketMakerFieldMaxPositionBaseOptional =>
      'Max position base (optional)';

  @override
  String get marketMakerFieldActiveConfig => 'Active config';

  @override
  String get marketMakerFieldOrderAmountOverrideOptional =>
      'Place order amount override (optional)';

  @override
  String get marketMakerFieldRefreshCycleKeyOptional =>
      'Refresh cycle key (optional idempotency)';

  @override
  String get marketMakerButtonSaveConfig => 'Save config';

  @override
  String get marketMakerButtonDelete => 'Delete';

  @override
  String get marketMakerButtonPlaceTwoSidedOrders =>
      'Place two-sided maker orders';

  @override
  String get marketMakerValidationSpreadBps => 'Invalid spread (bps)';

  @override
  String get marketMakerValidationAlertThreshold => 'Invalid alert threshold';

  @override
  String get marketMakerValidationOrderAmount => 'Invalid order amount';

  @override
  String get marketMakerNoActivePairs => 'No active trading pairs found';

  @override
  String marketMakerLastUpdated(String when) {
    return 'Last updated: $when';
  }

  @override
  String get marketMakerSnackSavedConfig => 'Saved market maker configuration';

  @override
  String get marketMakerSnackSaveFailed => 'Save failed';

  @override
  String get marketMakerSnackDeletedConfig =>
      'Deleted market maker configuration';

  @override
  String get marketMakerSnackDeleteFailed => 'Delete failed';

  @override
  String get marketMakerSnackPlaceOrdersFailed => 'Place maker orders failed';

  @override
  String get marketMakerOrdersResultReplayed => 'Replayed';

  @override
  String get marketMakerOrdersResultRefreshed => 'Refreshed';

  @override
  String marketMakerOrdersPlacedSummary(String action, String cancelled,
      String placed, String buyPrice, String sellPrice) {
    return '$action: cancelled $cancelled, placed $placed (BUY: $buyPrice, SELL: $sellPrice)';
  }

  @override
  String get marketMakerPlaceOrdersFormHint =>
      'Uses the saved configuration for the selected pair. Override amount or idempotency key if needed.';

  @override
  String get marketMakerHubWelcomeTitle => 'Market Maker workspace';

  @override
  String get marketMakerHubWelcomeSubtitle =>
      'Configure market-making parameters, place orders around the market price, and monitor positions in real time.';

  @override
  String get marketMakerHubBadgeComingSoon => 'Coming soon';

  @override
  String get marketMakerHubBadgeReady => 'Ready';

  @override
  String get marketMakerSectionPair => 'Trading pair';

  @override
  String get marketMakerSectionTradingParams => 'Trading parameters';

  @override
  String get marketMakerSectionOrderAmount => 'Order amount';

  @override
  String get marketMakerSectionRiskControls => 'Risk controls';

  @override
  String get marketMakerSectionOrderParams => 'Order parameters';

  @override
  String get marketMakerDeleteConfirmTitle => 'Delete configuration';

  @override
  String marketMakerDeleteConfirmContent(String symbol) {
    return 'Delete the Market Maker configuration for $symbol? This action cannot be undone.';
  }

  @override
  String get marketMakerPlaceOrdersInfoBanner =>
      'Uses the saved configuration for the selected pair.';

  @override
  String get marketMakerTooltipOrderAmountOverride =>
      'Override the order amount from the saved configuration. Leave empty to use the saved value.';

  @override
  String get marketMakerTooltipRefreshCycleKey =>
      'Idempotency key to prevent duplicate placements. Leave empty to auto-generate.';

  @override
  String get marketMakerStatActive => 'Active';

  @override
  String get marketMakerStatInactive => 'Inactive';

  @override
  String get marketMakerStatSpread => 'Spread';

  @override
  String get marketMakerStatBpsUnit => 'bps';

  @override
  String get marketMakerErrorLoadDefaults =>
      'Failed to load default form values';

  @override
  String get marketMakerErrorLoadConfigs =>
      'Failed to load market maker configurations';

  @override
  String get marketMakerErrorSaveConfig =>
      'Failed to save market maker configuration';

  @override
  String get marketMakerErrorDeleteConfig =>
      'Failed to delete market maker configuration';

  @override
  String get marketMakerErrorPlaceOrders => 'Failed to place maker orders';

  @override
  String get marketMakerErrorLoadActivePairs =>
      'Failed to load active trading pairs';

  @override
  String get adminCurrenciesTitle => 'Admin - Currencies';

  @override
  String get adminCurrenciesCreateTitle => 'Create new coin';

  @override
  String get adminCurrenciesDeleteTitle => 'Delete coin';

  @override
  String get adminCurrenciesDeleteConfirmMessage =>
      'Are you sure you want to delete this coin?';

  @override
  String adminCurrenciesEditTitle(String symbol) {
    return 'Edit $symbol';
  }

  @override
  String get adminCurrenciesEdit => 'Edit';

  @override
  String get adminCurrenciesCancel => 'Cancel';

  @override
  String get adminCurrenciesCreateAction => 'Create';

  @override
  String get adminCurrenciesSaveAction => 'Save';

  @override
  String get adminCurrenciesDeleteAction => 'Delete';

  @override
  String get adminCurrenciesHide => 'Hide';

  @override
  String get adminCurrenciesShow => 'Show';

  @override
  String get adminCurrenciesTradableLabel => 'Tradable';

  @override
  String get adminCurrenciesActiveLabel => 'Active';

  @override
  String get adminCurrenciesStatusLabel => 'Status';

  @override
  String get adminCurrenciesNameInputLabel => 'Name';

  @override
  String get adminCurrenciesPrecisionScaleLabel => 'Precision Scale';

  @override
  String get adminCurrenciesMinWithdrawLabel => 'Min Withdraw';

  @override
  String get adminCurrenciesFieldRequired => 'Required';

  @override
  String get adminCurrenciesRetryAction => 'Try again';

  @override
  String get adminCurrenciesCreateNewCoin => 'Create new coin';

  @override
  String get adminCurrenciesNoData => 'No data';

  @override
  String get adminCurrenciesSymbolLabel => 'Symbol';

  @override
  String get adminCurrenciesCreateSuccess => 'Coin created successfully!';

  @override
  String get adminCurrenciesUpdateSuccess => 'Coin updated successfully!';

  @override
  String get adminCurrenciesDeleteSuccess => 'Coin deleted successfully!';

  @override
  String get depositDetailStatus => 'Status';

  @override
  String get depositDetailOrderCode => 'Order Code';

  @override
  String get depositDetailCopied => 'Copied';

  @override
  String get depositDetailCreatedAt => 'Created at';

  @override
  String get depositDetailUpdatedAt => 'Updated at';

  @override
  String get depositDetailUserId => 'User ID';

  @override
  String get depositDetailViewUser => 'View user';

  @override
  String get depositStatusPaid => 'Paid';

  @override
  String get depositStatusPending => 'Pending';

  @override
  String get depositStatusCancelled => 'Cancelled';

  @override
  String get withdrawalDetailInfoTitle => 'Transaction Details';

  @override
  String get withdrawalDetailAmount => 'Amount';

  @override
  String get withdrawalDetailChain => 'Network';

  @override
  String get withdrawalDetailStatus => 'Status';

  @override
  String get withdrawalDetailCopied => 'Copied';

  @override
  String get withdrawalDetailAddress => 'Address';

  @override
  String get withdrawalDetailTxHash => 'Transaction Hash';

  @override
  String get withdrawalDetailCreatedAt => 'Created at';

  @override
  String get withdrawalDetailUpdatedAt => 'Updated at';

  @override
  String get withdrawalDetailConfirmations => 'Confirmations';

  @override
  String get withdrawalDetailUserId => 'User ID';

  @override
  String get withdrawalDetailViewUser => 'View user';

  @override
  String get withdrawalStatusCompleted => 'Completed';

  @override
  String get withdrawalStatusConfirming => 'Confirming';

  @override
  String get withdrawalStatusPending => 'Pending';

  @override
  String get withdrawalStatusFailed => 'Failed';

  @override
  String get withdrawalDetailTitle => 'Withdrawal Details';

  @override
  String get withdrawalNotFound => 'Withdrawal not found';

  @override
  String get withdrawalApprovedSnack => 'Withdrawal approved';

  @override
  String get withdrawalApproveButton => 'Approve';

  @override
  String get withdrawalApproveConfirmTitle => 'Confirm Withdrawal Approval';

  @override
  String get withdrawalApproveConfirmContent =>
      'Are you sure you want to approve this withdrawal? The funds will be sent immediately and cannot be reversed.';

  @override
  String get withdrawalApproveConfirmAction => 'Yes, Approve';

  @override
  String get withdrawalApproveAllConfirmTitle => 'Confirm Batch Approval';

  @override
  String get withdrawalApproveAllConfirmContent =>
      'You are about to approve all pending withdrawals. Each withdrawal will trigger a blockchain transaction. This action cannot be undone.';

  @override
  String get withdrawalApproveAllConfirmAction => 'Approve All';

  @override
  String get withdrawalDetailUser => 'User';

  @override
  String get withdrawalDetailToAddress => 'Destination';

  @override
  String get withdrawalRejectButton => 'Reject';

  @override
  String get withdrawalRejectDialogTitle => 'Reject withdrawal';

  @override
  String get withdrawalRejectReasonHint => 'Reason (optional)';

  @override
  String get withdrawalRejectedSnack => 'Withdrawal rejected';

  @override
  String get withdrawalUserInfoTitle => 'User Information';

  @override
  String get withdrawalBalanceLabel => 'Balance';

  @override
  String get withdrawalTransactionTitle => 'Transaction Information';

  @override
  String get withdrawalNetworkLabel => 'Network';

  @override
  String get withdrawalAmountLabel => 'Amount';

  @override
  String get withdrawalDestinationLabel => 'Destination';

  @override
  String get withdrawalTimeLabel => 'Time';

  @override
  String get withdrawalTxHashLabel => 'Tx Hash';

  @override
  String get withdrawalStatusRequested => 'Requested';

  @override
  String get withdrawalStatusApproved => 'Approved';

  @override
  String get withdrawalStatusSent => 'Sent';

  @override
  String get withdrawalStatusLabel => 'Status';

  @override
  String get withdrawalStatusRejected => 'Rejected';

  @override
  String get adminCurrenciesSearchHint => 'Search currencies...';

  @override
  String get adminCurrenciesFilterAll => 'All';

  @override
  String get adminCurrenciesFilterActive => 'Active';

  @override
  String get adminCurrenciesFilterInactive => 'Inactive';

  @override
  String get adminCurrenciesTradingLabel => 'Trading';

  @override
  String get adminCurrenciesFilterTradable => 'Tradable';

  @override
  String get adminCurrenciesFilterPaused => 'Paused';

  @override
  String get adminCurrenciesNoCoinsFound => 'No coins found';

  @override
  String get adminCurrenciesCreateCoin => 'Create coin';

  @override
  String adminCurrenciesDeleteConfirmWithPair(String symbol, String name) {
    return 'Are you sure you want to delete \"$symbol — $name\"?\nThis action cannot be undone.';
  }

  @override
  String adminCurrenciesListMeta(String precision, String minWithdraw) {
    return 'Precision: $precision · Min withdraw: $minWithdraw';
  }

  @override
  String get adminCurrenciesTradableBadgeOn => 'Trade';

  @override
  String get adminCurrenciesTradableBadgeOff => 'Off';

  @override
  String get adminCurrenciesTradingPausedTooltip => 'Trading paused';

  @override
  String get adminCurrenciesReadOnlyBanner =>
      'You are in read-only mode. Any change to the coin catalog requires an Admin account.';

  @override
  String get adminCurrenciesReadOnlySubtitle => 'Read-only';

  @override
  String adminCurrenciesCountSummary(
      int total, int active, int inactive, int tradable, int paused) {
    return 'Total $total · Active $active · Inactive $inactive · Tradable $tradable · Paused $paused';
  }

  @override
  String get adminCurrenciesDetailPrecision => 'Precision scale';

  @override
  String get adminCurrenciesDetailMinWithdraw => 'Min withdraw';

  @override
  String get adminCurrenciesDetailStatus => 'Status';

  @override
  String get adminCurrenciesDetailTrading => 'Tradable';

  @override
  String get adminCurrenciesDetailCreatedAt => 'Created at';

  @override
  String get adminCurrenciesDetailUpdatedAt => 'Updated at';

  @override
  String get adminCurrenciesDetailCopySymbol => 'Copy symbol';

  @override
  String adminCurrenciesCopySymbolDone(String symbol) {
    return 'Copied $symbol';
  }

  @override
  String get adminCurrenciesRefreshTooltip => 'Refresh';

  @override
  String get adminCurrenciesStatusActive => 'Active';

  @override
  String get adminCurrenciesStatusInactive => 'Inactive';

  @override
  String get adminCurrenciesStatusTradable => 'Tradable';

  @override
  String get adminCurrenciesStatusPaused => 'Trading paused';

  @override
  String get adminCurrenciesSectionBasic => 'Basic info';

  @override
  String get adminCurrenciesSectionTrading => 'Trading parameters';

  @override
  String get adminCurrenciesSectionStatus => 'Status';

  @override
  String adminShowingCount(int shown, int total, String label) {
    return 'Showing $shown of $total $label';
  }

  @override
  String get adminRetryButton => 'Retry';

  @override
  String payosTransitioningBanner(int minutes) {
    return 'PayOS payment method will be activated in $minutes minute(s)';
  }

  @override
  String payosTransitioningGraceMinutes(int minutes) {
    return 'Activation in $minutes minute(s)';
  }

  @override
  String get payosTransitioningUnderOneMinute =>
      'PayOS will be activated in less than a minute';

  @override
  String get payosTransitioningFinalizePending =>
      'PayOS activation is finishing — please wait';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get snackbarOk => 'OK';

  @override
  String get adminUserDetailTabWallets => 'Wallets';

  @override
  String get adminUserDetailTabAdjust => 'Adjust';

  @override
  String get adminUserDetailTabOrders => 'Orders';

  @override
  String get adminUserDetailTabOnchain => 'On-chain';

  @override
  String get adminUserDetailTabSecurity => 'Security';

  @override
  String get adminUserDetailCreatedAtLabel => 'Created at';

  @override
  String get withdrawalManagementTitle => 'Withdrawal Management';

  @override
  String get withdrawalManagementTabPending => 'Pending';

  @override
  String get withdrawalManagementTabAll => 'All';

  @override
  String get withdrawalApproveAllSmallTitle => 'Approve All';

  @override
  String get withdrawalApproveAllSmallContent =>
      'Approve all pending withdrawals?';

  @override
  String get withdrawalApproveAllProcess => 'Processing...';

  @override
  String get withdrawalProcessedSnack => 'Withdrawals processed successfully';

  @override
  String withdrawalStatsPendingCount(int count) {
    return '$count pending';
  }

  @override
  String get adminFilterAll => 'All';

  @override
  String get withdrawalSearchHint => 'Search by user ID or wallet address...';

  @override
  String get withdrawalApproveLabel => 'Approve';

  @override
  String get withdrawalRejectLabel => 'Reject';

  @override
  String get withdrawalRejectConfirmTitle => 'Confirm Rejection';

  @override
  String get withdrawalRejectConfirmAction => 'Reject';

  @override
  String get withdrawalRejectReasonLabel => 'Rejection reason';

  @override
  String get withdrawalReconcileSuccessSnack => 'Action completed successfully';

  @override
  String get withdrawalReconcileSettleLabel => 'Settle';

  @override
  String get withdrawalReconcileSettleTitle => 'Settle Withdrawal?';

  @override
  String get withdrawalReconcileSettleContent =>
      'Re-check the blockchain status and settle accordingly. This will update the withdrawal based on the current on-chain state.';

  @override
  String get withdrawalForceCompleteLabel => 'Force Complete';

  @override
  String get withdrawalForceCompleteTitle => 'Force Complete Withdrawal?';

  @override
  String get withdrawalForceCompleteContent =>
      'Mark this withdrawal as COMPLETED without checking blockchain. Use when you have personally confirmed the on-chain transaction is confirmed.';

  @override
  String get withdrawalForceFailLabel => 'Force Fail';

  @override
  String get withdrawalForceFailTitle => 'Force Fail Withdrawal?';

  @override
  String get withdrawalForceFailContent =>
      'Mark as FAILED and refund frozen balance to the user. Use when the blockchain transaction cannot be completed.';

  @override
  String get withdrawalForceFailConfirmAction => 'Force Fail';

  @override
  String get withdrawalForceRefundLabel => 'Refund Balance';

  @override
  String get withdrawalForceRefundTitle => 'Refund User Balance?';

  @override
  String get withdrawalForceRefundContent =>
      'Refund the frozen balance to the user without changing the transaction status. Use when the user was debited but the transaction was never properly recorded.';

  @override
  String get withdrawalNoRequests => 'No withdrawal requests';

  @override
  String get drawerTransactionMonitoring => 'Transaction Monitoring';

  @override
  String get adminTabOrders => 'Orders';

  @override
  String get adminTabDeposits => 'Deposits';

  @override
  String get adminTabWithdrawals => 'Withdrawals';

  @override
  String get orderStatusOpen => 'Open';

  @override
  String get orderStatusPartial => 'Partially Filled';

  @override
  String get orderStatusFilled => 'Filled';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusRejected => 'Rejected';

  @override
  String get filterByUserId => 'Filter by User ID';

  @override
  String get adminPairIdFilterHint =>
      'pair_id (UUID) or symbol e.g. OG/USDT — filter & reconcile';

  @override
  String get adminReconcileMatchingButton => 'Re-run matching';

  @override
  String get adminReconcileMatchingPairRequired =>
      'Enter pair_id (UUID) or symbol BASE/QUOTE.';

  @override
  String get adminOrderPairIdLabel => 'pair_id';

  @override
  String get adminOrderPairIdCopyTooltip => 'Copy pair_id for reconcile field';

  @override
  String get adminOrderPairIdCopied => 'pair_id copied';

  @override
  String get adminReconcileMatchingConfirmTitle => 'Re-run order matching?';

  @override
  String adminReconcileMatchingConfirmMessage(String pairId) {
    return 'Retry matching for all open orders on this pair: $pairId';
  }

  @override
  String get adminReconcileMatchingRun => 'Run';

  @override
  String get adminReconcileMatchingCancel => 'Cancel';

  @override
  String adminReconcileMatchingSuccess(int trades, int open, String reason) {
    return 'Reconcile done. Trades: $trades, still open: $open, outcome: $reason';
  }

  @override
  String get adminReconcileReasonAllMatched => 'all matched';

  @override
  String get adminReconcileReasonNoProgress => 'no further matches';

  @override
  String get adminReconcileReasonMaxRounds => 'stopped (safety limit)';

  @override
  String get adminOrdersEmpty => 'No orders';

  @override
  String adminOrdersCountLabel(int count) {
    return '$count orders';
  }

  @override
  String get adminDepositsEmpty => 'No deposits';

  @override
  String adminDepositsCountLabel(int count) {
    return '$count deposits';
  }

  @override
  String get adminUnmatchedDepositsTab => 'Unmatched';

  @override
  String get adminUnmatchedDepositsEmpty => 'No unmatched deposits';

  @override
  String adminUnmatchedDepositsCountLabel(int count) {
    return '$count unmatched';
  }

  @override
  String get adminUnmatchedDepositTitle => 'Unmatched Deposit';

  @override
  String get adminUnmatchedDepositChain => 'Chain';

  @override
  String get adminUnmatchedDepositAmount => 'Amount';

  @override
  String get adminUnmatchedDepositFrom => 'From Address';

  @override
  String get adminUnmatchedDepositTxHash => 'Tx Hash';

  @override
  String get adminUnmatchedDepositDetectedAt => 'Detected at';

  @override
  String get adminMatchUserButton => 'Match User';

  @override
  String get adminMatchUserDialogTitle => 'Assign User to Deposit';

  @override
  String adminMatchUserDialogSubtitle(String txId) {
    return 'Deposit: $txId';
  }

  @override
  String get adminMatchUserIdHint => 'User ID (UUID)';

  @override
  String get adminMatchUserIdLabel => 'User ID';

  @override
  String get adminMatchUserProposeButton => 'Propose Match';

  @override
  String get adminMatchUserApproveButton => 'Approve Match';

  @override
  String adminMatchUserPendingInfo(String matchId) {
    return 'A match proposal is pending (Match ID: $matchId). Approve to finalize.';
  }

  @override
  String get adminMatchUserProposedSuccess =>
      'Match proposed. Awaiting second approval.';

  @override
  String get adminMatchUserApprovedSuccess =>
      'Match approved. Deposit assigned to user.';

  @override
  String get adminMatchUserErrorTitle => 'Match Error';

  @override
  String get adminWithdrawalsEmpty => 'No withdrawals';

  @override
  String adminWithdrawalsCountLabel(int count) {
    return '$count withdrawals';
  }

  @override
  String get orderDetailTypeLimitLabel => 'Limit';

  @override
  String get orderDetailTypeMarketLabel => 'Market';

  @override
  String get adminOrderListBuyPriceLabel => 'Buy Price';

  @override
  String get adminOrderListSellPriceLabel => 'Sell Price';

  @override
  String get adminOrderListMarketPriceHint => '(Market Order)';

  @override
  String get adminUserLabel => 'User';

  @override
  String get orderDetailAmount => 'Amount';

  @override
  String get orderDetailPrice => 'Price';

  @override
  String get adminOrderCodeLabel => 'Order Code';

  @override
  String get adminTxHashLabel => 'Tx Hash';

  @override
  String get orderDetailSideBuy => 'Buy';

  @override
  String get orderDetailSideSell => 'Sell';

  @override
  String get orderDetailOrderId => 'Order ID';

  @override
  String get orderDetailCopied => 'Copied';

  @override
  String get orderDetailPair => 'Pair';

  @override
  String get orderDetailSide => 'Side';

  @override
  String get orderDetailType => 'Type';

  @override
  String get orderDetailTimeInForce => 'Time in force';

  @override
  String get orderDetailFilledAmount => 'Filled amount';

  @override
  String get orderDetailAvgPrice => 'Average price';

  @override
  String get orderDetailRemainingAmount => 'Remaining';

  @override
  String get orderDetailFilledPct => 'Filled %';

  @override
  String get orderDetailCreatedAt => 'Created at';

  @override
  String get orderDetailUpdatedAt => 'Updated at';

  @override
  String get orderDetailUserId => 'User ID';

  @override
  String get orderDetailViewUser => 'View user';

  @override
  String get depositDetailTitle => 'Deposit Details';

  @override
  String get depositDetailAmount => 'Amount';

  @override
  String get drawerSectionGeneral => 'General';

  @override
  String get drawerSectionAdministration => 'Administration';

  @override
  String get drawerSectionAdminUsers => 'Admin Users';

  @override
  String get drawerSectionAdminOps => 'Admin Operations';

  @override
  String get drawerTransactionMonitoringSubtitle =>
      'Orders, deposits, withdrawals';

  @override
  String get drawerCoinManagement => 'Coin Management';

  @override
  String get drawerCoinManagementSubtitleCrud => 'Create, update, delete';

  @override
  String get drawerCoinManagementSubtitleView => 'Read-only currency view';

  @override
  String get drawerSectionAdminSystem => 'Admin System';

  @override
  String get drawerSectionFinance => 'Finance';

  @override
  String get drawerPaymentConfig => 'Payment Configuration';

  @override
  String get drawerPaymentConfigSubtitle => 'Methods, wallets, activation';

  @override
  String get drawerTreasuryMainWalletsTitle => 'System Hot Wallets';

  @override
  String get drawerTreasuryMainWalletsSubtitle => 'Keys, approvals, MFA';

  @override
  String get treasuryMainWalletsTitle => 'System Hot Wallets Management';

  @override
  String get treasuryMainWalletsTabActive => 'Active Wallets';

  @override
  String get treasuryMainWalletsTabPending => 'Pending Approvals';

  @override
  String get treasuryMainWalletsEmptyActive => 'No active main wallets found.';

  @override
  String get treasuryMainWalletsEmptyPending =>
      'No pending wallets for approval.';

  @override
  String get treasuryMainWalletChipDefault => 'Default';

  @override
  String get treasuryMainWalletLabelNone => 'None';

  @override
  String get treasuryMainWalletTooltipSetDefault => 'Set as Default';

  @override
  String get treasuryMainWalletTooltipApprove => 'Approve';

  @override
  String get treasuryMainWalletTooltipReject => 'Reject';

  @override
  String get treasuryMainWalletUnknownTime => 'Unknown';

  @override
  String treasuryMainWalletCardSubtitle(
      String balance, String symbol, String label) {
    return 'Balance: $balance $symbol\nLabel: $label';
  }

  @override
  String treasuryMainWalletPendingSubtitle(String dateTime) {
    return 'Added at: $dateTime';
  }

  @override
  String treasuryTrc20UsdtBalanceLine(String balance) {
    return 'USDT (TRC-20): $balance USDT';
  }

  @override
  String get treasuryNetworkLabel => 'Network';

  @override
  String get treasuryChainEcosystemTron => 'Tron';

  @override
  String get treasuryChainEcosystemEthereum => 'Ethereum';

  @override
  String get treasuryChainEcosystemBsc => 'BSC';

  @override
  String get treasuryChainEcosystemSolana => 'Solana';

  @override
  String get treasuryChainEcosystemBase => 'Base';

  @override
  String get treasuryChainEcosystemArbitrum => 'Arbitrum';

  @override
  String get treasuryChainEcosystemOptimism => 'Optimism';

  @override
  String get treasuryChainEcosystemPolygon => 'Polygon';

  @override
  String get treasuryChainEcosystemAvalanche => 'Avalanche';

  @override
  String get treasuryChainEcosystemGnosis => 'Gnosis';

  @override
  String get treasuryChainEcosystemLinea => 'Linea';

  @override
  String get treasuryChainEcosystemFantom => 'Fantom';

  @override
  String treasuryMainWalletBalanceLine(String balance, String symbol) {
    return 'Balance: $balance $symbol';
  }

  @override
  String treasuryMainWalletLabelLine(String label) {
    return 'Label: $label';
  }

  @override
  String get treasuryMainWalletPublicAddressLabel => 'Public address';

  @override
  String get treasuryMainWalletCopyAddressTooltip => 'Copy public address';

  @override
  String get treasuryMainWalletCopiedAddressSnack =>
      'Public address copied to clipboard.';

  @override
  String get treasuryMainWalletRevealPrivateKeyTooltip =>
      'Private key (email OTP)';

  @override
  String get treasuryMainWalletMenuCopyPrivateKey => 'Copy private key';

  @override
  String get treasuryMainWalletMenuEditLabel => 'Edit label';

  @override
  String get treasuryMainWalletMenuDelete =>
      'Request removal (Risk must approve)';

  @override
  String get treasuryMainWalletRevealKeyTitle => 'Copy private key';

  @override
  String get treasuryMainWalletRevealKeyHint =>
      'Send OTP to your email, enter the code, then copy the key.';

  @override
  String get treasuryMainWalletRevealKeyCopy => 'Reveal and copy';

  @override
  String get treasuryMainWalletCopiedPrivateKeySnack =>
      'Private key copied to clipboard.';

  @override
  String get treasuryMainWalletEditLabelTitle => 'Edit label';

  @override
  String get treasuryMainWalletEditLabelSave => 'Save';

  @override
  String get treasuryMainWalletLabelUpdatedSnack => 'Label updated.';

  @override
  String get treasuryMainWalletDeleteTitle => 'Request wallet removal?';

  @override
  String get treasuryMainWalletDeleteBody =>
      'A Risk Officer must approve before the wallet is removed. You cannot request removal of the default wallet if another active wallet exists for the chain.';

  @override
  String get treasuryMainWalletDeleteSuccessSnack =>
      'Removal requested — pending Risk approval.';

  @override
  String get treasuryMainWalletDeleteAction => 'Submit request';

  @override
  String get treasuryMainWalletChipPendingDeletion => 'Pending deletion';

  @override
  String get treasuryMainWalletPendingDeletionHint =>
      'Removal awaiting Risk Officer approval. This wallet is not used for Fund/Sweep until approved or cancelled.';

  @override
  String get treasuryMainWalletTooltipApproveDeletion =>
      'Approve deletion (remove wallet)';

  @override
  String get treasuryMainWalletTooltipRejectDeletion =>
      'Reject deletion (restore wallet)';

  @override
  String get treasuryChainTronNile => 'TRON — Nile testnet';

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
  String get treasuryChainTronShasta => 'TRON — Shasta testnet';

  @override
  String get treasuryChainEthMainnet => 'Ethereum — Mainnet';

  @override
  String get treasuryChainEthSepolia => 'Ethereum — Sepolia (testnet)';

  @override
  String get treasuryChainBaseMainnet => 'Base — Mainnet';

  @override
  String get treasuryChainBaseSepolia => 'Base — Sepolia (testnet)';

  @override
  String get treasuryChainArbitrumMainnet => 'Arbitrum — Mainnet';

  @override
  String get treasuryChainArbitrumSepolia => 'Arbitrum — Sepolia (testnet)';

  @override
  String get treasuryChainOptimismMainnet => 'Optimism — Mainnet';

  @override
  String get treasuryChainOptimismSepolia => 'Optimism — Sepolia (testnet)';

  @override
  String get treasuryChainPolygonMainnet => 'Polygon — Mainnet';

  @override
  String get treasuryChainPolygonAmoy => 'Polygon — Amoy (testnet)';

  @override
  String get treasuryChainAvalancheMainnet => 'Avalanche — Mainnet';

  @override
  String get treasuryChainAvalancheFuji => 'Avalanche — Fuji (testnet)';

  @override
  String get treasuryChainGnosisMainnet => 'Gnosis — Mainnet';

  @override
  String get treasuryChainGnosisChiado => 'Gnosis — Chiado (testnet)';

  @override
  String get treasuryChainLineaMainnet => 'Linea — Mainnet';

  @override
  String get treasuryChainLineaSepolia => 'Linea — Sepolia (testnet)';

  @override
  String get treasuryChainFantomMainnet => 'Fantom — Mainnet';

  @override
  String get treasuryChainFantomTestnet => 'Fantom — Testnet';

  @override
  String get treasuryChainTonMainnet => 'TON — Mainnet';

  @override
  String get treasuryChainTonTestnet => 'TON — Testnet';

  @override
  String treasuryImportWalletDialogTitle(String chainName) {
    return 'Import main wallet ($chainName)';
  }

  @override
  String get treasuryImportWalletDialogHeading => 'Import main wallet';

  @override
  String get treasuryImportWalletDialogChainLabel => 'Network';

  @override
  String get treasuryImportWalletOtpVerifiedBanner =>
      'Email verified — enter your wallet details below.';

  @override
  String get treasuryImportWalletLabelOptional => 'Label (optional)';

  @override
  String get treasuryImportWalletPrivateKey => 'Private key';

  @override
  String get treasuryImportWalletMfaCode => 'MFA code';

  @override
  String get treasuryImportWalletSendOtp => 'Send OTP';

  @override
  String get treasuryImportWalletImport => 'Import';

  @override
  String get treasuryImportWalletMfaSentSnack => 'MFA code sent to your email.';

  @override
  String treasuryImportWalletMfaFailedSnack(String error) {
    return 'Failed to send MFA: $error';
  }

  @override
  String get treasuryImportWalletRequiredSnack =>
      'Private key and MFA code are required.';

  @override
  String get treasuryImportWalletOtpStepHint =>
      'Tap Send OTP, enter the code from your email, and confirm. You can enter the label and private key only after the code is verified.';

  @override
  String get treasuryImportWalletConfirmOtp => 'Confirm code';

  @override
  String get treasuryImportWalletOtpEmpty => 'Enter the code from your email.';

  @override
  String treasuryImportWalletOtpVerifyFailed(String message) {
    return 'Could not verify: $message';
  }

  @override
  String get treasuryImportWalletPrivateKeyRequired =>
      'Private key is required.';

  @override
  String get treasuryImportWalletMistakeTronAddress =>
      'This looks like a TRON address (starts with T), not a private key. Paste the 64-character hex private key from your wallet export.';

  @override
  String get treasuryImportWalletMistakeEvmAddress =>
      'This looks like an EVM wallet address (0x…), not a private key. Paste the 64-character hex private key from your wallet export.';

  @override
  String get treasuryImportWalletSuccessSnack =>
      'Main wallet imported and activated.';

  @override
  String treasuryImportWalletErrorSnack(String error) {
    return 'Error: $error';
  }

  @override
  String get treasuryImportWalletMfaExpiredOnImport =>
      'This email code expired or was already used. Tap Send OTP for a new code, confirm it, then try importing again.';

  @override
  String get treasuryImportWalletMfaExpiredOnImportSnack =>
      'OTP expired or invalid. Tap Send OTP for a new code.';

  @override
  String get drawerWithdrawalManagement => 'Withdrawal Management';

  @override
  String get drawerWithdrawalManagementSubtitle =>
      'Review and process requests';

  @override
  String get drawerManagedWalletsTitle => 'User deposits & managed wallets';

  @override
  String get drawerManagedWalletsSubtitle =>
      'Default deposit addresses, priority chain, company wallets';

  @override
  String get drawerBlockchainHubTitle => 'Blockchain hub';

  @override
  String get drawerBlockchainHubSubtitle =>
      'On-chain deposits, withdrawals, tools';

  @override
  String get drawerSectionTreasuryDeposits => 'Treasury & deposits';

  @override
  String managedWalletOwnerHint(String userIdShort) {
    return 'Owner: $userIdShort';
  }

  @override
  String get drawerSectionAccount => 'Account';

  @override
  String get profileFirstName => 'First name';

  @override
  String get profileLastName => 'Last name';

  @override
  String get ordersPayosUsdtHint =>
      'Use PayOS to top up VND and buy USDT for trading.';

  @override
  String get priceHintExample => 'e.g. 65000';

  @override
  String get amountHintExample => 'e.g. 0.01';

  @override
  String get maxAmountButton => 'MAX';

  @override
  String amountMaxDecimals(int max) {
    return 'Amount supports up to $max decimal places';
  }

  @override
  String get priceMustBePositive => 'Price must be positive';

  @override
  String priceMaxDecimals(int max) {
    return 'Price supports up to $max decimal places';
  }

  @override
  String get tickerBid => 'Bid';

  @override
  String get tickerAsk => 'Ask';

  @override
  String get ticker24hHigh => '24h High';

  @override
  String get ticker24hLow => '24h Low';

  @override
  String get tickerVolume => 'Volume';

  @override
  String get orderColumnSide => 'Side';

  @override
  String get orderColumnTime => 'Time';

  @override
  String timeSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String timeMinutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String timeHoursShort(int hours) {
    return '${hours}h';
  }

  @override
  String get ordersSelectPairFirst => 'Select a trading pair first';

  @override
  String get myOrdersEmpty => 'No open orders';

  @override
  String ordersMyOrdersWithCount(int count) {
    return 'My Orders ($count)';
  }

  @override
  String get orderBookColumnSize => 'Size';

  @override
  String get orderBookColumnCount => 'Count';

  @override
  String get marketPriceAbbrev => 'MKT';

  @override
  String get orderFilledQuantity => 'Filled';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSeedColor => 'Seed color';

  @override
  String get walletDebugTitle => 'Wallet Debug';

  @override
  String get adminUserListRoleAll => 'All roles';

  @override
  String get adminUserListRoleTrader => 'Trader';

  @override
  String get adminUserListRoleVerified => 'Verified user';

  @override
  String get adminUserListRoleMarketMaker => 'Market maker';

  @override
  String get adminUserListRoleSupport => 'Support agent';

  @override
  String get adminUserListRoleRiskOfficer => 'Risk officer';

  @override
  String get adminUserListRoleAdmin => 'Admin';

  @override
  String get adminUserListRoleFinanceManager => 'Finance manager';

  @override
  String get adminUserListRoleGuest => 'Guest';

  @override
  String get adminUserListStatusActive => 'Active';

  @override
  String get adminUserListStatusBanned => 'Banned';

  @override
  String get adminUserListStatusPending => 'Pending';

  @override
  String get adminUserListTitle => 'Admin User List';

  @override
  String get adminUserListSearchHint => 'Search users by name, email or ID';

  @override
  String get adminUserListRoleLabel => 'Role';

  @override
  String get adminUserListStatusLabel => 'Status';

  @override
  String adminUserListTotalUsers(int count) {
    return 'Total users: $count';
  }

  @override
  String get adminUserListNoUsersFound => 'No users found';

  @override
  String get adminUserListSelectUserPlaceholder =>
      'Select a user to view details';

  @override
  String get adminUserDetailNoteLabel => 'Note';

  @override
  String get adminWalletAdjustSelectUserRequired => 'Please select a user';

  @override
  String get adminWalletAdjustError => 'Adjustment failed';

  @override
  String get adminWalletAdjustUserIdRequired => 'User ID is required';

  @override
  String get adminWalletAdjustTitle => 'Wallet Adjustment';

  @override
  String get adminWalletAdjustDepositWithdrawTab => 'Deposit/Withdraw';

  @override
  String get adminWalletAdjustHistoryTab => 'History';

  @override
  String get adminWalletAdjustUseUserMgmt => 'Use User Management';

  @override
  String get adminWalletAdjustUseUserMgmtSubtitle =>
      'Pick user from admin user list';

  @override
  String get adminWalletAdjustOpen => 'Open';

  @override
  String get adminWalletAdjustOperationType => 'Operation type';

  @override
  String get adminWalletAdjustInfo => 'Adjustment Information';

  @override
  String get adminWalletAdjustSelectUserHint => 'Enter user ID';

  @override
  String get adminWalletAdjustCoinTypeLabel => 'Coin type';

  @override
  String get adminWalletAdjustCoinSearchHint => 'Search coin...';

  @override
  String get adminWalletAdjustNoCoinsFound => 'No coins found';

  @override
  String get adminWalletAdjustSelectCoinRequired => 'Please select a coin type';

  @override
  String adminUserDetailAdjustDepositSuccess(Object symbol) {
    return 'Deposited $symbol successfully!';
  }

  @override
  String adminUserDetailAdjustWithdrawSuccess(Object symbol) {
    return 'Withdrew $symbol successfully!';
  }

  @override
  String get adminUserDetailAdjustmentFailed =>
      'Something went wrong. Please try again.';

  @override
  String get adminWalletAdjustAmountLabel => 'Amount';

  @override
  String get adminWalletAdjustAmountHint => 'Enter adjustment amount';

  @override
  String get adminWalletAdjustAmountRequired => 'Amount is required';

  @override
  String get adminWalletAdjustAmountInvalid => 'Invalid amount';

  @override
  String get adminWalletAdjustAmountMustBePositive =>
      'Amount must be greater than 0';

  @override
  String get adminWalletAdjustNoteLabel => 'Note';

  @override
  String get adminWalletAdjustReasonHint => 'Reason for adjustment';

  @override
  String get adminWalletAdjustDepositTab => 'Deposit';

  @override
  String get adminWalletAdjustWithdrawTab => 'Withdraw';

  @override
  String get adminWalletAdjustProcessing => 'Processing...';

  @override
  String get adminWalletAdjustDepositBalance => 'Deposit to balance';

  @override
  String get adminWalletAdjustWithdrawBalance => 'Withdraw from balance';

  @override
  String get adminWalletHistoryUserIdLabel => 'User ID';

  @override
  String get adminWalletSearchUserIdHint => 'Search by User ID';

  @override
  String get adminWalletSearchButton => 'Search';

  @override
  String get adminWalletSearchByUserList => 'Search by user list';

  @override
  String get adminWalletNoAdjustmentHistory => 'No adjustment history';

  @override
  String get adminWalletTargetLabel => 'Target';

  @override
  String get adminWalletActorLabel => 'Actor';

  @override
  String get homeLogoutConfirmTitle => 'Confirm logout';

  @override
  String get homeLogoutConfirmContent => 'Are you sure you want to log out?';

  @override
  String get homeLogoutCancel => 'Cancel';

  @override
  String get homeLogoutConfirm => 'Logout';

  @override
  String get homeFailedToLoadUser => 'Failed to load user information';

  @override
  String get homeGoToLogin => 'Go to login';

  @override
  String get homeAppTitle => 'Home';

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String get homeCryptoPlatform => 'Crypto trading platform';

  @override
  String get homeAuthReady => 'Authentication ready';

  @override
  String get homeLastUpdated => 'Last updated';

  @override
  String get wcLoginTitleWeb => 'Login with wallet (Web)';

  @override
  String get wcLoginTitleNative => 'WalletConnect login';

  @override
  String get wcReownDesktopUnsupportedBody =>
      'Pick a network, tap “Create QR code”, scan with your phone wallet, then sign when asked.';

  @override
  String get wcReownMissingProjectId =>
      'Missing WALLETCONNECT_PROJECT_ID (or REOWN_PROJECT_ID) in .env';

  @override
  String wcReownInitFailed(String error) {
    return 'Could not initialize Reown: $error';
  }

  @override
  String get wcReownSessionNoEvmAddress =>
      'Session has no EVM address (eip155). Choose an EVM wallet (e.g. BSC Chapel or Ethereum mainnet).';

  @override
  String get wcReownNoSignature => 'Wallet did not return a signature.';

  @override
  String wcReownLoginError(String error) {
    return 'Wallet login error: $error';
  }

  @override
  String get wcReownQrDescription =>
      'Open QR, connect your phone wallet, then sign the login message.';

  @override
  String get wcReownOpenQrButton => 'Open WalletConnect QR (Reown)';

  @override
  String get wcAdvancedLegacyQrTitle => 'Other: Server QR code';

  @override
  String get wcAdvancedLegacyQrSubtitle =>
      'If you prefer not to use Reown above';

  @override
  String get wcManualFlowIntroWeb =>
      'Create a QR, scan with your wallet, sign the message, then finish on the web app.';

  @override
  String get wcManualFlowIntroNative =>
      'Create a QR and scan with your phone; the app completes login when the server receives the signature.';

  @override
  String get wcNetworkLabel => 'Network';

  @override
  String get wcCreateQr => 'Create QR code';

  @override
  String get wcCreateQrNew => 'Create new QR code';

  @override
  String get wcRelayDisabledBanner =>
      'WalletConnect relay is off on the server (missing project id). This QR is not scannable — set WALLETCONNECT_PROJECT_ID on the API, restart, create a new QR. Or sign the message and paste address + signature below.';

  @override
  String get wcQrFooterLoginShort =>
      'Scan with your phone wallet and sign the message below.';

  @override
  String get wcMessageToSign => 'Message to sign';

  @override
  String get wcCopyMessage => 'Copy message';

  @override
  String get wcMessageCopied => 'Message copied';

  @override
  String get wcCompletingLogin => 'Completing sign-in…';

  @override
  String get wcSignedWalletAddress => 'Wallet address used to sign';

  @override
  String get wcSignatureField => 'Signature';

  @override
  String get wcVerifyAndLogin => 'Verify & sign in';

  @override
  String get wcWebRecommendExtension =>
      'Tron: use TronLink on Chrome. EVM: open the QR section below.';

  @override
  String get wcWebAdvancedWcTitle => 'WalletConnect QR / paste signature';

  @override
  String get wcWebAdvancedWcSubtitle =>
      'Desktop, mobile wallet, or no extension';

  @override
  String get wcWebTronLinkExtension => 'TronLink (Chrome)';

  @override
  String get wcEnterAddressAndSignature =>
      'Enter wallet address and signature.';

  @override
  String get wcSessionExpiredCreateNew =>
      'Session expired. Create a new QR code.';

  @override
  String get desktopTronlinkDialogTitle => 'TronLink';

  @override
  String get desktopTronlinkDialogBody =>
      'TronLink works in Chrome (web) only. On this app: sign in with email or open the web version.';

  @override
  String get desktopTronlinkDialogOk => 'OK';

  @override
  String get wcLinkDialogTitle => 'Link digital wallet';

  @override
  String get wcLinkDialogSubtitle =>
      'Connect via WalletConnect • High security';

  @override
  String get wcQrScanHintEvm =>
      'Open Trust Wallet or MetaMask Mobile → Scan QR';

  @override
  String get wcQrScanHintSolana =>
      'Solana: open Phantom or Solflare Mobile → Scan QR (MetaMask is mainly for Ethereum; WalletConnect on Solana needs a Solana-capable wallet).';

  @override
  String get wcQrCopyUri => 'Copy URI';

  @override
  String get wcQrUriCopied => 'WalletConnect URI copied';

  @override
  String get wcQrWalletLinkedCard => 'Wallet linked successfully!';

  @override
  String get wcSessionExpiredFiveMin => 'Session expired (5 minutes)';

  @override
  String get wcQrCreateNew => 'Create new QR';

  @override
  String get wcStatusIdle => 'Awaiting…';

  @override
  String get wcStatusPending => 'Waiting for QR scan';

  @override
  String get wcStatusConnected => 'Wallet connected, waiting for signature…';

  @override
  String get wcStatusSigned => 'Signed successfully!';

  @override
  String get wcStatusExpired => 'Session expired';

  @override
  String get wcStatusFailed => 'Something went wrong';

  @override
  String get wcLinkChooseBlockchain => 'Choose blockchain';

  @override
  String get wcTooltipTronlinkChrome => 'Use TronLink extension (Chrome)';

  @override
  String get wcTooltipWalletConnect => 'WalletConnect';

  @override
  String get wcTronChromeExtensionWebOnly =>
      'TronLink is handled via Chrome extension — only available on web.';

  @override
  String get wcTronChromeOnlyLong =>
      'Tron is only supported via TronLink extension on Chrome. Please open the site in Chrome to link your Tron wallet.';

  @override
  String get wcCreateQrButton => 'Generate connection QR';

  @override
  String get wcCancelReselect => 'Cancel and choose again';

  @override
  String get wcPrivateKeyStaysInWallet =>
      'Your private key never leaves your wallet.';

  @override
  String get wcCreatingSession => 'Creating connection…';

  @override
  String get wcSessionCreateFailed =>
      'Could not create WalletConnect session. Try again.';

  @override
  String get wcSessionExpiredNewQr =>
      'Session expired. Please create a new QR code.';

  @override
  String get wcSessionWcFailedRetry =>
      'WalletConnect failed (connection or signing). Create a new QR code or try again.';

  @override
  String get wcWcSupportsEvmSolanaTron =>
      'WalletConnect supports BSC Chapel, Ethereum mainnet, Solana Devnet, and Tron on desktop/mobile (QR scan). On web, link Tron with the TronLink extension.';

  @override
  String get wcSignWithTronlinkExtension => 'Sign with TronLink extension';

  @override
  String get wcTronlinkSignFailed => 'TronLink signing failed.';

  @override
  String get wcTronlinkSignMessage => 'TronLink link wallet';

  @override
  String get tronLinkAddressLabel => 'TronLink address';

  @override
  String get tronLinkGetChallenge => 'Get challenge';

  @override
  String get tronLinkChallengeTitle => 'Challenge message (sign in TronLink)';

  @override
  String get tronLinkChallengeHint =>
      'Open TronLink, go to Sign / Messages, paste the challenge text, sign, then paste the signature below.';

  @override
  String get tronLinkSignatureLabel => 'Signature (paste)';

  @override
  String get tronLinkVerify => 'Verify and link';

  @override
  String get tronLinkExtensionAutoSign => 'Auto-sign with TronLink extension';

  @override
  String get tronLinkNativePlatformHint =>
      'Tap create QR code, then scan it with TronLink on your phone to sign and complete linking.';

  @override
  String get tronLinkAddressRequired =>
      'Please enter your Tron wallet address.';

  @override
  String get tronLinkSignatureRequired =>
      'Please paste the signature from TronLink.';

  @override
  String get wcOpenWalletOnPhone => 'Open with wallet on phone';

  @override
  String wcWalletNotInstalled(String name) {
    return '$name is not installed';
  }

  @override
  String wcDownloadFromStore(String store) {
    return 'Download from $store';
  }

  @override
  String wcOpenWalletNamed(String name) {
    return 'Open $name';
  }

  @override
  String get wcStoreGooglePlay => 'Google Play';

  @override
  String get wcStoreAppStore => 'App Store';

  @override
  String get wcLinkedWalletAddedToList =>
      'The wallet has been added to your linked list.';

  @override
  String get onchainOperatorSandboxBanner =>
      'On-chain deployment is in Sandbox mode. Use test networks only — not real mainnet funds.';

  @override
  String get onchainSandboxShort => 'Sandbox';

  @override
  String get onchainTxStatusPending => 'Pending';

  @override
  String get onchainTxStatusConfirming => 'Confirming';

  @override
  String get onchainTxStatusCompleted => 'Completed';

  @override
  String get onchainTxStatusFailed => 'Failed';

  @override
  String get onchainTxStatusTxBroadcast => 'Broadcast';

  @override
  String get onchainTxStatusUnmatched => 'Unmatched';

  @override
  String get onchainTxStatusUnknown => 'Unknown';

  @override
  String get treasuryE2eTabTitle => 'Treasury E2E';

  @override
  String get treasuryE2eAddAction => 'Add Treasury E2E';

  @override
  String get treasuryE2eEditAction => 'Edit';

  @override
  String get treasuryE2eActivateAction => 'Activate';

  @override
  String get treasuryE2eDeactivateAction => 'Deactivate';

  @override
  String get treasuryE2eArchiveAction => 'Archive';

  @override
  String get treasuryE2eEmptyState => 'No treasury E2E configs yet.';

  @override
  String get treasuryE2eCreateTitle => 'Create Treasury E2E Config';

  @override
  String get treasuryE2eEditTitle => 'Edit Treasury E2E Config';

  @override
  String get treasuryE2eEnvironmentLabel => 'Environment';

  @override
  String get treasuryE2eDisplayNameLabel => 'Display name';

  @override
  String get treasuryE2eApiBaseUrlLabel => 'API base URL';

  @override
  String get treasuryE2eChainLabel => 'Chain';

  @override
  String get treasuryE2eLinkedWalletLabel => 'Linked wallet';

  @override
  String get treasuryE2eLinkedWalletHelper =>
      'Only verified wallets on the selected chain are shown.';

  @override
  String get treasuryE2eLinkedWalletEmpty => 'No linked wallet selected';

  @override
  String get treasuryE2eWithdrawAutoLabel => 'Withdraw auto amount';

  @override
  String get treasuryE2eWithdrawManualLabel => 'Withdraw manual amount';

  @override
  String get treasuryE2eDepositTxHashLabel => 'Deposit tx hash (optional)';

  @override
  String get treasuryE2eDepositAmountLabel => 'Deposit amount (optional)';

  @override
  String get treasuryE2eAllowSkipLabel => 'Allow skip when config incomplete';

  @override
  String get treasuryE2eFailOnCriticalLabel => 'Fail health on critical alerts';

  @override
  String get treasuryE2eStaleManualLabel => 'Stale manual minutes';

  @override
  String get treasuryE2eStaleConfirmingLabel => 'Stale confirming minutes';

  @override
  String get treasuryE2eFailed24hLabel => 'Failed withdrawals /24h';

  @override
  String get treasuryE2eReconcileLimitLabel => 'Reconcile pair limit';

  @override
  String get treasuryE2eReconciliationThresholdLabel =>
      'Reconciliation threshold';

  @override
  String get treasuryE2eTraderTokenLabel =>
      'Replace trader bearer token (optional)';

  @override
  String get treasuryE2eRiskTokenLabel =>
      'Replace risk bearer token (optional)';

  @override
  String get treasuryE2eValidateAction => 'Validate config';

  @override
  String get treasuryE2eValidationPassed => 'Validation passed.';

  @override
  String get treasuryE2eSaving => 'Saving...';

  @override
  String get treasuryE2eActivateDialogTitle => 'Activate Treasury E2E config';

  @override
  String get treasuryE2eDeactivateDialogTitle =>
      'Deactivate Treasury E2E config';

  @override
  String get treasuryE2eArchiveDialogTitle => 'Archive Treasury E2E config';

  @override
  String treasuryE2eListSummary(
      String allowSkip, String strictHealth, String wallet) {
    return 'allowSkip=$allowSkip • strictHealth=$strictHealth • wallet=$wallet';
  }

  @override
  String treasuryE2eListTokens(String trader, String risk) {
    return 'Trader: $trader • Risk: $risk';
  }

  @override
  String treasuryE2eCurrentTraderToken(String masked) {
    return 'Current trader token: $masked';
  }

  @override
  String treasuryE2eCurrentRiskToken(String masked) {
    return 'Current risk token: $masked';
  }

  @override
  String treasuryE2eActivateDialogContent(String name, String environment) {
    return 'Activate $name for $environment?';
  }

  @override
  String treasuryE2eDeactivateDialogContent(String name) {
    return 'Deactivate $name?';
  }

  @override
  String treasuryE2eArchiveDialogContent(String name) {
    return 'Archive $name?';
  }

  @override
  String get treasuryE2eTraderSearchLabel => 'Search trader test account';

  @override
  String get treasuryE2eLoadTraderAction => 'Load traders / wallets';

  @override
  String get treasuryE2eTraderSelectLabel => 'Trader test account';

  @override
  String get treasuryE2eTraderEmpty => 'All traders';

  @override
  String get treasuryE2eTestConnectionAction => 'Test API / Test tokens';

  @override
  String get treasuryE2eTestConnectionPassed => 'Connection test passed.';

  @override
  String get treasuryE2eTestConnectionFailed => 'Connection test failed.';

  @override
  String get treasuryE2eIdentityPreferredHint =>
      'Preferred: select test identities so the backend mints short-lived tokens automatically.';

  @override
  String get treasuryE2eRiskActorLabel => 'Risk reviewer identity';

  @override
  String get treasuryE2eRiskActorEmpty => 'No risk identity selected';

  @override
  String get treasuryE2eLegacyTokenSection => 'Legacy token fallback';

  @override
  String get treasuryE2eGuideTitle => 'Treasury E2E Configuration Guide';

  @override
  String get treasuryE2eGuideWhatIs =>
      'Treasury E2E is a configuration used to run automated end-to-end tests on the Treasury system. It connects a test trader account, linked wallet, and chain so the system can automatically verify deposit/withdrawal flows.';

  @override
  String get treasuryE2eGuideStep1Title => 'Step 1: Select Environment & Chain';

  @override
  String get treasuryE2eGuideStep1Desc =>
      'Development: local testing; Staging: staging server; Test: integration test; Production: real system (use with caution). Chain must match the linked wallet.';

  @override
  String get treasuryE2eGuideStep2Title => 'Step 2: Test Trader Account';

  @override
  String get treasuryE2eGuideStep2Desc =>
      'Search and select a test trader account. The system will use this account to execute E2E transactions.';

  @override
  String get treasuryE2eGuideStep3Title => 'Step 3: Withdrawal Configuration';

  @override
  String get treasuryE2eGuideStep3Desc =>
      'Set auto and manual amounts for the system to test. Auto amount for small automated transactions; manual amount for transactions requiring approval.';

  @override
  String get treasuryE2eGuideNote =>
      'Bearer tokens are encrypted and not displayed. Only admins can view/update them.';

  @override
  String get treasuryE2eSectionBasic => 'Basic Information';

  @override
  String get treasuryE2eSectionTrader => 'Test Trader Account';

  @override
  String get treasuryE2eSectionWithdrawal => 'Withdrawal Configuration';

  @override
  String get treasuryE2eSectionOptions => 'Options';

  @override
  String get treasuryE2eChainTooltip =>
      'Select the blockchain network for E2E testing. Must match the verified linked wallet.';

  @override
  String get treasuryE2eEnvironmentTooltip =>
      'E2E environment: development (local), staging, test (integration), production (use with caution).';

  @override
  String get treasuryE2eApiBaseUrlTooltip =>
      'Base URL of the E2E service to test. Usually http://localhost:3000 for local development.';

  @override
  String get treasuryE2eLinkedWalletTooltip =>
      'Verified wallet on the selected chain. Used by the system to execute and verify transactions.';

  @override
  String get treasuryE2eNoChainList =>
      'Failed to load chain list from API. Please check server connection and retry.';

  @override
  String get depositWatcherTitle => 'Deposit Watcher Cursors';

  @override
  String get depositWatcherNoCursorsFound => 'No Cursors Found';

  @override
  String get depositWatcherNoCursorsDesc =>
      'Cursors are created when deposits are processed.\nCurrently, no users have wallets on monitored chains,\nso no deposit scanning cursors have been initialized.';

  @override
  String get depositWatcherHowItWorks => 'How it works:';

  @override
  String get depositWatcherStep1 => '1. User creates a wallet on a blockchain';

  @override
  String get depositWatcherStep2 => '2. User deposits crypto to that wallet';

  @override
  String get depositWatcherStep3 =>
      '3. Deposit watcher scans and finds the deposit';

  @override
  String get depositWatcherStep4 =>
      '4. Cursor is saved after successful processing';

  @override
  String depositWatcherCursorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cursors',
      one: '1 cursor',
    );
    return '$_temp0';
  }

  @override
  String get depositWatcherResetAll => 'Reset All Cursors';

  @override
  String get depositWatcherResetAllConfirm =>
      'Reset all deposit watcher cursors? This will rescan everything from 7 days ago.';

  @override
  String get depositWatcherResetAllSuccess => 'All cursors reset successfully';

  @override
  String get depositWatcherResetAllFailed => 'Failed to reset cursors';

  @override
  String depositWatcherResetSuccess(String chain) {
    return 'Cursor for $chain has been reset';
  }

  @override
  String get drawerDepositWatcher => 'Deposit Watcher';

  @override
  String get drawerDepositWatcherSubtitle =>
      'Reset cursors for blockchain deposit scanning';

  @override
  String get notificationSoundSettings => 'Sound Settings';

  @override
  String get notificationSoundPerType => 'Sound per notification type';

  @override
  String get notificationSoundSystemDefault => 'System Default';

  @override
  String get notificationSoundWithdrawalRequest => 'Withdrawal Request';

  @override
  String get notificationSoundWithdrawalApproved => 'Withdrawal Approved';

  @override
  String get notificationSoundWithdrawalRejected => 'Withdrawal Rejected';

  @override
  String get notificationSoundAlert => 'Alert';

  @override
  String get notificationSoundPromo => 'Promo';

  @override
  String get notificationsTypeWithdrawalRequest => 'Withdrawal Request';

  @override
  String get notificationsTypeWithdrawalApproved => 'Withdrawal Approved';

  @override
  String get notificationsTypeWithdrawalRejected => 'Withdrawal Rejected';

  @override
  String notifWithdrawalRequest(String amount, String symbol, String chain) {
    return 'User requested withdrawal of $amount $symbol on $chain';
  }

  @override
  String notifWithdrawalApproved(String amount, String symbol, String chain) {
    return 'Your withdrawal of $amount $symbol on $chain has been approved and is being processed.';
  }

  @override
  String notifWithdrawalRejected(
      String amount, String symbol, String chain, String reason) {
    String _temp0 = intl.Intl.selectLogic(
      reason,
      {
        'undefined': '',
        'other': ' Reason: $reason',
      },
    );
    return 'Your withdrawal of $amount $symbol on $chain has been rejected.$_temp0';
  }

  @override
  String get walletFilterAll => 'All';

  @override
  String get walletFilterDeposit => 'Deposit';

  @override
  String get walletFilterWithdraw => 'Withdraw';

  @override
  String get walletFilterTrade => 'Trade';

  @override
  String get walletFilterOrder => 'Order';

  @override
  String get walletFilterTransfer => 'Transfer';

  @override
  String get walletFilterAdjust => 'Adjust';

  @override
  String get walletFilterOnchain => 'On-chain';

  @override
  String get walletFilterExternal => 'On-chain';

  @override
  String get walletTxRefId => 'Reference';

  @override
  String get walletTxDate => 'Date';

  @override
  String get walletTxType => 'Type';

  @override
  String get walletTxAmount => 'Amount';

  @override
  String get walletRecentTransactions => 'Recent Transactions';

  @override
  String get walletLoadMore => 'Load more';

  @override
  String get walletNoTransactionsMatch =>
      'No transactions match the selected filter';

  @override
  String get testAccount => 'Test Account';

  @override
  String get testAccountDev => 'Test Account (Dev)';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get selectAccount => 'Select account';

  @override
  String get youCanEditCredentialsAbove =>
      'You can edit email or password here for testing';

  @override
  String get ordersGuestGateTitle => 'Sign in to view your orders';

  @override
  String get ordersGuestGateSubtitle =>
      'The Orders tab is available after signing in. Sign in to view your order book, place buy/sell orders, and manage your portfolio.';

  @override
  String get ordersSessionExpiredTitle => 'Your session has expired';

  @override
  String get ordersSessionExpiredSubtitle =>
      'Please sign in again to continue viewing your orders.';

  @override
  String get signInAgain => 'Sign in again';

  @override
  String get apiErrorEmailExists => 'This email is already in use.';

  @override
  String get apiErrorInvalidOtp => 'The OTP code is invalid or has expired.';

  @override
  String get apiErrorOtpRequired => 'OTP code is required.';

  @override
  String apiErrorOtpCooldown(int seconds) {
    return 'Please wait $seconds seconds before requesting another OTP.';
  }

  @override
  String apiErrorOtpAttemptLimitExceeded(int seconds) {
    return 'Too many OTP attempts. Please try again in $seconds seconds.';
  }

  @override
  String get apiErrorTwoFaRequired =>
      'Two-factor authentication is required. Please enable 2FA in Settings first.';

  @override
  String get apiErrorAccountBanned =>
      'Your account has been banned. Contact support.';

  @override
  String get apiErrorEmailVerificationDisabled =>
      'Email verification is disabled by admin. OTP is not required.';

  @override
  String get apiErrorNotWalletPlaceholder =>
      'Only wallet-placeholder accounts can use this flow. Use the regular email-change endpoint in Settings.';

  @override
  String get apiErrorUseContactEmailVerification =>
      'Wallet accounts use a temporary email. Please verify a real email in Profile.';

  @override
  String get apiErrorUseChangePasswordEndpoint =>
      'Please use the dedicated change-password endpoint.';

  @override
  String get apiErrorInvalidPayload => 'Request payload is invalid.';

  @override
  String get apiErrorInvalidChangeType => 'Unsupported change type.';

  @override
  String get apiErrorAvatarUploadDisabled =>
      'Avatar upload is currently disabled.';

  @override
  String get apiErrorContactEmailRequired => 'A contact email is required.';

  @override
  String get apiErrorInvalidAvatarFormat =>
      'Only JPEG, PNG, or WebP images are allowed.';

  @override
  String get apiErrorAvatarRequired => 'Avatar file is required.';

  @override
  String get apiErrorWithdrawalProcessing => 'A withdrawal is being processed.';

  @override
  String get apiErrorWithdrawalDuplicate => 'Duplicate withdrawal request.';

  @override
  String get apiErrorWithdrawalNotFound => 'Withdrawal not found.';

  @override
  String apiErrorWithdrawalPendingExists(int count) {
    return 'Cannot change email while $count withdrawal(s) are pending. Please wait or cancel them first.';
  }

  @override
  String get apiErrorPendingWithdrawals =>
      'Cannot perform this action while a withdrawal is pending.';

  @override
  String get apiErrorUserNotFound => 'User not found.';

  @override
  String get apiErrorWalletNotFound => 'Wallet not found.';

  @override
  String get apiErrorInvalidAmount => 'Invalid amount.';

  @override
  String get apiErrorInvalidTarget => 'Cannot transfer to the same user.';

  @override
  String get apiErrorTargetRequired =>
      'targetUserId is required for transfers.';

  @override
  String get apiErrorInvalidAction => 'Invalid wallet action.';

  @override
  String get apiErrorInsufficientBalance => 'Insufficient balance.';

  @override
  String get apiErrorAccountFrozen => 'Account is frozen.';

  @override
  String get apiErrorChainRequired => 'Missing query param: chain.';

  @override
  String get apiErrorTxHashRequired => 'Missing query param: txHash.';

  @override
  String get apiErrorAdminIngestMissingParams =>
      'chain and txHash are required.';

  @override
  String apiErrorInvalidAddress(String chain) {
    return 'Invalid wallet address on chain $chain.';
  }

  @override
  String get apiErrorInvalidTronAddress => 'Invalid Tron destination address.';

  @override
  String get apiErrorInvalidEvmAddress => 'Invalid EVM destination address.';

  @override
  String get apiErrorInvalidSignature => 'Signature is invalid.';

  @override
  String get apiErrorWalletAlreadyLinked =>
      'This wallet is already linked to your account.';

  @override
  String get apiErrorWalletInactive =>
      'Inactive wallet cannot be set as default.';

  @override
  String get apiErrorLinkNotFound => 'Linked wallet not found.';

  @override
  String get apiErrorWcAuthSessionExpired =>
      'WalletConnect session expired. Please try again.';

  @override
  String get apiErrorWcAuthInvalidPayload => 'Invalid WalletConnect payload.';

  @override
  String get apiErrorTreasuryChainUnsupported => 'Unsupported treasury chain.';

  @override
  String get apiErrorTreasuryChainNotEvm =>
      'Operation requires an EVM-compatible chain.';

  @override
  String get apiErrorTreasuryInvalidAmount =>
      'Amount must be greater than zero.';

  @override
  String get apiErrorTreasurySweepUsdtZero => 'No USDT balance to sweep.';

  @override
  String get apiErrorTreasuryUsdtChain => 'USDT sweep requires a Tron chain.';

  @override
  String get apiErrorTreasuryConfirmNoWallet =>
      'Missing to_wallet_id for confirm operation.';

  @override
  String get apiErrorTreasuryManualSettleTxEmpty =>
      'Transaction hash is required.';

  @override
  String get apiErrorTreasuryOperationNotFound =>
      'Treasury operation not found.';

  @override
  String get apiErrorTreasuryOperationStateInvalid =>
      'Operation is in an invalid state for this action.';

  @override
  String get apiErrorTreasuryOperationNotQueued =>
      'Operation is not in the queued state.';

  @override
  String get apiErrorTreasuryOperationNotProcessing =>
      'Operation is not being processed.';

  @override
  String get apiErrorTreasuryOperationNotConfirming =>
      'Operation is not confirming on-chain.';

  @override
  String get apiErrorTreasuryOperationNotCompleted =>
      'Operation has not completed yet.';

  @override
  String get apiErrorTreasuryOperationNotFailed => 'Operation has not failed.';

  @override
  String get apiErrorTreasuryTxHashNotFound =>
      'Transaction hash not found in our records.';

  @override
  String get apiErrorTreasuryInsufficientFunds =>
      'Insufficient on-chain balance for this operation.';

  @override
  String get apiErrorTreasuryBalanceReconcileFailed =>
      'Failed to reconcile treasury balance.';

  @override
  String get apiErrorTreasuryOperationTypeUnsupported =>
      'Unsupported treasury operation type.';

  @override
  String get apiErrorTreasuryRpcUnavailable =>
      'Blockchain RPC is unavailable. Please try again later.';

  @override
  String get apiErrorTreasuryRpcTimeout =>
      'Blockchain RPC timed out. Please try again later.';

  @override
  String get apiErrorTreasuryGasEstimateFailed =>
      'Could not estimate gas for the transaction.';

  @override
  String get apiErrorTreasuryNonceConflict =>
      'Nonce conflict. Another transaction is in flight for this wallet.';

  @override
  String get apiErrorTreasuryTxReverted => 'On-chain transaction reverted.';

  @override
  String get apiErrorTreasuryTxBroadcastFailed =>
      'Failed to broadcast transaction to the network.';

  @override
  String get apiErrorTxWalletNotFound => 'Transaction wallet not found.';

  @override
  String get apiErrorTxWalletDefaultDepositDeleteForbidden =>
      'Unset this wallet as the user deposit default before deleting it.';

  @override
  String get apiErrorDefaultUserDepositDeactivateForbidden =>
      'You cannot deactivate the current default user deposit wallet.';

  @override
  String get apiErrorTreasuryMainWalletNotFound =>
      'Treasury main wallet not found.';

  @override
  String get apiErrorTreasuryMainWalletConflict =>
      'A treasury main wallet with this configuration already exists.';

  @override
  String get apiErrorOrderNotFound => 'Order not found.';

  @override
  String get apiErrorOrderNotOpen => 'Order is not open.';

  @override
  String get apiErrorInvalidPrice => 'Invalid price.';

  @override
  String get apiErrorInvalidInput => 'Invalid order input.';

  @override
  String get apiErrorInvalidMarketBuyReserve => 'Invalid market buy reserve.';

  @override
  String get apiErrorNoLiquidity => 'Not enough liquidity for this order.';

  @override
  String get apiErrorOrderCreateFailed => 'Could not create order.';

  @override
  String get apiErrorInvalidState => 'Order is in an invalid state.';

  @override
  String get apiErrorOverfillAttempt => 'Order would be overfilled.';

  @override
  String get apiErrorCancelFailed => 'Cancel failed.';

  @override
  String get apiErrorPairNotFound => 'Trading pair not found.';

  @override
  String get apiErrorInvalidOrderType => 'Invalid order type.';

  @override
  String get apiErrorOrderBookServiceUnavailable =>
      'Order book service is not available.';

  @override
  String get apiErrorInvalidDepthLimit => 'Depth limit must be 5, 10, or 20.';

  @override
  String get apiErrorInvalidInterval => 'Invalid interval.';

  @override
  String get apiErrorMarketPairSymbolExists =>
      'A market pair with this symbol already exists.';

  @override
  String get apiErrorBaseQuoteSame =>
      'Base and quote currencies cannot be the same.';

  @override
  String get apiErrorBaseQuoteRequired =>
      'Base and quote currencies are required.';

  @override
  String get apiErrorCurrencyNotFound => 'Currency not found.';

  @override
  String get apiErrorCurrencySymbolExists =>
      'A currency with this symbol already exists.';

  @override
  String get apiErrorCurrencyDisabled => 'Currency is disabled.';

  @override
  String get apiErrorMarketMakerConfigNotFound =>
      'Market maker config not found.';

  @override
  String get apiErrorMarketMakerConfigConflict =>
      'A market maker config for this user and pair already exists.';

  @override
  String get apiErrorMarketMakerInvalidSpread => 'Invalid market maker spread.';

  @override
  String get apiErrorMarketMakerInvalidAmount =>
      'Invalid market maker order amount.';

  @override
  String get apiErrorMarketMakerNoActivePairs =>
      'No active trading pairs configured for market making.';

  @override
  String get apiErrorMarketMakerPlaceFailed =>
      'Market maker could not place orders.';

  @override
  String get apiErrorConfigKeyNotFound => 'Configuration key not found.';

  @override
  String get apiErrorConfigKeyDisallowed =>
      'This configuration key is not allowed.';

  @override
  String get apiErrorConfigKeyReadOnly =>
      'This configuration key is read-only.';

  @override
  String get apiErrorConfigValueInvalid =>
      'Invalid value for configuration key.';

  @override
  String get apiErrorAdminRequired => 'Admin role required.';

  @override
  String get apiErrorRiskOfficerRequired => 'Risk officer role required.';

  @override
  String get apiErrorFinanceManagerRequired => 'Finance manager role required.';

  @override
  String get apiErrorDepositNotFound => 'Deposit not found.';

  @override
  String get apiErrorDepositAlreadyPaid => 'Deposit already paid or not found.';

  @override
  String get apiErrorDepositAmountInvalid => 'Invalid deposit amount.';

  @override
  String get apiErrorDepositChainUnsupported => 'Unsupported deposit chain.';

  @override
  String get apiErrorDepositPollFailed =>
      'Could not check deposit status. Please try again later.';

  @override
  String get apiErrorTxFailed => 'On-chain transaction failed.';

  @override
  String get apiErrorEncryptionFailed => 'Encryption failed.';

  @override
  String get apiErrorDecryptionFailed => 'Decryption failed.';

  @override
  String get apiErrorEncryptedPayloadMalformed =>
      'Encrypted payload is malformed.';

  @override
  String get apiErrorDecryptedPayloadInvalid => 'Decrypted payload is invalid.';

  @override
  String get apiErrorExternalProviderUnavailable =>
      'External provider is unavailable.';

  @override
  String get apiErrorExternalProviderRateLimited =>
      'External provider rate limit reached. Please try again later.';

  @override
  String get apiErrorNotificationDeliveryFailed =>
      'Notification delivery failed.';

  @override
  String get apiErrorFcmNotConfigured =>
      'Push notifications are not configured.';

  @override
  String get apiErrorTronSendFailed => 'Failed to submit Tron transaction.';

  @override
  String get adminTransactionSectionOrderInfo => 'Order information';

  @override
  String get adminTransactionSectionPriceAndAmount => 'Price & quantity';

  @override
  String get adminTransactionSectionTime => 'Time';

  @override
  String get adminTransactionSectionReference => 'Reference';

  @override
  String get adminTransactionLabelClientOrderId => 'Client Order ID';

  @override
  String get adminTransactionSectionUser => 'User';

  @override
  String get adminTransactionSectionDepositInfo => 'Deposit information';

  @override
  String get adminTransactionLabelDepositId => 'Deposit ID';

  @override
  String get adminTransactionSectionWithdrawalInfo => 'Transaction information';

  @override
  String get adminTransactionLabelWithdrawalId => 'Withdrawal ID';

  @override
  String get adminTransactionSectionOnChain => 'On-Chain';

  @override
  String adminTransactionLoadUserFailed(String error) {
    return 'Cannot load user info: $error';
  }

  @override
  String get adminUserDetailDepositAction => 'Deposit';

  @override
  String get adminUserDetailWithdrawAction => 'Withdraw';

  @override
  String get adminUserDetailAdjustDepositTitle => 'Deposit coin for user';

  @override
  String get adminUserDetailAdjustWithdrawTitle => 'Withdraw coin from user';

  @override
  String get adminUserDetailAdjustDepositSegment => 'Deposit coin';

  @override
  String get adminUserDetailAdjustWithdrawSegment => 'Withdraw coin';

  @override
  String get adminUserDetailAdjustAmountLabel => 'Amount';

  @override
  String get adminUserDetailAdjustAmountHint => '0.00';

  @override
  String get adminUserDetailAdjustAmountRequired => 'Please enter the amount';

  @override
  String get adminUserDetailAdjustAmountInvalid => 'Invalid amount';

  @override
  String get adminUserDetailAdjustAmountPositive =>
      'Amount must be greater than 0';

  @override
  String get adminUserDetailAdjustNoteLabel => 'Note (optional)';

  @override
  String get adminUserDetailAdjustNoteHint => 'Reason for adjustment...';

  @override
  String get adminUserDetailAdjustProcessing => 'Processing...';

  @override
  String get adminUserDetailPickCoinType => 'Select coin type';

  @override
  String adminUserDetailBalanceAvailableLabel(String amount, String symbol) {
    return 'Available balance: $amount $symbol';
  }

  @override
  String get adminUserDetailNoWalletWillCreate =>
      'User has no wallet — will be auto-created';

  @override
  String adminUserDetailNoWalletForSymbol(String symbol) {
    return 'User has no $symbol wallet';
  }

  @override
  String get adminUserDetailSectionExistingWallets => 'EXISTING WALLETS';

  @override
  String get adminUserDetailSectionNewWallets => 'CREATE NEW WALLET';

  @override
  String get adminUserDetailNoWalletBadge => 'No wallet yet';

  @override
  String get adminUserDetailPermissionDeniedWallets =>
      'You do not have permission to view this user\'s wallet balances';

  @override
  String get adminUserDetailPermissionDeniedAdjustments =>
      'You do not have permission to view adjustment history';

  @override
  String get adminUserDetailPermissionDeniedSecurity =>
      'You do not have permission to view security change history';

  @override
  String get adminUserDetailEmptyWallets => 'User has no wallets yet';

  @override
  String get adminUserDetailEmptyAdjustments => 'No adjustment history yet';

  @override
  String get adminUserDetailEmptyOrders => 'User has no orders yet';

  @override
  String get adminUserDetailEmptyOnchainTxs => 'No on-chain transactions';

  @override
  String get adminUserDetailEmptySecurityChanges =>
      'No security change history';

  @override
  String adminUserDetailAdjustmentByActor(String actor) {
    return 'By: $actor';
  }

  @override
  String adminUserDetailAdjustmentNoteValue(String note) {
    return 'Note: $note';
  }

  @override
  String adminUserDetailOrderQuantityAndPrice(
      String amount, String price, String type) {
    String _temp0 = intl.Intl.selectLogic(
      price,
      {
        'undefined': '',
        'other': ' · Price: $price',
      },
    );
    return 'Qty: $amount$_temp0 · $type';
  }

  @override
  String adminUserDetailOrderTxHashTruncated(String hash) {
    return 'TX: $hash';
  }

  @override
  String get adminUserDetailOrderStatusFilled => 'Filled';

  @override
  String get adminUserDetailOrderStatusPartial => 'Partially filled';

  @override
  String get adminUserDetailOrderStatusOpen => 'Open';

  @override
  String get adminUserDetailOrderStatusCancelled => 'Cancelled';

  @override
  String get adminUserDetailOrderStatusRejected => 'Rejected';

  @override
  String get adminUserDetailOnchainStatusCompleted => 'Completed';

  @override
  String get adminUserDetailOnchainStatusConfirming => 'Confirming';

  @override
  String get adminUserDetailOnchainStatusPending => 'Pending';

  @override
  String get adminUserDetailOnchainStatusFailed => 'Failed';

  @override
  String get adminUserDetailSecurityStatusApproved => 'Approved';

  @override
  String get adminUserDetailSecurityStatusRejected => 'Rejected';

  @override
  String get adminUserDetailSecurityStatusPending => 'Pending review';

  @override
  String get adminUserDetailRetryAction => 'Try again';

  @override
  String get adminUserDetailDialogCancel => 'Cancel';

  @override
  String adminUserDetailWalletBalanceLine(String available, String frozen) {
    return 'Available: $available  |  Frozen: $frozen';
  }

  @override
  String adminUserDetailDepositWithdrawTooltip(String symbol) {
    return 'Deposit/Withdraw $symbol';
  }

  @override
  String get paymentConfigFieldClientId => 'Client ID';

  @override
  String get paymentConfigFieldApiKey => 'API Key';

  @override
  String get paymentConfigFieldChecksumKey => 'Checksum Key';

  @override
  String get paymentConfigFieldReturnUrl => 'Return URL';

  @override
  String get paymentConfigFieldCancelUrl => 'Cancel URL';

  @override
  String get paymentConfigFieldFiatSymbol => 'Fiat Symbol';

  @override
  String get paymentConfigFieldQuoteSymbol => 'Quote Symbol';

  @override
  String get paymentConfigFieldFxSpreadBps => 'FX Spread (bps)';

  @override
  String get paymentConfigFieldMinDepositFiat => 'Min deposit (fiat, integer)';

  @override
  String get paymentConfigFieldMaxDepositFiat => 'Max deposit (fiat, optional)';

  @override
  String get paymentConfigFieldRpcUrl => 'RPC URL';

  @override
  String get paymentConfigFieldHotWalletKey => 'Hot Wallet Private Key';

  @override
  String get paymentConfigFieldNativeSymbol => 'Native Symbol';

  @override
  String get paymentConfigFieldWithdrawAutoMax => 'Withdraw Auto Max';

  @override
  String get paymentConfigFieldFxFallbackRate =>
      'FX Fallback Rate (1 Native → X USDT)';

  @override
  String get paymentConfigFieldMainnet => 'Mainnet';

  @override
  String marketMakerValidationMustBeAtLeast(String minValue) {
    return 'Must be ≥ $minValue';
  }

  @override
  String get binanceSpotTradingTitle => 'Spot Trading';

  @override
  String get binanceSpotTradingBinanceLabel => 'Binance';

  @override
  String get binanceSpotTradingBalancesTitle => 'Balances';

  @override
  String get binanceSpotTradingNoAssetsWithBalance => 'No assets with balance';

  @override
  String binanceSpotTradingBalanceFree(String amount) {
    return '$amount free';
  }

  @override
  String get binanceSpotTradingSideBuy => 'BUY';

  @override
  String get binanceSpotTradingSideSell => 'SELL';

  @override
  String get binanceSpotTradingTypeLimit => 'LIMIT';

  @override
  String get binanceSpotTradingTypeMarket => 'MARKET';

  @override
  String binanceSpotTradingPriceLabel(String asset) {
    return 'Price ($asset)';
  }

  @override
  String binanceSpotTradingAmountLabel(String asset) {
    return 'Amount ($asset)';
  }

  @override
  String get binanceSpotTradingTotalLabel => 'Total';

  @override
  String binanceSpotTradingTotalAmount(String amount) {
    return '$amount USDT';
  }

  @override
  String binanceSpotTradingSubmitButton(String side, String asset) {
    return '$side $asset';
  }

  @override
  String get binanceSpotTradingInvalidAmount => 'Please enter a valid amount';

  @override
  String get binanceSpotTradingInvalidPrice => 'Please enter a valid price';

  @override
  String get binanceSpotTradingOrderFailed => 'Order failed';

  @override
  String get binanceSpotTradingOrderPlaced => 'Order placed successfully';

  @override
  String get binanceSpotTradingOrderCancelled => 'Order cancelled';

  @override
  String get binanceSpotTradingOpenOrdersTab => 'Open Orders';

  @override
  String get binanceSpotTradingHistoryTab => 'History';

  @override
  String get binanceSpotTradingNoOpenOrders => 'No open orders';

  @override
  String get binanceSpotTradingLoadHistory => 'Load History';

  @override
  String get binanceSpotTradingCancelOrder => 'Cancel';

  @override
  String get binanceApiKeyListTitle => 'My Binance API Keys';

  @override
  String get binanceApiKeyListEmptyTitle => 'No Binance API Keys';

  @override
  String get binanceApiKeyListEmptyDescription =>
      'Connect your Binance account to start trading';

  @override
  String get binanceApiKeyListAddAction => 'Add API Key';

  @override
  String get binanceApiKeyListTestConnection => 'Test Connection';

  @override
  String get binanceApiKeyListTrade => 'Trade';

  @override
  String get binanceApiKeyListDelete => 'Delete';

  @override
  String get binanceApiKeyListDeleteConfirmTitle => 'Delete API Key?';

  @override
  String binanceApiKeyListDeleteConfirmContent(String label) {
    return 'Are you sure you want to delete \"$label\"? This action cannot be undone.';
  }

  @override
  String get binanceApiKeyListAccountFallbackLabel => 'Binance Account';

  @override
  String get binanceApiKeyListTestnetBadge => 'TESTNET';

  @override
  String get binanceApiKeyListMainnetBadge => 'MAINNET';

  @override
  String binanceApiKeyListLastUsedAt(String date) {
    return 'Last used: $date';
  }

  @override
  String get binanceApiKeyListNeverUsed => 'Never used';

  @override
  String binanceApiKeyListConnectionOk(String info) {
    return 'Connection OK — Account: $info';
  }

  @override
  String binanceApiKeyListConnectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get binanceApiKeyListJustNow => 'Just now';

  @override
  String binanceApiKeyListMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String binanceApiKeyListHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String binanceApiKeyListDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get binanceApiKeySetupTitle => 'Connect Binance API';

  @override
  String get binanceApiKeySetupDefaultLabel => 'Main Spot Account';

  @override
  String get binanceApiKeySetupLabelField => 'Label';

  @override
  String get binanceApiKeySetupLabelHint => 'e.g. Main Spot Account';

  @override
  String get binanceApiKeySetupLabelRequired => 'Label is required';

  @override
  String get binanceApiKeySetupApiKeyField => 'API Key';

  @override
  String get binanceApiKeySetupApiKeyHint => 'Enter your Binance API Key';

  @override
  String get binanceApiKeySetupApiSecretField => 'API Secret';

  @override
  String get binanceApiKeySetupApiSecretHint => 'Enter your Binance API Secret';

  @override
  String get binanceApiKeySetupPermissionsSection => 'Permissions';

  @override
  String get binanceApiKeySetupSpotTradingTitle => 'Spot Trading';

  @override
  String get binanceApiKeySetupSpotTradingSubtitle =>
      'Enable spot market trading';

  @override
  String get binanceApiKeySetupFuturesTradingTitle => 'Futures Trading';

  @override
  String get binanceApiKeySetupFuturesTradingSubtitle =>
      'Enable USD-M futures trading';

  @override
  String get binanceApiKeySetupUseTestnetTitle => 'Use Testnet';

  @override
  String get binanceApiKeySetupUseTestnetSubtitle =>
      'Connect to Binance testnet instead of mainnet';

  @override
  String get binanceApiKeySetupGuideTitle => 'API Key Setup Guide';

  @override
  String get binanceApiKeySetupGuideIntro =>
      'When creating your API key on Binance:';

  @override
  String get binanceApiKeySetupGuideTip1 =>
      'Disable all Withdrawal permissions';

  @override
  String get binanceApiKeySetupGuideTip2 => 'Enable: Spot/Futures Trading';

  @override
  String get binanceApiKeySetupGuideTip3 => 'Enable: Read-only market data';

  @override
  String get binanceApiKeySetupGuideLink => 'View Binance API Guide';

  @override
  String get binanceApiKeySetupTestConnection => 'Test Connection';

  @override
  String get binanceApiKeySetupSaveAction => 'Save API Key';

  @override
  String get binanceApiKeySetupConnectionPassedSaved =>
      'Connection test passed! Credentials saved.';

  @override
  String get binanceApiKeySetupSavedSuccess => 'API Key saved successfully';

  @override
  String binanceApiKeySetupSavedFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get binanceApiKeySetupConnectionSuccessful => 'Connection successful!';

  @override
  String binanceApiKeySetupConnectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get walletAuthOpenTronLinkHint =>
      'Open TronLink on your phone, then return to the app.';

  @override
  String get walletAuthTronLinkUnavailable =>
      'Could not open TronLink. Install the app or use Chrome (extension).';

  @override
  String walletAuthMetaMaskOrTronLinkUnavailable(String name) {
    return '$name not detected. Install the Chrome extension and open the app in the browser.';
  }

  @override
  String walletAuthNonceFetchFailed(String error) {
    return 'Failed to fetch nonce: $error';
  }

  @override
  String walletAuthWrongMetaMaskAddress(String address) {
    return 'Wrong MetaMask address. Currently connected: $address';
  }

  @override
  String walletAuthWrongTronLinkAddress(String address) {
    return 'Wrong TronLink address. Currently connected: $address';
  }

  @override
  String walletAuthVerificationFailed(String message) {
    return 'Verification failed: $message';
  }

  @override
  String get manualTitle => 'Operator Manual';

  @override
  String get manualSubtitle => 'Step-by-step guide for every role and tab';

  @override
  String get manualIntroHeroDesc =>
      'Welcome. Browse the sections below to learn how to use every feature of the platform, from basic trading to advanced operations.';

  @override
  String get manualEmptyForRole =>
      'No manual sections are available for this role.';

  @override
  String get manualGettingStartedTitle => 'Getting Started';

  @override
  String get manualGettingStartedDesc =>
      'Set up your account in a few minutes.';

  @override
  String get manualDashboardTitle => 'Dashboard';

  @override
  String get manualDashboardDesc =>
      'Portfolio overview, top markets and my wallets.';

  @override
  String get manualMarketsTitle => 'Markets';

  @override
  String get manualMarketsDesc => 'Browse and search all trading pairs.';

  @override
  String get manualWalletsTitle => 'Wallets';

  @override
  String get manualWalletsDesc => 'View balances and transaction history.';

  @override
  String get manualOrdersTitle => 'Orders / Trading';

  @override
  String get manualOrdersDesc => 'Place orders and manage open positions.';

  @override
  String get manualAccountSettingsTitle => 'Account Settings';

  @override
  String get manualAccountSettingsDesc =>
      'Theme, language, 2FA and exchange sync.';

  @override
  String get manualUserManagementTitle => 'User Management';

  @override
  String get manualUserManagementDesc =>
      'Search users, assign roles and lock accounts.';

  @override
  String get manualSecurityRequestsTitle => 'Security Requests';

  @override
  String get manualSecurityRequestsDesc =>
      'Review OTP + admin approval workflows.';

  @override
  String get manualManagedWalletsTitle => 'Managed Wallets';

  @override
  String get manualManagedWalletsDesc =>
      'System wallets, on-chain monitoring and sweeps.';

  @override
  String get manualPaymentConfigTitle => 'Payment Configuration';

  @override
  String get manualPaymentConfigDesc =>
      'Configure PayOS, FX spreads and limits.';

  @override
  String get manualTreasuryE2ETitle => 'Treasury E2E Configuration';

  @override
  String get manualTreasuryE2EDesc => 'End-to-end settings for treasury flows.';

  @override
  String get manualMarketMakerTitle => 'Market Maker Hub';

  @override
  String get manualMarketMakerDesc =>
      'Create pairs, manage depth and sync exchange.';

  @override
  String get manualMonitoringTitle => 'Transaction Monitoring';

  @override
  String get manualMonitoringDesc =>
      'Inspect transactions, currencies and deposits.';

  @override
  String get manualSystemConfigTitle => 'System Configuration';

  @override
  String get manualSystemConfigDesc =>
      'Auth Security / Core / Finance / Ops / Tech editors.';

  @override
  String get manualBroadcastTitle => 'Broadcast Notification';

  @override
  String get manualBroadcastDesc => 'Send announcements to all active users.';

  @override
  String get manualGlossaryTitle => 'Glossary';

  @override
  String get manualGlossaryDesc => 'Common crypto and platform terms.';

  @override
  String get manualFaqTitle => 'FAQ';

  @override
  String get manualFaqDesc => 'Frequently asked questions.';

  @override
  String get manualContactTitle => 'Contact Support';

  @override
  String get manualContactDesc => 'How to reach the support team.';

  @override
  String get manualEntrySetupAccountTitle => 'Set up your account';

  @override
  String get manualEntrySetupAccountDesc =>
      'Edit your profile, upload an avatar and confirm your email.';

  @override
  String get manualEntryEnable2faTitle => 'Enable 2FA';

  @override
  String get manualEntryEnable2faDesc =>
      'Add an extra layer of security before changing email or password.';

  @override
  String get manualEntryChangeLanguageTitle => 'Change language';

  @override
  String get manualEntryChangeLanguageDesc =>
      'Switch the interface between English and Vietnamese.';

  @override
  String get manualEntryChangeThemeTitle => 'Change theme';

  @override
  String get manualEntryChangeThemeDesc =>
      'Pick light, dark or follow the system, and choose a seed color.';

  @override
  String get manualEntryDashboardOverviewTitle => 'Portfolio overview';

  @override
  String get manualEntryDashboardOverviewDesc =>
      'Read total portfolio value, top markets preview and wallet summary.';

  @override
  String get manualEntryDashboardPullRefreshTitle => 'Pull to refresh';

  @override
  String get manualEntryDashboardPullRefreshDesc =>
      'Swipe down on the dashboard to reload balances and top markets.';

  @override
  String get manualEntryMarketsSearchTitle => 'Search markets';

  @override
  String get manualEntryMarketsSearchDesc =>
      'Type a symbol (e.g. BTC) to filter the list instantly.';

  @override
  String get manualEntryMarketsFilterTitle => 'Filter by currency';

  @override
  String get manualEntryMarketsFilterDesc =>
      'Open the currency picker to show only pairs using a chosen base.';

  @override
  String get manualEntryMarketsSortTitle => 'Sort and filter (admin)';

  @override
  String get manualEntryMarketsSortDesc =>
      'Use the sort dropdown to view top volume, top gainers or A-Z.';

  @override
  String get manualEntryWalletsViewTitle => 'View balances';

  @override
  String get manualEntryWalletsViewDesc =>
      'Switch currency in the picker to see available, frozen and total.';

  @override
  String get manualEntryWalletsHistoryTitle => 'Transaction history';

  @override
  String get manualEntryWalletsHistoryDesc =>
      'Filter by type and search by ref to find a specific movement.';

  @override
  String get manualEntryOrdersPlaceTitle => 'Place an order';

  @override
  String get manualEntryOrdersPlaceDesc =>
      'Pick LIMIT, MARKET or STOP_LOSS and choose BUY or SELL.';

  @override
  String get manualEntryOrdersCancelTitle => 'Cancel an open order';

  @override
  String get manualEntryOrdersCancelDesc =>
      'Open My Orders and tap the X next to an open order to cancel it.';

  @override
  String get manualEntrySettings2faTitle => 'Enable / disable 2FA';

  @override
  String get manualEntrySettings2faDesc =>
      'Toggle 2FA in Settings; an OTP dialog will confirm the change.';

  @override
  String get manualEntrySettingsSyncTitle => 'Manual exchange sync';

  @override
  String get manualEntrySettingsSyncDesc =>
      'Trigger a manual Binance sync and read the last sync timestamp.';

  @override
  String get manualEntryAdminUsersTitle => 'Browse and filter users';

  @override
  String get manualEntryAdminUsersDesc =>
      'Search by email, filter by role and status, then open a user.';

  @override
  String get manualEntryAdminRolesTitle => 'Assign roles';

  @override
  String get manualEntryAdminRolesDesc =>
      'Update a user role from the detail panel; changes are audited.';

  @override
  String get manualEntryAdminBanTitle => 'Lock or unlock users';

  @override
  String get manualEntryAdminBanDesc =>
      'Ban/unban, set status to PENDING/ACTIVE and review 2FA flags.';

  @override
  String get manualEntrySecurityRequestsReviewTitle =>
      'Review a security request';

  @override
  String get manualEntrySecurityRequestsReviewDesc =>
      'Approve or reject OTP-protected email / password changes.';

  @override
  String get manualEntryManagedWalletsOpsTitle => 'Run wallet operations';

  @override
  String get manualEntryManagedWalletsOpsDesc =>
      'Sweep, top up and inspect on-chain balances per managed wallet.';

  @override
  String get manualEntryPaymentConfigSaveTitle => 'Edit payment config';

  @override
  String get manualEntryPaymentConfigSaveDesc =>
      'Update client id, API key, FX spread and deposit limits.';

  @override
  String get manualEntryTreasuryE2EConfigTitle => 'Edit treasury E2E settings';

  @override
  String get manualEntryTreasuryE2EConfigDesc =>
      'Configure RPC URL, hot wallet key and FX fallback rate.';

  @override
  String get manualEntryMarketMakerPairTitle => 'Create or edit a pair';

  @override
  String get manualEntryMarketMakerPairDesc =>
      'Set base/quote, depth, min order size and trading status.';

  @override
  String get manualEntryMarketMakerSyncTitle => 'Sync the exchange';

  @override
  String get manualEntryMarketMakerSyncDesc =>
      'Trigger a manual sync to refresh markets from Binance.';

  @override
  String get manualEntryAdminTransactionsTitle => 'Monitor transactions';

  @override
  String get manualEntryAdminTransactionsDesc =>
      'Inspect suspicious activity and export filtered lists.';

  @override
  String get manualEntryAdminCurrenciesTitle => 'Manage currencies';

  @override
  String get manualEntryAdminCurrenciesDesc =>
      'Create, edit or pause tradable currencies.';

  @override
  String get manualEntryAdminDepositWatcherTitle => 'Deposit watcher';

  @override
  String get manualEntryAdminDepositWatcherDesc =>
      'Track incoming on-chain deposits and credit users.';

  @override
  String get manualEntrySystemConfigSaveTitle => 'Edit system config';

  @override
  String get manualEntrySystemConfigSaveDesc =>
      'Switch tabs (Auth Security / Core / Finance / Ops / Tech) and save.';

  @override
  String get manualEntryBroadcastSendTitle => 'Send a broadcast';

  @override
  String get manualEntryBroadcastSendDesc =>
      'Choose a type (system / alert / promo) and broadcast to all users.';

  @override
  String get manualGlossaryBody =>
      '## Key terms\n\n- **Order Book** — the live list of buy (bid) and sell (ask) orders for a trading pair.\n- **LIMIT order** — buy or sell at a price you choose; it waits in the book until matched.\n- **MARKET order** — buy or sell immediately at the best available price.\n- **STOP_LOSS** — a conditional order triggered when price reaches a threshold.\n- **Maker / Taker** — maker adds liquidity (LIMIT); taker removes it (MARKET).\n- **Available vs Frozen** — available can be traded; frozen is locked by an open order or pending withdrawal.\n- **2FA / TOTP** — a 6-digit code from an authenticator app used to confirm sensitive actions.\n- **On-chain** — a transaction settled on the blockchain (vs. internal ledger transfer).\n- **Sweep** — a treasury operation that consolidates funds into a cold wallet.\n- **Pair / Base / Quote** — pair = BTC/USDT, base = BTC, quote = USDT.';

  @override
  String get aiFloatingHintText => 'Drag to move';

  @override
  String get aiFloatingOpenTooltip => 'Open AI Assistant';

  @override
  String get manualFaqBody =>
      '## Frequently asked questions\n\n### Why is my withdrawal pending?\nLarge or first-time withdrawals are reviewed by an admin. You will receive a notification once approved.\n\n### I lost access to my 2FA device — what now?\nOpen Profile → Security, then contact support. An admin can reset your 2FA after identity verification.\n\n### How do I switch between demo and live trading?\nUse the exchange-sync card in Settings to refresh markets from Binance. For spot trading on Binance directly, link an API key under the Market Maker area.\n\n### Why is a market hidden from the list?\nAdmin can pause a market. Open Currencies from the drawer to view all currencies regardless of status.\n\n### What is the difference between Wallet and Managed Wallets?\nWallets are your personal balances. Managed Wallets are platform-owned wallets used for treasury operations.';

  @override
  String get manualContactBody =>
      '## Contact Support\n\n- **In-app**: open this manual\'s Glossary / FAQ first; many issues are covered there.\n- **Profile → Security**: request an email or password change; admin review is required.\n- **Notifications tab**: review the latest announcements and broadcast messages.\n- **Admin / Finance / Risk users**: use the drawer sections to reach the relevant operational tools.\n\nIf your issue is not covered, raise it inside the app and an admin will route it to the right team.';
}
