import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Crypto Trading App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @currencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currencies;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noMarkets.
  ///
  /// In en, this message translates to:
  /// **'No markets'**
  String get noMarkets;

  /// No description provided for @noWallets.
  ///
  /// In en, this message translates to:
  /// **'No wallets'**
  String get noWallets;

  /// No description provided for @tradingChart.
  ///
  /// In en, this message translates to:
  /// **'Trading Chart'**
  String get tradingChart;

  /// No description provided for @bids.
  ///
  /// In en, this message translates to:
  /// **'Bids (Buy)'**
  String get bids;

  /// No description provided for @asks.
  ///
  /// In en, this message translates to:
  /// **'Asks (Sell)'**
  String get asks;

  /// No description provided for @realtimeActive.
  ///
  /// In en, this message translates to:
  /// **'Real-time updates active'**
  String get realtimeActive;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @candles.
  ///
  /// In en, this message translates to:
  /// **'Candles'**
  String get candles;

  /// No description provided for @vol.
  ///
  /// In en, this message translates to:
  /// **'Vol'**
  String get vol;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @marketDetails.
  ///
  /// In en, this message translates to:
  /// **'Market Details'**
  String get marketDetails;

  /// No description provided for @marketNotFound.
  ///
  /// In en, this message translates to:
  /// **'Market not found'**
  String get marketNotFound;

  /// No description provided for @lastPrice.
  ///
  /// In en, this message translates to:
  /// **'Last Price'**
  String get lastPrice;

  /// No description provided for @change24h.
  ///
  /// In en, this message translates to:
  /// **'24h Change'**
  String get change24h;

  /// No description provided for @volume24h.
  ///
  /// In en, this message translates to:
  /// **'Volume (24h)'**
  String get volume24h;

  /// No description provided for @marketInformation.
  ///
  /// In en, this message translates to:
  /// **'Market Information'**
  String get marketInformation;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base Currency'**
  String get baseCurrency;

  /// No description provided for @quoteCurrency.
  ///
  /// In en, this message translates to:
  /// **'Quote Currency'**
  String get quoteCurrency;

  /// No description provided for @minOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Min Order Amount'**
  String get minOrderAmount;

  /// No description provided for @makerFee.
  ///
  /// In en, this message translates to:
  /// **'Maker Fee'**
  String get makerFee;

  /// No description provided for @takerFee.
  ///
  /// In en, this message translates to:
  /// **'Taker Fee'**
  String get takerFee;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @orderBook.
  ///
  /// In en, this message translates to:
  /// **'Order Book'**
  String get orderBook;

  /// No description provided for @asksSell.
  ///
  /// In en, this message translates to:
  /// **'ASKS (Sell)'**
  String get asksSell;

  /// No description provided for @bidsBuy.
  ///
  /// In en, this message translates to:
  /// **'BIDS (Buy)'**
  String get bidsBuy;

  /// No description provided for @waitingForChartData.
  ///
  /// In en, this message translates to:
  /// **'Waiting for chart data...'**
  String get waitingForChartData;

  /// No description provided for @connectedRealtime.
  ///
  /// In en, this message translates to:
  /// **'Connected to real-time updates'**
  String get connectedRealtime;

  /// No description provided for @connectedNoUpdates.
  ///
  /// In en, this message translates to:
  /// **'Connected — no updates for this pair'**
  String get connectedNoUpdates;

  /// No description provided for @noRealtimeUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'This pair may not have real-time data (e.g. not on Binance). Try BTC/USDT or ETH/USDT.'**
  String get noRealtimeUpdatesHint;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @frozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get frozen;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @depositSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deposit successful!'**
  String get depositSuccess;

  /// No description provided for @withdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdraw successful!'**
  String get withdrawSuccess;

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer successful!'**
  String get transferSuccess;

  /// No description provided for @depositFailed.
  ///
  /// In en, this message translates to:
  /// **'Deposit failed'**
  String get depositFailed;

  /// No description provided for @withdrawFailed.
  ///
  /// In en, this message translates to:
  /// **'Withdraw failed'**
  String get withdrawFailed;

  /// No description provided for @transferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get transferFailed;

  /// No description provided for @noActiveCurrencies.
  ///
  /// In en, this message translates to:
  /// **'No active currencies found'**
  String get noActiveCurrencies;

  /// No description provided for @lastTransaction.
  ///
  /// In en, this message translates to:
  /// **'Last Transaction'**
  String get lastTransaction;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search by amount, type, date...'**
  String get searchTransactions;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get filterByType;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsMatch.
  ///
  /// In en, this message translates to:
  /// **'No transactions match your search'**
  String get noTransactionsMatch;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @toUserId.
  ///
  /// In en, this message translates to:
  /// **'To User ID'**
  String get toUserId;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @viewAllCurrencies.
  ///
  /// In en, this message translates to:
  /// **'View all available currencies'**
  String get viewAllCurrencies;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appSettingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'App settings and preferences'**
  String get appSettingsPreferences;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @loggedOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccess;

  /// No description provided for @orderBookEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orderBookEmpty;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @limitOrder.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limitOrder;

  /// No description provided for @marketOrder.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get marketOrder;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @pairId.
  ///
  /// In en, this message translates to:
  /// **'Pair ID'**
  String get pairId;

  /// No description provided for @orderType.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get orderType;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get orderPlacedSuccess;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// No description provided for @tradingPair.
  ///
  /// In en, this message translates to:
  /// **'Trading pair'**
  String get tradingPair;

  /// No description provided for @recentTrades.
  ///
  /// In en, this message translates to:
  /// **'Recent trades'**
  String get recentTrades;

  /// No description provided for @youWillReceive.
  ///
  /// In en, this message translates to:
  /// **'You will receive'**
  String get youWillReceive;

  /// No description provided for @syncBinance.
  ///
  /// In en, this message translates to:
  /// **'Sync Binance'**
  String get syncBinance;

  /// No description provided for @syncBinanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Sync currencies and market pairs from Binance into the app database'**
  String get syncBinanceDescription;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync completed. Currencies and markets are up to date.'**
  String get syncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @searchMarketsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by symbol (e.g. BTC, USDT)'**
  String get searchMarketsHint;

  /// No description provided for @filterQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get filterQuote;

  /// No description provided for @filterQuoteAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterQuoteAll;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @payosTopupVnd.
  ///
  /// In en, this message translates to:
  /// **'Top up VND via PayOS'**
  String get payosTopupVnd;

  /// No description provided for @payosDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'VND Deposit (PayOS)'**
  String get payosDepositTitle;

  /// No description provided for @payosCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Create deposit order'**
  String get payosCreateOrder;

  /// No description provided for @payosAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (VND)'**
  String get payosAmountLabel;

  /// No description provided for @payosMinAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 10,000'**
  String get payosMinAmountHint;

  /// No description provided for @payosNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No deposit transactions yet.'**
  String get payosNoTransactions;

  /// No description provided for @payosOrderCode.
  ///
  /// In en, this message translates to:
  /// **'Order code'**
  String get payosOrderCode;

  /// No description provided for @payosEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount.'**
  String get payosEnterAmount;

  /// No description provided for @payosInvalidAmountMin.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount. Minimum is 10,000 VND.'**
  String get payosInvalidAmountMin;

  /// No description provided for @payosOpenLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open payment link.'**
  String get payosOpenLinkFailed;

  /// No description provided for @payosWaitingWebhook.
  ///
  /// In en, this message translates to:
  /// **'Waiting for PayOS webhook...'**
  String get payosWaitingWebhook;

  /// No description provided for @payosPaymentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment successful. Balance and history have been updated.'**
  String get payosPaymentUpdated;

  /// No description provided for @payosOrderProcessing.
  ///
  /// In en, this message translates to:
  /// **'Order is being processed. The system will auto-update when PayOS webhook arrives.'**
  String get payosOrderProcessing;

  /// No description provided for @payosNeedFiatTitle.
  ///
  /// In en, this message translates to:
  /// **'Need fiat deposit instead?'**
  String get payosNeedFiatTitle;

  /// No description provided for @payosNeedFiatDesc.
  ///
  /// In en, this message translates to:
  /// **'Use PayOS to top up VND, then return to trade or transfer funds.'**
  String get payosNeedFiatDesc;

  /// No description provided for @openOnchainWalletFlow.
  ///
  /// In en, this message translates to:
  /// **'Open On-chain Wallet Flow'**
  String get openOnchainWalletFlow;

  /// No description provided for @onchainWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'On-chain Wallets'**
  String get onchainWalletsTitle;

  /// No description provided for @onchainLinkedWallets.
  ///
  /// In en, this message translates to:
  /// **'Linked Wallets'**
  String get onchainLinkedWallets;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get addressCopied;

  /// No description provided for @copyFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy full address'**
  String get copyFullAddress;

  /// No description provided for @linkWallet.
  ///
  /// In en, this message translates to:
  /// **'Link Wallet'**
  String get linkWallet;

  /// No description provided for @linkWalletWeb.
  ///
  /// In en, this message translates to:
  /// **'Link Wallet (Web)'**
  String get linkWalletWeb;

  /// No description provided for @linkFirstWallet.
  ///
  /// In en, this message translates to:
  /// **'Link Your First Wallet'**
  String get linkFirstWallet;

  /// No description provided for @noLinkedWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'No linked wallets yet'**
  String get noLinkedWalletsTitle;

  /// No description provided for @noLinkedWalletsMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect a Tron, Solana, or Sepolia wallet first so deposit and withdrawal flows have a verified destination.'**
  String get noLinkedWalletsMessage;

  /// No description provided for @unlinkWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink wallet'**
  String get unlinkWalletTitle;

  /// No description provided for @confirmUnlinkWallet.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink {address}?'**
  String confirmUnlinkWallet(String address);

  /// No description provided for @walletUnlinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet unlinked successfully'**
  String get walletUnlinkedSuccess;

  /// No description provided for @failedToUnlinkWallet.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink wallet'**
  String get failedToUnlinkWallet;

  /// No description provided for @walletLabelPrefix.
  ///
  /// In en, this message translates to:
  /// **'Label: {label}'**
  String walletLabelPrefix(String label);

  /// No description provided for @linkedAtPrefix.
  ///
  /// In en, this message translates to:
  /// **'Linked at: {datetime}'**
  String linkedAtPrefix(String datetime);

  /// No description provided for @unlinkAction.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlinkAction;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkLabel;

  /// No description provided for @walletAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet address'**
  String get walletAddressLabel;

  /// No description provided for @walletAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get walletAddressRequired;

  /// No description provided for @labelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get labelOptional;

  /// No description provided for @enableTestMode.
  ///
  /// In en, this message translates to:
  /// **'Enable test mode (manual signature fallback)'**
  String get enableTestMode;

  /// No description provided for @requestingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Requesting...'**
  String get requestingChallenge;

  /// No description provided for @requestChallengeStep.
  ///
  /// In en, this message translates to:
  /// **'1) Request Challenge'**
  String get requestChallengeStep;

  /// No description provided for @challengeMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge message'**
  String get challengeMessageTitle;

  /// No description provided for @copyChallengManual.
  ///
  /// In en, this message translates to:
  /// **'2) Copy Challenge (Manual)'**
  String get copyChallengManual;

  /// No description provided for @openExtensionSign.
  ///
  /// In en, this message translates to:
  /// **'2) Open Extension & Sign'**
  String get openExtensionSign;

  /// No description provided for @openWalletSign.
  ///
  /// In en, this message translates to:
  /// **'2) Open Wallet & Sign'**
  String get openWalletSign;

  /// No description provided for @signatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signatureLabel;

  /// No description provided for @pasteSignatureHint.
  ///
  /// In en, this message translates to:
  /// **'Paste wallet signature here'**
  String get pasteSignatureHint;

  /// No description provided for @verifyingLink.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifyingLink;

  /// No description provided for @verifyLinkStep.
  ///
  /// In en, this message translates to:
  /// **'3) Verify Link'**
  String get verifyLinkStep;

  /// No description provided for @failedToRequestChallenge.
  ///
  /// In en, this message translates to:
  /// **'Failed to request challenge'**
  String get failedToRequestChallenge;

  /// No description provided for @challengeReceived.
  ///
  /// In en, this message translates to:
  /// **'Challenge received. Expires in {seconds}s'**
  String challengeReceived(int seconds);

  /// No description provided for @manualModeCopied.
  ///
  /// In en, this message translates to:
  /// **'Manual mode: challenge copied. Sign it in wallet manually, then paste signature below.'**
  String get manualModeCopied;

  /// No description provided for @walletAddressUpdatedMetamask.
  ///
  /// In en, this message translates to:
  /// **'Wallet address updated from MetaMask. Request a new challenge before signing.'**
  String get walletAddressUpdatedMetamask;

  /// No description provided for @useConnectedAccount.
  ///
  /// In en, this message translates to:
  /// **'Use connected account ({address})'**
  String useConnectedAccount(String address);

  /// No description provided for @requestChallengeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please request challenge first.'**
  String get requestChallengeFirst;

  /// No description provided for @signatureRequired.
  ///
  /// In en, this message translates to:
  /// **'Signature is required.'**
  String get signatureRequired;

  /// No description provided for @walletLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet linked successfully.'**
  String get walletLinkedSuccess;

  /// No description provided for @verifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Verify failed'**
  String get verifyFailed;

  /// No description provided for @webModeNotice.
  ///
  /// In en, this message translates to:
  /// **'Web mode: this flow signs via browser extension popup when provider is available.'**
  String get webModeNotice;

  /// No description provided for @appModeNotice.
  ///
  /// In en, this message translates to:
  /// **'App mode: Windows/Mobile uses wallet app or manual-sign fallback depending on network/provider availability.'**
  String get appModeNotice;

  /// No description provided for @manualSignGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual signing guide (Test mode)'**
  String get manualSignGuideTitle;

  /// No description provided for @browserSignGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Browser signing guide ({wallet})'**
  String browserSignGuideTitle(String wallet);

  /// No description provided for @desktopSignGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Desktop/Mobile signing guide ({wallet})'**
  String desktopSignGuideTitle(String wallet);

  /// No description provided for @walletGuideTestStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 2 copies the challenge text to your clipboard.'**
  String get walletGuideTestStep1;

  /// No description provided for @walletGuideNativeTestStep2.
  ///
  /// In en, this message translates to:
  /// **'Open your wallet or signer tool manually and sign the exact challenge text.'**
  String get walletGuideNativeTestStep2;

  /// No description provided for @walletGuideNativeTestStep3.
  ///
  /// In en, this message translates to:
  /// **'Paste the resulting signature into the Signature field, then click Verify Link.'**
  String get walletGuideNativeTestStep3;

  /// No description provided for @walletGuideWebTestStep2.
  ///
  /// In en, this message translates to:
  /// **'Sign the exact challenge text in your extension or wallet app.'**
  String get walletGuideWebTestStep2;

  /// No description provided for @walletGuideWebTestStep3.
  ///
  /// In en, this message translates to:
  /// **'Paste signature into the Signature field and click Verify Link.'**
  String get walletGuideWebTestStep3;

  /// No description provided for @walletGuideNativeEthStep1.
  ///
  /// In en, this message translates to:
  /// **'Install MetaMask browser extension and unlock it.'**
  String get walletGuideNativeEthStep1;

  /// No description provided for @walletGuideNativeEthStep2.
  ///
  /// In en, this message translates to:
  /// **'Use an account on Sepolia network that matches the wallet address you entered.'**
  String get walletGuideNativeEthStep2;

  /// No description provided for @walletGuideNativeEthStep3.
  ///
  /// In en, this message translates to:
  /// **'Click Step 2 to trigger deep-link; if nothing opens, sign manually in MetaMask and paste signature below.'**
  String get walletGuideNativeEthStep3;

  /// No description provided for @walletGuideNativeSolStep1.
  ///
  /// In en, this message translates to:
  /// **'Install Phantom extension or desktop app and unlock it.'**
  String get walletGuideNativeSolStep1;

  /// No description provided for @walletGuideNativeSolStep2.
  ///
  /// In en, this message translates to:
  /// **'Switch wallet to Solana Devnet and use the same address you entered.'**
  String get walletGuideNativeSolStep2;

  /// No description provided for @walletGuideNativeSolStep3.
  ///
  /// In en, this message translates to:
  /// **'Click Step 2; if deep-link fails, sign the challenge manually and paste signature below.'**
  String get walletGuideNativeSolStep3;

  /// No description provided for @walletGuideNativeTronStep1.
  ///
  /// In en, this message translates to:
  /// **'Install TronLink extension/app and unlock it.'**
  String get walletGuideNativeTronStep1;

  /// No description provided for @walletGuideNativeTronStep2.
  ///
  /// In en, this message translates to:
  /// **'Switch to Nile or Shasta account matching your entered address.'**
  String get walletGuideNativeTronStep2;

  /// No description provided for @walletGuideNativeTronStep3.
  ///
  /// In en, this message translates to:
  /// **'Click Step 2; if app does not open, open TronLink manually, sign challenge, then paste signature below.'**
  String get walletGuideNativeTronStep3;

  /// No description provided for @walletGuideWebEthStep1.
  ///
  /// In en, this message translates to:
  /// **'Use Chrome/Edge profile where MetaMask extension is installed and unlocked.'**
  String get walletGuideWebEthStep1;

  /// No description provided for @walletGuideWebEthStep2.
  ///
  /// In en, this message translates to:
  /// **'Ensure extension has site access on this app host (localhost or your domain).'**
  String get walletGuideWebEthStep2;

  /// No description provided for @walletGuideWebEthStep3.
  ///
  /// In en, this message translates to:
  /// **'Click Step 2 to open MetaMask popup and confirm personal_sign.'**
  String get walletGuideWebEthStep3;

  /// No description provided for @walletGuideWebSolStep1.
  ///
  /// In en, this message translates to:
  /// **'Use browser profile with Phantom extension enabled and unlocked.'**
  String get walletGuideWebSolStep1;

  /// No description provided for @walletGuideWebSolStep2.
  ///
  /// In en, this message translates to:
  /// **'Switch Phantom to Solana Devnet and confirm wallet address matches.'**
  String get walletGuideWebSolStep2;

  /// No description provided for @walletGuideWebSolStep3.
  ///
  /// In en, this message translates to:
  /// **'Click Step 2, approve the signature request, then continue verify.'**
  String get walletGuideWebSolStep3;

  /// No description provided for @walletGuideWebTronStep1.
  ///
  /// In en, this message translates to:
  /// **'Use browser profile with TronLink extension enabled and unlocked.'**
  String get walletGuideWebTronStep1;

  /// No description provided for @walletGuideWebTronStep2.
  ///
  /// In en, this message translates to:
  /// **'Switch to Nile or Shasta account that matches your entered address.'**
  String get walletGuideWebTronStep2;

  /// No description provided for @walletGuideWebTronStep3.
  ///
  /// In en, this message translates to:
  /// **'Click Step 2 and confirm signature in TronLink popup.'**
  String get walletGuideWebTronStep3;

  /// No description provided for @submitOnchainDeposit.
  ///
  /// In en, this message translates to:
  /// **'Submit on-chain deposit'**
  String get submitOnchainDeposit;

  /// No description provided for @onchainDepositDesc.
  ///
  /// In en, this message translates to:
  /// **'After sending tokens from your wallet to exchange deposit address, paste tx hash here.'**
  String get onchainDepositDesc;

  /// No description provided for @platformDepositAddress.
  ///
  /// In en, this message translates to:
  /// **'Platform deposit address'**
  String get platformDepositAddress;

  /// No description provided for @sendAssetsToAddress.
  ///
  /// In en, this message translates to:
  /// **'Send {network} assets to this address, then submit tx hash below.'**
  String sendAssetsToAddress(String network);

  /// No description provided for @onlyTransferSelectedChain.
  ///
  /// In en, this message translates to:
  /// **'Only transfer on the selected chain. Sending from wrong chain may cause permanent loss.'**
  String get onlyTransferSelectedChain;

  /// No description provided for @refreshAddress.
  ///
  /// In en, this message translates to:
  /// **'Refresh address'**
  String get refreshAddress;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @hideFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Hide full address'**
  String get hideFullAddress;

  /// No description provided for @showFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Show full address'**
  String get showFullAddress;

  /// No description provided for @couldNotLoadDepositAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not load deposit address.'**
  String get couldNotLoadDepositAddress;

  /// No description provided for @transactionHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction hash'**
  String get transactionHashLabel;

  /// No description provided for @txHashRequired.
  ///
  /// In en, this message translates to:
  /// **'Tx hash is required'**
  String get txHashRequired;

  /// No description provided for @depositAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Deposit address copied'**
  String get depositAddressCopied;

  /// No description provided for @senderWalletNotLinkedError.
  ///
  /// In en, this message translates to:
  /// **'Sender wallet is not linked. Link that wallet before submitting deposit.'**
  String get senderWalletNotLinkedError;

  /// No description provided for @depositSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deposit submitted successfully'**
  String get depositSubmittedSuccess;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be > 0'**
  String get amountMustBePositive;

  /// No description provided for @depositPreviewLinked.
  ///
  /// In en, this message translates to:
  /// **'Sender wallet is linked. Amount auto-filled from on-chain data.'**
  String get depositPreviewLinked;

  /// No description provided for @depositPreviewNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Sender wallet is not linked to your account. Link that wallet before submit.'**
  String get depositPreviewNotLinked;

  /// No description provided for @depositPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview: {status} · Amount {amount}'**
  String depositPreviewLabel(String status, String amount);

  /// No description provided for @allNetworks.
  ///
  /// In en, this message translates to:
  /// **'All networks'**
  String get allNetworks;

  /// No description provided for @txResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String txResultCount(int count);

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @noTxMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No transactions match these filters'**
  String get noTxMatchFilters;

  /// No description provided for @trySwitchingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try switching network, type, or sort to surface the transactions you need.'**
  String get trySwitchingFilters;

  /// No description provided for @txToAddress.
  ///
  /// In en, this message translates to:
  /// **'To: {address}'**
  String txToAddress(String address);

  /// No description provided for @txTypeDeposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get txTypeDeposits;

  /// No description provided for @txTypeWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get txTypeWithdrawals;

  /// No description provided for @txTypeTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get txTypeTransfers;

  /// No description provided for @noOnchainActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No on-chain activity yet'**
  String get noOnchainActivityTitle;

  /// No description provided for @noOnchainActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Deposits you submit will appear here so users can review status and confirmations.'**
  String get noOnchainActivityDesc;

  /// No description provided for @trySwitchingFiltersDeposit.
  ///
  /// In en, this message translates to:
  /// **'Try switching network, type, or sort to surface the transactions you need.'**
  String get trySwitchingFiltersDeposit;

  /// No description provided for @requestOnchainWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Request on-chain withdrawal'**
  String get requestOnchainWithdrawal;

  /// No description provided for @withdrawalDestinationDesc.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal destination must be a verified linked wallet on the same network.'**
  String get withdrawalDestinationDesc;

  /// No description provided for @linkedWalletDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked wallet'**
  String get linkedWalletDropdownLabel;

  /// No description provided for @selectDestinationWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select destination linked wallet'**
  String get selectDestinationWallet;

  /// No description provided for @withdrawalRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request submitted'**
  String get withdrawalRequestSubmitted;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get requestFailed;

  /// No description provided for @noVerifiedWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'No verified wallet on this network'**
  String get noVerifiedWalletTitle;

  /// No description provided for @noVerifiedWalletDesc.
  ///
  /// In en, this message translates to:
  /// **'Link and verify a wallet in the linked-wallets tab before requesting a withdrawal here.'**
  String get noVerifiedWalletDesc;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @requestWithdrawalAction.
  ///
  /// In en, this message translates to:
  /// **'Request Withdrawal'**
  String get requestWithdrawalAction;

  /// No description provided for @noWithdrawalActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No withdrawal activity yet'**
  String get noWithdrawalActivityTitle;

  /// No description provided for @noWithdrawalActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Approved withdrawals will show up here with their latest on-chain status.'**
  String get noWithdrawalActivityDesc;

  /// No description provided for @tryAnotherFilter.
  ///
  /// In en, this message translates to:
  /// **'Try another network or type chip to quickly bring matching transactions back.'**
  String get tryAnotherFilter;

  /// No description provided for @payosOpenLinkFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to open PayOS automatically'**
  String get payosOpenLinkFallbackTitle;

  /// No description provided for @payosOpenLinkFallbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payment link is ready. You can copy it or try opening it again.'**
  String get payosOpenLinkFallbackDesc;

  /// No description provided for @payosCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get payosCopyLink;

  /// No description provided for @payosOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get payosOpenInBrowser;

  /// No description provided for @payosLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Payment link copied'**
  String get payosLinkCopied;

  /// No description provided for @payosTapToOpenCheckout.
  ///
  /// In en, this message translates to:
  /// **'Tap to open checkout'**
  String get payosTapToOpenCheckout;

  /// No description provided for @payosPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled or expired.'**
  String get payosPaymentCancelled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
