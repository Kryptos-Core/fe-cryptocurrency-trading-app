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

  /// No description provided for @estimatedFee.
  ///
  /// In en, this message translates to:
  /// **'Estimated fee'**
  String get estimatedFee;

  /// No description provided for @spotWallet.
  ///
  /// In en, this message translates to:
  /// **'Spot wallet'**
  String get spotWallet;

  /// No description provided for @orderFundsFrom.
  ///
  /// In en, this message translates to:
  /// **'From wallet'**
  String get orderFundsFrom;

  /// No description provided for @orderFundsTo.
  ///
  /// In en, this message translates to:
  /// **'To wallet'**
  String get orderFundsTo;

  /// No description provided for @orderInsufficientBase.
  ///
  /// In en, this message translates to:
  /// **'Insufficient base balance. Available'**
  String get orderInsufficientBase;

  /// No description provided for @orderInsufficientQuote.
  ///
  /// In en, this message translates to:
  /// **'Insufficient quote balance. Available'**
  String get orderInsufficientQuote;

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

  /// No description provided for @manualResyncBinance.
  ///
  /// In en, this message translates to:
  /// **'Manual re-sync from Binance'**
  String get manualResyncBinance;

  /// No description provided for @manualResyncBinanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this only when you need to manually refresh market catalog from Binance.'**
  String get manualResyncBinanceDescription;

  /// No description provided for @lastManualSync.
  ///
  /// In en, this message translates to:
  /// **'Last manual sync'**
  String get lastManualSync;

  /// No description provided for @neverSyncedYet.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get neverSyncedYet;

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

  /// No description provided for @filterBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get filterBase;

  /// No description provided for @filterBaseAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterBaseAll;

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

  /// No description provided for @marketsSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get marketsSortBy;

  /// No description provided for @marketsSortTopVolume.
  ///
  /// In en, this message translates to:
  /// **'Top Volume'**
  String get marketsSortTopVolume;

  /// No description provided for @marketsSortTopGainers.
  ///
  /// In en, this message translates to:
  /// **'Top Gainers'**
  String get marketsSortTopGainers;

  /// No description provided for @marketsSortTopLosers.
  ///
  /// In en, this message translates to:
  /// **'Top Losers'**
  String get marketsSortTopLosers;

  /// No description provided for @marketsSortSymbolAsc.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get marketsSortSymbolAsc;

  /// No description provided for @marketsSortSymbolDesc.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get marketsSortSymbolDesc;

  /// No description provided for @marketsSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get marketsSortNewest;

  /// No description provided for @marketsSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get marketsSortOldest;

  /// No description provided for @marketsFuzzySearch.
  ///
  /// In en, this message translates to:
  /// **'Smart search'**
  String get marketsFuzzySearch;

  /// No description provided for @marketsResultSuffix.
  ///
  /// In en, this message translates to:
  /// **'pairs'**
  String get marketsResultSuffix;

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

  /// No description provided for @openWalletManualSign.
  ///
  /// In en, this message translates to:
  /// **'2) Open Wallet (Manual Sign)'**
  String get openWalletManualSign;

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

  /// No description provided for @walletWindowsPrecheckReady.
  ///
  /// In en, this message translates to:
  /// **'Windows pre-check: extension is ready, you can continue signing.'**
  String get walletWindowsPrecheckReady;

  /// No description provided for @walletWindowsPrecheckRequired.
  ///
  /// In en, this message translates to:
  /// **'Windows pre-check: confirm extension is installed before signing.'**
  String get walletWindowsPrecheckRequired;

  /// No description provided for @walletWindowsPrecheckCheck.
  ///
  /// In en, this message translates to:
  /// **'Check extension in browser'**
  String get walletWindowsPrecheckCheck;

  /// No description provided for @walletWindowsPrecheckRecheck.
  ///
  /// In en, this message translates to:
  /// **'Re-check extension'**
  String get walletWindowsPrecheckRecheck;

  /// No description provided for @walletExtensionCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check {extension}'**
  String walletExtensionCheckTitle(String extension);

  /// No description provided for @walletExtensionCheckMessage.
  ///
  /// In en, this message translates to:
  /// **'Browser has been opened so you can check {extension}. If installed and unlocked, click Ready to continue wallet linking.'**
  String walletExtensionCheckMessage(String extension);

  /// No description provided for @walletExtensionCheckClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get walletExtensionCheckClose;

  /// No description provided for @walletExtensionInstallAction.
  ///
  /// In en, this message translates to:
  /// **'Install {extension}'**
  String walletExtensionInstallAction(String extension);

  /// No description provided for @walletExtensionReadyAction.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get walletExtensionReadyAction;

  /// No description provided for @walletDontAskAgainSession.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again in this session'**
  String get walletDontAskAgainSession;

  /// No description provided for @walletOpenTronLinkExtension.
  ///
  /// In en, this message translates to:
  /// **'Open TronLink Extension Manager'**
  String get walletOpenTronLinkExtension;

  /// No description provided for @walletWindowsNativeSignNotice.
  ///
  /// In en, this message translates to:
  /// **'Windows native app cannot trigger extension signing popup directly. Direct popup signing is available only on web (Chrome/Edge).'**
  String get walletWindowsNativeSignNotice;

  /// No description provided for @walletTronLinkExtensionOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened TronLink extension page.'**
  String get walletTronLinkExtensionOpened;

  /// No description provided for @walletExtensionOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open extension page.'**
  String get walletExtensionOpenFailed;

  /// No description provided for @walletExtensionInstallOpenedInfo.
  ///
  /// In en, this message translates to:
  /// **'Opened {extension} install page. After installation, return and run check again.'**
  String walletExtensionInstallOpenedInfo(String extension);

  /// No description provided for @walletExtensionPrecheckSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pre-check completed. Open extension, sign challenge, then paste signature below.'**
  String get walletExtensionPrecheckSuccess;

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

  /// No description provided for @currenciesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search currencies...'**
  String get currenciesSearchHint;

  /// No description provided for @currenciesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get currenciesFilterAll;

  /// No description provided for @currenciesTradable.
  ///
  /// In en, this message translates to:
  /// **'Tradable'**
  String get currenciesTradable;

  /// No description provided for @currenciesSortTopVolume.
  ///
  /// In en, this message translates to:
  /// **'Top Volume'**
  String get currenciesSortTopVolume;

  /// No description provided for @currenciesSortTopGainers.
  ///
  /// In en, this message translates to:
  /// **'Top Gainers'**
  String get currenciesSortTopGainers;

  /// No description provided for @currenciesSortTopLosers.
  ///
  /// In en, this message translates to:
  /// **'Top Losers'**
  String get currenciesSortTopLosers;

  /// No description provided for @currenciesSortAlphabet.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get currenciesSortAlphabet;

  /// No description provided for @currenciesNoCurrenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get currenciesNoCurrenciesFound;

  /// No description provided for @currenciesNoMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No currencies match your search'**
  String get currenciesNoMatchSearch;

  /// No description provided for @currenciesDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency Details'**
  String get currenciesDetailTitle;

  /// No description provided for @currenciesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Currency not found'**
  String get currenciesNotFound;

  /// No description provided for @currenciesMarketOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Overview'**
  String get currenciesMarketOverviewTitle;

  /// No description provided for @currenciesConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency Configuration'**
  String get currenciesConfigurationTitle;

  /// No description provided for @currenciesSymbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get currenciesSymbolLabel;

  /// No description provided for @currenciesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get currenciesNameLabel;

  /// No description provided for @currenciesPrecisionScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Precision Scale'**
  String get currenciesPrecisionScaleLabel;

  /// No description provided for @currenciesMinWithdrawLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Withdraw'**
  String get currenciesMinWithdrawLabel;

  /// No description provided for @currenciesYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get currenciesYes;

  /// No description provided for @currenciesNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get currenciesNo;

  /// No description provided for @profileTapToChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Tap to change avatar'**
  String get profileTapToChangeAvatar;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEditName;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get profileAvatarUpdated;

  /// No description provided for @profileSecurityRequiresApproval.
  ///
  /// In en, this message translates to:
  /// **'Security (requires approval)'**
  String get profileSecurityRequiresApproval;

  /// No description provided for @profileChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get profileChangeEmail;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordDirect.
  ///
  /// In en, this message translates to:
  /// **'Change directly, no approval required'**
  String get profileChangePasswordDirect;

  /// No description provided for @profilePasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password has been changed'**
  String get profilePasswordChanged;

  /// No description provided for @profileOtpAdminReviewRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP + admin review required'**
  String get profileOtpAdminReviewRequired;

  /// No description provided for @profileEnable2faFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA first'**
  String get profileEnable2faFirstTitle;

  /// No description provided for @profileEnable2faFirstDesc.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings to enable 2FA before changing email/password'**
  String get profileEnable2faFirstDesc;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurityTitle;

  /// No description provided for @settings2faDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA to protect sensitive actions like changing email/password.'**
  String get settings2faDescription;

  /// No description provided for @settings2faLabel.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get settings2faLabel;

  /// No description provided for @settings2faEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settings2faEnabled;

  /// No description provided for @settings2faDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settings2faDisabled;

  /// No description provided for @otpSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your verified email.'**
  String get otpSentToEmail;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP verification'**
  String get otpVerificationTitle;

  /// No description provided for @otpEnterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get otpEnterCodeHint;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpRequiredEnable2faFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enable 2FA in Settings before changing email or password.'**
  String get otpRequiredEnable2faFirst;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get aboutOpenInBrowser;

  /// No description provided for @aboutPolicyGuideHint.
  ///
  /// In en, this message translates to:
  /// **'Policy, app information, and user guide are available in browser.'**
  String get aboutPolicyGuideHint;

  /// No description provided for @aboutAppTileTitle.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get aboutAppTileTitle;

  /// No description provided for @aboutAppTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Policy, app info, user guide'**
  String get aboutAppTileSubtitle;

  /// No description provided for @requestSentPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Request sent. Pending approval.'**
  String get requestSentPendingApproval;

  /// No description provided for @broadcastNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Notification'**
  String get broadcastNotificationTitle;

  /// No description provided for @broadcastInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'This notification will be delivered to all active users in real-time and persisted in their notification history.'**
  String get broadcastInfoBanner;

  /// No description provided for @broadcastTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get broadcastTypeLabel;

  /// No description provided for @broadcastTypeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get broadcastTypeSystem;

  /// No description provided for @broadcastTypeAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get broadcastTypeAlert;

  /// No description provided for @broadcastTypePromo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get broadcastTypePromo;

  /// No description provided for @broadcastTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get broadcastTitleLabel;

  /// No description provided for @broadcastTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. System maintenance tonight at 23:00'**
  String get broadcastTitleHint;

  /// No description provided for @broadcastTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get broadcastTitleRequired;

  /// No description provided for @broadcastTitleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title too short'**
  String get broadcastTitleTooShort;

  /// No description provided for @broadcastMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get broadcastMessageLabel;

  /// No description provided for @broadcastMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write your notification message here...'**
  String get broadcastMessageHint;

  /// No description provided for @broadcastMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Message body is required'**
  String get broadcastMessageRequired;

  /// No description provided for @broadcastMessageTooShort.
  ///
  /// In en, this message translates to:
  /// **'Message too short'**
  String get broadcastMessageTooShort;

  /// No description provided for @broadcastSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get broadcastSending;

  /// No description provided for @broadcastSendAllUsers.
  ///
  /// In en, this message translates to:
  /// **'Send to all users'**
  String get broadcastSendAllUsers;

  /// No description provided for @broadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notification broadcast successfully'**
  String get broadcastSuccess;

  /// No description provided for @broadcastFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to send notification. Please try again.'**
  String get broadcastFailedTryAgain;

  /// No description provided for @noPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get noPermissionMessage;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTooltip;

  /// No description provided for @onchainTooltip.
  ///
  /// In en, this message translates to:
  /// **'On-chain'**
  String get onchainTooltip;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @drawerOnchainWallets.
  ///
  /// In en, this message translates to:
  /// **'On-chain Wallets'**
  String get drawerOnchainWallets;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerUserManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get drawerUserManagement;

  /// No description provided for @drawerAdminArea.
  ///
  /// In en, this message translates to:
  /// **'Admin area'**
  String get drawerAdminArea;

  /// No description provided for @drawerUserMgmtComingSoon.
  ///
  /// In en, this message translates to:
  /// **'User management screen — coming soon'**
  String get drawerUserMgmtComingSoon;

  /// No description provided for @drawerBroadcastNotification.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Notification'**
  String get drawerBroadcastNotification;

  /// No description provided for @drawerBroadcastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send to all users'**
  String get drawerBroadcastSubtitle;

  /// No description provided for @drawerManualResync.
  ///
  /// In en, this message translates to:
  /// **'Manual re-sync Binance'**
  String get drawerManualResync;

  /// No description provided for @drawerManualResyncComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Manual exchange re-sync — coming soon'**
  String get drawerManualResyncComingSoon;

  /// No description provided for @drawerSecurityRequests.
  ///
  /// In en, this message translates to:
  /// **'Security requests'**
  String get drawerSecurityRequests;

  /// No description provided for @drawerSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve/reject email & password changes'**
  String get drawerSecuritySubtitle;

  /// No description provided for @authRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get authRequiredTitle;

  /// No description provided for @authRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to access this feature.'**
  String get authRequiredSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Guest'**
  String get welcomeGuest;

  /// No description provided for @guestSignInDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your wallet, place orders, and manage your account.'**
  String get guestSignInDesc;

  /// No description provided for @guestFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Available without signing in'**
  String get guestFeaturesTitle;

  /// No description provided for @guestFeatureLiveMarkets.
  ///
  /// In en, this message translates to:
  /// **'Live market data & charts'**
  String get guestFeatureLiveMarkets;

  /// No description provided for @guestFeatureCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Supported currencies & networks'**
  String get guestFeatureCurrencies;

  /// No description provided for @guestFeatureDeposit.
  ///
  /// In en, this message translates to:
  /// **'Platform deposit methods'**
  String get guestFeatureDeposit;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsJustNow;

  /// No description provided for @notificationsMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notificationsMinAgo(int count);

  /// No description provided for @notificationsHourAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notificationsHourAgo(int count);

  /// No description provided for @notificationsDayAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notificationsDayAgo(int count);

  /// No description provided for @notificationsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get notificationsDetails;

  /// No description provided for @notificationsTypeAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get notificationsTypeAlert;

  /// No description provided for @notificationsTypePromo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get notificationsTypePromo;

  /// No description provided for @notificationsTypeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationsTypeSystem;

  /// No description provided for @dashboardTopMarkets.
  ///
  /// In en, this message translates to:
  /// **'Top Markets'**
  String get dashboardTopMarkets;

  /// No description provided for @dashboardMyWallets.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get dashboardMyWallets;

  /// No description provided for @dashboardTotalPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Total Portfolio Value'**
  String get dashboardTotalPortfolioValue;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardNoMarketsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No markets available'**
  String get dashboardNoMarketsAvailable;

  /// No description provided for @dashboardNoFundedWallets.
  ///
  /// In en, this message translates to:
  /// **'No funded wallets yet.\nDeposit or trade to see balances here.'**
  String get dashboardNoFundedWallets;

  /// No description provided for @dashboardWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get dashboardWallets;

  /// No description provided for @dashboardActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get dashboardActive;

  /// No description provided for @securityRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Security change requests'**
  String get securityRequestsTitle;

  /// No description provided for @securityRequestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved'**
  String get securityRequestApproved;

  /// No description provided for @securityRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get securityRequestRejected;

  /// No description provided for @securityRejectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get securityRejectDialogTitle;

  /// No description provided for @securityRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Optional reason'**
  String get securityRejectReasonHint;

  /// No description provided for @securityRequestNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get securityRequestNoPending;

  /// No description provided for @securityRequestRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested: {date}'**
  String securityRequestRequested(String date);

  /// No description provided for @securityRequestApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get securityRequestApprove;

  /// No description provided for @securityRequestReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get securityRequestReject;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateAccount;

  /// No description provided for @registerSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get registerSignUpSubtitle;

  /// No description provided for @registerFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get registerFirstNameLabel;

  /// No description provided for @registerFirstNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Only letters and spaces allowed'**
  String get registerFirstNameHelper;

  /// No description provided for @registerFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get registerFirstNameRequired;

  /// No description provided for @registerLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get registerLastNameLabel;

  /// No description provided for @registerLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get registerLastNameRequired;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'user@example.com'**
  String get registerEmailHint;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters with uppercase, lowercase, number'**
  String get registerPasswordHint;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get registerPasswordMinLength;

  /// No description provided for @registerPasswordNeedsUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain uppercase letter'**
  String get registerPasswordNeedsUppercase;

  /// No description provided for @registerPasswordNeedsLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain lowercase letter'**
  String get registerPasswordNeedsLowercase;

  /// No description provided for @registerPasswordNeedsNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a number'**
  String get registerPasswordNeedsNumber;

  /// No description provided for @registerPasswordNeedsSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a special character'**
  String get registerPasswordNeedsSpecial;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get registerConfirmPasswordRequired;

  /// No description provided for @registerPasswordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordsNoMatch;

  /// No description provided for @registerWalletDivider.
  ///
  /// In en, this message translates to:
  /// **'Register with wallet'**
  String get registerWalletDivider;

  /// No description provided for @registerWithMetaMask.
  ///
  /// In en, this message translates to:
  /// **'Register with MetaMask'**
  String get registerWithMetaMask;

  /// No description provided for @registerWithTronLink.
  ///
  /// In en, this message translates to:
  /// **'Register with TronLink'**
  String get registerWithTronLink;

  /// No description provided for @registerSuccessLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Logging in...'**
  String get registerSuccessLoggingIn;

  /// No description provided for @registerLoginFailedManual.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try logging in manually.'**
  String get registerLoginFailedManual;

  /// No description provided for @registerLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get registerLoginSuccess;

  /// No description provided for @registerWalletSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet registration & login successful!'**
  String get registerWalletSuccess;

  /// No description provided for @walletDetails.
  ///
  /// In en, this message translates to:
  /// **'Wallet Details'**
  String get walletDetails;

  /// No description provided for @walletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallet not found'**
  String get walletNotFound;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get walletAvailableBalance;

  /// No description provided for @walletFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get walletFrozen;

  /// No description provided for @walletTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get walletTotal;

  /// No description provided for @walletAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get walletAvailable;

  /// No description provided for @walletTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get walletTransactionHistory;

  /// No description provided for @walletNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get walletNoTransactions;

  /// No description provided for @walletBalanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String walletBalanceAfter(String amount);

  /// No description provided for @walletUsdValue.
  ///
  /// In en, this message translates to:
  /// **'USD Value'**
  String get walletUsdValue;

  /// No description provided for @totalPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Total Portfolio Value'**
  String get totalPortfolioValue;

  /// No description provided for @noWalletsFound.
  ///
  /// In en, this message translates to:
  /// **'No wallets found'**
  String get noWalletsFound;

  /// No description provided for @myWallets.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get myWallets;

  /// No description provided for @cashWalletSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Wallet'**
  String get cashWalletSectionTitle;

  /// No description provided for @cashWalletSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receives all deposits • Use to buy coins'**
  String get cashWalletSectionSubtitle;

  /// No description provided for @coinAssetsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get coinAssetsSectionTitle;

  /// No description provided for @coinAssetsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Coins from trading'**
  String get coinAssetsSectionSubtitle;

  /// No description provided for @depositOnchainHint.
  ///
  /// In en, this message translates to:
  /// **'Funds will be converted to USDT and credited to your Cash Wallet'**
  String get depositOnchainHint;

  /// No description provided for @treasuryTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasury Management'**
  String get treasuryTitle;

  /// No description provided for @treasuryManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage company wallets & deposit settings'**
  String get treasuryManageSubtitle;

  /// No description provided for @recommendedChainUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recommended chain updated to {chain}'**
  String recommendedChainUpdated(String chain);

  /// No description provided for @managedWalletsSection.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get managedWalletsSection;

  /// No description provided for @managedWalletsTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String managedWalletsTotalCount(int count);

  /// No description provided for @managedWalletsNewWallet.
  ///
  /// In en, this message translates to:
  /// **'New Wallet'**
  String get managedWalletsNewWallet;

  /// No description provided for @managedWalletsActiveDefaults.
  ///
  /// In en, this message translates to:
  /// **'Active Deposit Defaults'**
  String get managedWalletsActiveDefaults;

  /// No description provided for @managedWalletsNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get managedWalletsNotConfigured;

  /// No description provided for @managedWalletsRecommendedChainTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Chain for Users'**
  String get managedWalletsRecommendedChainTitle;

  /// No description provided for @managedWalletsRecommendedChainDesc.
  ///
  /// In en, this message translates to:
  /// **'Users will see this chain as the primary deposit option.'**
  String get managedWalletsRecommendedChainDesc;

  /// No description provided for @managedWalletsRecommendedChainLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended Chain'**
  String get managedWalletsRecommendedChainLabel;

  /// No description provided for @managedWalletsSelectChain.
  ///
  /// In en, this message translates to:
  /// **'Select chain'**
  String get managedWalletsSelectChain;

  /// No description provided for @managedWalletsNoWallets.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet'**
  String get managedWalletsNoWallets;

  /// No description provided for @managedWalletsNoWalletsDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate your first treasury wallet to start accepting deposits.'**
  String get managedWalletsNoWalletsDesc;

  /// No description provided for @managedWalletsCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create First Wallet'**
  String get managedWalletsCreateFirst;

  /// No description provided for @walletSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Wallet set as default deposit address'**
  String get walletSetAsDefault;

  /// No description provided for @walletDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Wallet deactivated'**
  String get walletDeactivated;

  /// No description provided for @deactivateWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Wallet'**
  String get deactivateWalletTitle;

  /// No description provided for @deactivateWalletContent.
  ///
  /// In en, this message translates to:
  /// **'This wallet will be deactivated and can no longer receive or send funds. This cannot be undone.'**
  String get deactivateWalletContent;

  /// No description provided for @deactivateWalletAction.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateWalletAction;

  /// No description provided for @managedWalletOnchainBalance.
  ///
  /// In en, this message translates to:
  /// **'On-chain Balance'**
  String get managedWalletOnchainBalance;

  /// No description provided for @managedWalletSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get managedWalletSetDefault;

  /// No description provided for @managedWalletDefaultDeposit.
  ///
  /// In en, this message translates to:
  /// **'Default Deposit'**
  String get managedWalletDefaultDeposit;

  /// No description provided for @managedWalletSendTrx.
  ///
  /// In en, this message translates to:
  /// **'Send TRX'**
  String get managedWalletSendTrx;

  /// No description provided for @managedWalletTxHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get managedWalletTxHistory;

  /// No description provided for @managedWalletNoTx.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get managedWalletNoTx;

  /// No description provided for @sendTrxTitle.
  ///
  /// In en, this message translates to:
  /// **'Send TRX'**
  String get sendTrxTitle;

  /// No description provided for @sendTrxConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Send'**
  String get sendTrxConfirmTitle;

  /// No description provided for @sendTrxConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Send {amount} TRX to\n{address}?'**
  String sendTrxConfirmContent(String amount, String address);

  /// No description provided for @sendTrxConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get sendTrxConfirm;

  /// No description provided for @sendTrxRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Address'**
  String get sendTrxRecipientLabel;

  /// No description provided for @sendTrxRecipientHint.
  ///
  /// In en, this message translates to:
  /// **'T...'**
  String get sendTrxRecipientHint;

  /// No description provided for @sendTrxAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get sendTrxAddressRequired;

  /// No description provided for @sendTrxInvalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid address'**
  String get sendTrxInvalidAddress;

  /// No description provided for @sendTrxAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (TRX)'**
  String get sendTrxAmountLabel;

  /// No description provided for @sendTrxAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get sendTrxAmountHint;

  /// No description provided for @sendTrxAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get sendTrxAmountRequired;

  /// No description provided for @sendTrxAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get sendTrxAmountInvalid;

  /// No description provided for @sendTrxSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sendTrxSending;

  /// No description provided for @sendTrxSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendTrxSend;

  /// No description provided for @sendTrxSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction sent successfully'**
  String get sendTrxSuccess;

  /// No description provided for @createWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Treasury Wallet'**
  String get createWalletTitle;

  /// No description provided for @createWalletBlockchainLabel.
  ///
  /// In en, this message translates to:
  /// **'Blockchain'**
  String get createWalletBlockchainLabel;

  /// No description provided for @createWalletLabelField.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get createWalletLabelField;

  /// No description provided for @createWalletLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Fund, AML Reserve'**
  String get createWalletLabelHint;

  /// No description provided for @createWalletGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get createWalletGenerating;

  /// No description provided for @createWalletGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Wallet'**
  String get createWalletGenerate;

  /// No description provided for @createWalletSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'A new Tron wallet will be generated. The private key is encrypted and stored securely. You will never be shown the private key.'**
  String get createWalletSecurityNote;

  /// No description provided for @createWalletSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet Created!'**
  String get createWalletSuccess;

  /// No description provided for @createWalletAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get createWalletAddressLabel;

  /// No description provided for @createWalletAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get createWalletAddressCopied;

  /// No description provided for @createWalletDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get createWalletDone;

  /// No description provided for @createWalletFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create wallet'**
  String get createWalletFailed;

  /// No description provided for @walletBadgeDefault.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get walletBadgeDefault;

  /// No description provided for @walletBadgeInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get walletBadgeInactive;

  /// No description provided for @depositMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform Deposit Methods'**
  String get depositMethodsTitle;

  /// No description provided for @depositMethodRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get depositMethodRecommended;

  /// No description provided for @copyAddressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddressTooltip;

  /// No description provided for @marketMakerHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Maker'**
  String get marketMakerHubTitle;

  /// No description provided for @marketMakerHubDrawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard · Config · Maker orders'**
  String get marketMakerHubDrawerSubtitle;

  /// No description provided for @marketMakerConfigCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Maker configuration'**
  String get marketMakerConfigCardTitle;

  /// No description provided for @marketMakerConfigCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage spread, stop-loss, and position limits per trading pair.'**
  String get marketMakerConfigCardSubtitle;

  /// No description provided for @marketMakerPlaceOrdersCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Place maker orders'**
  String get marketMakerPlaceOrdersCardTitle;

  /// No description provided for @marketMakerPlaceOrdersCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place BUY/SELL order pairs around market price using batch orders.'**
  String get marketMakerPlaceOrdersCardSubtitle;

  /// No description provided for @marketMakerPositionDashboardCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Position dashboard'**
  String get marketMakerPositionDashboardCardTitle;

  /// No description provided for @marketMakerPositionDashboardCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor open orders, positions, and unrealized P/L in real time.'**
  String get marketMakerPositionDashboardCardSubtitle;

  /// No description provided for @marketMakerDashboardComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Position dashboard — coming soon'**
  String get marketMakerDashboardComingSoon;

  /// No description provided for @marketMakerFieldPair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get marketMakerFieldPair;

  /// No description provided for @marketMakerFieldSpreadBps.
  ///
  /// In en, this message translates to:
  /// **'Spread (bps)'**
  String get marketMakerFieldSpreadBps;

  /// No description provided for @marketMakerFieldSpreadAlertBps.
  ///
  /// In en, this message translates to:
  /// **'Spread alert threshold (bps)'**
  String get marketMakerFieldSpreadAlertBps;

  /// No description provided for @marketMakerFieldOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Order amount'**
  String get marketMakerFieldOrderAmount;

  /// No description provided for @marketMakerFieldStopLossOptional.
  ///
  /// In en, this message translates to:
  /// **'Stop-loss % (optional)'**
  String get marketMakerFieldStopLossOptional;

  /// No description provided for @marketMakerFieldMaxPositionBaseOptional.
  ///
  /// In en, this message translates to:
  /// **'Max position base (optional)'**
  String get marketMakerFieldMaxPositionBaseOptional;

  /// No description provided for @marketMakerFieldActiveConfig.
  ///
  /// In en, this message translates to:
  /// **'Active config'**
  String get marketMakerFieldActiveConfig;

  /// No description provided for @marketMakerFieldOrderAmountOverrideOptional.
  ///
  /// In en, this message translates to:
  /// **'Place order amount override (optional)'**
  String get marketMakerFieldOrderAmountOverrideOptional;

  /// No description provided for @marketMakerFieldRefreshCycleKeyOptional.
  ///
  /// In en, this message translates to:
  /// **'Refresh cycle key (optional idempotency)'**
  String get marketMakerFieldRefreshCycleKeyOptional;

  /// No description provided for @marketMakerButtonSaveConfig.
  ///
  /// In en, this message translates to:
  /// **'Save config'**
  String get marketMakerButtonSaveConfig;

  /// No description provided for @marketMakerButtonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get marketMakerButtonDelete;

  /// No description provided for @marketMakerButtonPlaceTwoSidedOrders.
  ///
  /// In en, this message translates to:
  /// **'Place two-sided maker orders'**
  String get marketMakerButtonPlaceTwoSidedOrders;

  /// No description provided for @marketMakerValidationSpreadBps.
  ///
  /// In en, this message translates to:
  /// **'Invalid spread (bps)'**
  String get marketMakerValidationSpreadBps;

  /// No description provided for @marketMakerValidationAlertThreshold.
  ///
  /// In en, this message translates to:
  /// **'Invalid alert threshold'**
  String get marketMakerValidationAlertThreshold;

  /// No description provided for @marketMakerValidationOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid order amount'**
  String get marketMakerValidationOrderAmount;

  /// No description provided for @marketMakerNoActivePairs.
  ///
  /// In en, this message translates to:
  /// **'No active trading pairs found'**
  String get marketMakerNoActivePairs;

  /// No description provided for @marketMakerLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {when}'**
  String marketMakerLastUpdated(String when);

  /// No description provided for @marketMakerSnackSavedConfig.
  ///
  /// In en, this message translates to:
  /// **'Saved market maker configuration'**
  String get marketMakerSnackSavedConfig;

  /// No description provided for @marketMakerSnackSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get marketMakerSnackSaveFailed;

  /// No description provided for @marketMakerSnackDeletedConfig.
  ///
  /// In en, this message translates to:
  /// **'Deleted market maker configuration'**
  String get marketMakerSnackDeletedConfig;

  /// No description provided for @marketMakerSnackDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get marketMakerSnackDeleteFailed;

  /// No description provided for @marketMakerSnackPlaceOrdersFailed.
  ///
  /// In en, this message translates to:
  /// **'Place maker orders failed'**
  String get marketMakerSnackPlaceOrdersFailed;

  /// No description provided for @marketMakerOrdersResultReplayed.
  ///
  /// In en, this message translates to:
  /// **'Replayed'**
  String get marketMakerOrdersResultReplayed;

  /// No description provided for @marketMakerOrdersResultRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Refreshed'**
  String get marketMakerOrdersResultRefreshed;

  /// No description provided for @marketMakerOrdersPlacedSummary.
  ///
  /// In en, this message translates to:
  /// **'{action}: cancelled {cancelled}, placed {placed} (BUY: {buyPrice}, SELL: {sellPrice})'**
  String marketMakerOrdersPlacedSummary(String action, String cancelled,
      String placed, String buyPrice, String sellPrice);

  /// No description provided for @marketMakerPlaceOrdersFormHint.
  ///
  /// In en, this message translates to:
  /// **'Uses the saved configuration for the selected pair. Override amount or idempotency key if needed.'**
  String get marketMakerPlaceOrdersFormHint;
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
