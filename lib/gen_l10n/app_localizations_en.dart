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
  String get selectCurrency => 'Select Currency';

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
  String get amountMustBePositive => 'Amount must be > 0';

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
}
