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
  String get cancel => 'Cancel';

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
  String get payosInvalidAmountMin => 'Invalid amount. Minimum is 10,000 VND.';

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
  String get payosNeedFiatTitle => 'Need fiat deposit instead?';

  @override
  String get payosNeedFiatDesc =>
      'Use PayOS to top up VND, then return to trade or transfer funds.';

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
      'Connect a Tron, Solana, or Sepolia wallet first so deposit and withdrawal flows have a verified destination.';

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
      'Use an account on Sepolia network that matches the wallet address you entered.';

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
  String get submitOnchainDeposit => 'Submit on-chain deposit';

  @override
  String get onchainDepositDesc =>
      'After sending tokens from your wallet to exchange deposit address, paste tx hash here.';

  @override
  String get platformDepositAddress => 'Platform deposit address';

  @override
  String sendAssetsToAddress(String network) {
    return 'Send $network assets to this address, then submit tx hash below.';
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
  String get noOnchainActivityTitle => 'No on-chain activity yet';

  @override
  String get noOnchainActivityDesc =>
      'Deposits you submit will appear here so users can review status and confirmations.';

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
  String get currenciesSortTopVolume => 'Top Volume';

  @override
  String get currenciesSortTopGainers => 'Top Gainers';

  @override
  String get currenciesSortTopLosers => 'Top Losers';

  @override
  String get currenciesSortAlphabet => 'A-Z';

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
  String get drawerManualResyncComingSoon =>
      'Manual exchange re-sync — coming soon';

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
  String get registerWithMetaMask => 'Register with MetaMask';

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
  String get depositOnchainHint =>
      'Funds will be converted to USDT and credited to your Cash Wallet';

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
      'This list is for deposit defaults and risk-managed wallets. Operational hot wallets used for Fund/Sweep are in Payment configuration → Payment ops (Fund/Sweep).';

  @override
  String get treasuryOpsScopeBanner =>
      'These wallets are for payment operations (fund from main, sweep back). User-facing deposit defaults are configured under User deposits & managed wallets (treasury icon on the toolbar).';

  @override
  String get paymentConfigTitle => 'Payment Configuration';

  @override
  String get paymentConfigMethodsTab => 'Methods';

  @override
  String get paymentConfigTreasuryWalletsTab => 'Payment ops (Fund/Sweep)';

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
  String get treasuryCreateWalletFab => 'Create wallet';

  @override
  String get treasuryCreateWalletDialogTitle => 'Create transaction wallet';

  @override
  String get treasuryCreateWalletCta => 'Create wallet';

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
  String get treasuryOpsGuideTitle => 'What are Sweep and Fund?';

  @override
  String get treasurySweepMeaning =>
      'Sweep: move assets from the selected wallet back to the main wallet to centralize liquidity. About 0.1 TRX is left on TRON wallets for fees/bandwidth.';

  @override
  String get treasuryFundMeaning =>
      'Fund: send assets from the main wallet to the selected wallet so it can process transactions.';

  @override
  String get treasuryOpsHowTo =>
      'How to use: if a wallet is low on funds, tap Fund and enter an amount; if it has excess funds, tap Sweep to move assets back to the main wallet.';

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
  String get treasuryFundAction => 'Fund wallet';

  @override
  String get treasuryFundTooltip => 'Fund this wallet from the main wallet';

  @override
  String get treasurySweepQueued =>
      'Sweep request received. This card\'s balance will update when the on-chain transfer completes.';

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
  String get treasuryFundQueued =>
      'Fund request received. This card\'s balance will update when the on-chain transfer completes.';

  @override
  String get treasuryWalletPendingOnChainBadge => 'Processing on-chain…';

  @override
  String get treasuryQueuedBalanceHint =>
      'Balance shown is unchanged until the chain confirms.';

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
  String get treasuryHistoryStatusPending => 'Pending';

  @override
  String get treasuryHistoryStatusProcessing => 'Processing';

  @override
  String get treasuryHistoryStatusConfirming => 'Confirming';

  @override
  String get treasuryHistoryStatusCompleted => 'Completed';

  @override
  String get treasuryHistoryStatusFailed => 'Failed';

  @override
  String get treasuryWalletCreatedSuccess => 'Transaction wallet created';

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
  String get withdrawalDetailInfoTitle => 'Withdrawal Information';

  @override
  String get withdrawalDetailAmount => 'Amount';

  @override
  String get withdrawalDetailChain => 'Chain';

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
}
