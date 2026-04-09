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

  /// No description provided for @walletPortfolioCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Total portfolio'**
  String get walletPortfolioCardTitle;

  /// No description provided for @walletPortfolioEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No wallet data yet. Pull to refresh or check your connection.'**
  String get walletPortfolioEmptyHint;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currencySelectHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to search or choose a currency'**
  String get currencySelectHint;

  /// No description provided for @searchCurrenciesHint.
  ///
  /// In en, this message translates to:
  /// **'Search by symbol or name (e.g. BTC, USDT)'**
  String get searchCurrenciesHint;

  /// No description provided for @currencyPickerFilter.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get currencyPickerFilter;

  /// No description provided for @currencyPickerFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get currencyPickerFilterAll;

  /// No description provided for @currencyPickerFilterTradable.
  ///
  /// In en, this message translates to:
  /// **'Tradable'**
  String get currencyPickerFilterTradable;

  /// No description provided for @currencyPickerFilterNonTradable.
  ///
  /// In en, this message translates to:
  /// **'Non-tradable'**
  String get currencyPickerFilterNonTradable;

  /// No description provided for @currencyPickerNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No currencies match your search or filter'**
  String get currencyPickerNoMatches;

  /// No description provided for @currencyPickerRemoveRecent.
  ///
  /// In en, this message translates to:
  /// **'Remove from recent'**
  String get currencyPickerRemoveRecent;

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

  /// No description provided for @tradingPairPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select trading pair'**
  String get tradingPairPickerTitle;

  /// No description provided for @tradingPairQuoteAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tradingPairQuoteAll;

  /// No description provided for @tradingPairSectionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get tradingPairSectionRecent;

  /// No description provided for @tradingPairSectionFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tradingPairSectionFavorites;

  /// No description provided for @tradingPairSelectPairHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to search or choose a pair'**
  String get tradingPairSelectPairHint;

  /// No description provided for @tradingPairAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get tradingPairAddFavorite;

  /// No description provided for @tradingPairRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get tradingPairRemoveFavorite;

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

  /// No description provided for @fiatWithdrawBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to bank (USDT)'**
  String get fiatWithdrawBankTitle;

  /// No description provided for @fiatWithdrawBankSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link a Vietnamese bank account, then request withdrawal. Requires verified user role.'**
  String get fiatWithdrawBankSubtitle;

  /// No description provided for @fiatWithdrawToBankShort.
  ///
  /// In en, this message translates to:
  /// **'Bank withdraw'**
  String get fiatWithdrawToBankShort;

  /// No description provided for @fiatWithdrawBankCode.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get fiatWithdrawBankCode;

  /// No description provided for @fiatWithdrawAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get fiatWithdrawAccountNumber;

  /// No description provided for @fiatWithdrawHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get fiatWithdrawHolderName;

  /// No description provided for @fiatWithdrawSaveBank.
  ///
  /// In en, this message translates to:
  /// **'Submit bank for review'**
  String get fiatWithdrawSaveBank;

  /// No description provided for @fiatWithdrawMyBanks.
  ///
  /// In en, this message translates to:
  /// **'My bank accounts'**
  String get fiatWithdrawMyBanks;

  /// No description provided for @fiatWithdrawAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (USDT)'**
  String get fiatWithdrawAmount;

  /// No description provided for @fiatWithdrawSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit withdrawal'**
  String get fiatWithdrawSubmitRequest;

  /// No description provided for @fiatWithdrawMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get fiatWithdrawMyRequests;

  /// No description provided for @fiatWithdrawAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Fiat bank withdrawals'**
  String get fiatWithdrawAdminTitle;

  /// No description provided for @fiatWithdrawAdminBanks.
  ///
  /// In en, this message translates to:
  /// **'Bank accounts'**
  String get fiatWithdrawAdminBanks;

  /// No description provided for @fiatWithdrawAdminRequests.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal requests'**
  String get fiatWithdrawAdminRequests;

  /// No description provided for @fiatWithdrawVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get fiatWithdrawVerify;

  /// No description provided for @fiatWithdrawReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get fiatWithdrawReject;

  /// No description provided for @fiatWithdrawComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete transfer'**
  String get fiatWithdrawComplete;

  /// No description provided for @fiatWithdrawTransferRef.
  ///
  /// In en, this message translates to:
  /// **'Transfer reference'**
  String get fiatWithdrawTransferRef;

  /// No description provided for @drawerFiatWithdrawalAdmin.
  ///
  /// In en, this message translates to:
  /// **'Fiat bank (admin)'**
  String get drawerFiatWithdrawalAdmin;

  /// No description provided for @drawerFiatWithdrawalAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify bank accounts & approve USDT payouts'**
  String get drawerFiatWithdrawalAdminSubtitle;

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

  /// No description provided for @onchainDepositTransitioningMinutes.
  ///
  /// In en, this message translates to:
  /// **'Wallet addresses are updating (~{minutes} min left). The QR code will refresh automatically when done.'**
  String onchainDepositTransitioningMinutes(int minutes);

  /// No description provided for @onchainDepositTransitioningUnderOneMinute.
  ///
  /// In en, this message translates to:
  /// **'Wallet addresses are updating (under one minute left). The QR code will refresh automatically when done.'**
  String get onchainDepositTransitioningUnderOneMinute;

  /// No description provided for @onchainDepositTransitioningFinalize.
  ///
  /// In en, this message translates to:
  /// **'Wallet addresses are finishing activation. The QR code will refresh automatically when done.'**
  String get onchainDepositTransitioningFinalize;

  /// No description provided for @onchainDepositTransitioningUnknown.
  ///
  /// In en, this message translates to:
  /// **'Wallet addresses are updating. The QR code will refresh automatically when done.'**
  String get onchainDepositTransitioningUnknown;

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
  /// **'Amount must be positive'**
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

  /// No description provided for @profileEmailVerifiedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Email verified with OTP'**
  String get profileEmailVerifiedTooltip;

  /// No description provided for @profileEmailVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileEmailVerifiedLabel;

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

  /// No description provided for @contactEmailRequiredForOtpShort.
  ///
  /// In en, this message translates to:
  /// **'Add a real email in Profile → Security before using email OTP.'**
  String get contactEmailRequiredForOtpShort;

  /// No description provided for @contactEmailRequiredForOtpBody.
  ///
  /// In en, this message translates to:
  /// **'Wallet sign-in uses a placeholder address until you verify a real one. Open Change email, enter your address, tap Send code, then enter the OTP sent to that inbox.'**
  String get contactEmailRequiredForOtpBody;

  /// No description provided for @contactEmailGoToProfile.
  ///
  /// In en, this message translates to:
  /// **'Open Profile'**
  String get contactEmailGoToProfile;

  /// No description provided for @contactEmailVerifyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify contact email'**
  String get contactEmailVerifyDialogTitle;

  /// No description provided for @contactEmailVerifyDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your real email. We will send a 6-digit code there.'**
  String get contactEmailVerifyDialogSubtitle;

  /// No description provided for @contactEmailSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get contactEmailSendCode;

  /// No description provided for @contactEmailVerifySave.
  ///
  /// In en, this message translates to:
  /// **'Verify and save'**
  String get contactEmailVerifySave;

  /// No description provided for @contactEmailUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contact email updated.'**
  String get contactEmailUpdatedSuccess;

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

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without signing in'**
  String get continueAsGuest;

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

  /// No description provided for @dashboardBankProvidersHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank payout APIs'**
  String get dashboardBankProvidersHealthTitle;

  /// No description provided for @dashboardBankProvidersHealthAllOperational.
  ///
  /// In en, this message translates to:
  /// **'All providers operational'**
  String get dashboardBankProvidersHealthAllOperational;

  /// No description provided for @dashboardBankProvidersHealthDegraded.
  ///
  /// In en, this message translates to:
  /// **'Some providers unavailable'**
  String get dashboardBankProvidersHealthDegraded;

  /// No description provided for @dashboardBankProvidersHealthCouldNotCheck.
  ///
  /// In en, this message translates to:
  /// **'Health check failed'**
  String get dashboardBankProvidersHealthCouldNotCheck;

  /// No description provided for @dashboardBankProvidersHealthLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking providers…'**
  String get dashboardBankProvidersHealthLoading;

  /// No description provided for @dashboardBankProvidersHealthMs.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String dashboardBankProvidersHealthMs(int ms);

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

  /// No description provided for @registerWalletConnectQr.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect (QR)'**
  String get registerWalletConnectQr;

  /// No description provided for @registerUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String registerUnexpectedError(String error);

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
  /// **'User deposits & managed wallets'**
  String get treasuryTitle;

  /// No description provided for @treasuryManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default deposit addresses, priority chain, and company wallets for user-facing flows.'**
  String get treasuryManageSubtitle;

  /// No description provided for @treasuryToolbarTooltip.
  ///
  /// In en, this message translates to:
  /// **'User deposits & managed wallets — default addresses and priority chain'**
  String get treasuryToolbarTooltip;

  /// No description provided for @treasuryManagedScopeBanner.
  ///
  /// In en, this message translates to:
  /// **'This list is for deposit defaults and risk-managed wallets. Operational wallets: Payment configuration → Operational wallets.'**
  String get treasuryManagedScopeBanner;

  /// No description provided for @treasuryOpsScopeBanner.
  ///
  /// In en, this message translates to:
  /// **'Fund from main or sweep back to main. User deposit addresses: Deposits & managed wallets.'**
  String get treasuryOpsScopeBanner;

  /// No description provided for @paymentConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Configuration'**
  String get paymentConfigTitle;

  /// No description provided for @paymentConfigMethodsTab.
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get paymentConfigMethodsTab;

  /// No description provided for @paymentConfigTreasuryWalletsTab.
  ///
  /// In en, this message translates to:
  /// **'Operational wallets'**
  String get paymentConfigTreasuryWalletsTab;

  /// No description provided for @paymentConfigHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get paymentConfigHistoryTab;

  /// No description provided for @paymentConfigAddMethod.
  ///
  /// In en, this message translates to:
  /// **'Add method'**
  String get paymentConfigAddMethod;

  /// No description provided for @paymentConfigEditConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit configuration'**
  String get paymentConfigEditConfigTitle;

  /// No description provided for @paymentConfigEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No configurations yet.\nTap \"Add method\" to create one.'**
  String get paymentConfigEmptyMessage;

  /// No description provided for @paymentConfigActivateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate configuration'**
  String get paymentConfigActivateDialogTitle;

  /// No description provided for @paymentConfigActivateTarget.
  ///
  /// In en, this message translates to:
  /// **'Activate: {name}'**
  String paymentConfigActivateTarget(String name);

  /// No description provided for @paymentConfigActivateWarning.
  ///
  /// In en, this message translates to:
  /// **'The system will move to TRANSITIONING. Traders will see a warning banner during the grace period.'**
  String get paymentConfigActivateWarning;

  /// No description provided for @paymentConfigGracePeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Grace period (minutes)'**
  String get paymentConfigGracePeriodLabel;

  /// No description provided for @paymentConfigGracePeriodHelper.
  ///
  /// In en, this message translates to:
  /// **'Wait time before the new config becomes effective'**
  String get paymentConfigGracePeriodHelper;

  /// No description provided for @paymentConfigActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get paymentConfigActivateAction;

  /// No description provided for @paymentConfigActivationStartedMinutes.
  ///
  /// In en, this message translates to:
  /// **'Grace period of {minutes} minutes started'**
  String paymentConfigActivationStartedMinutes(int minutes);

  /// No description provided for @paymentConfigActivationAt.
  ///
  /// In en, this message translates to:
  /// **'Activates at: {time}'**
  String paymentConfigActivationAt(String time);

  /// No description provided for @paymentConfigActivateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to activate configuration'**
  String get paymentConfigActivateFailed;

  /// No description provided for @paymentConfigDeactivateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate configuration'**
  String get paymentConfigDeactivateDialogTitle;

  /// No description provided for @paymentConfigDeactivateDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate \"{name}\"?\nThis action takes effect immediately.'**
  String paymentConfigDeactivateDialogContent(String name);

  /// No description provided for @paymentConfigDeactivateAction.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get paymentConfigDeactivateAction;

  /// No description provided for @paymentConfigDeactivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get paymentConfigDeactivatedSuccess;

  /// No description provided for @paymentConfigTransitioningRemaining.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} minutes remaining before activation'**
  String paymentConfigTransitioningRemaining(int minutes);

  /// No description provided for @paymentConfigGraceUnderOneMinute.
  ///
  /// In en, this message translates to:
  /// **'Less than one minute remaining before activation'**
  String get paymentConfigGraceUnderOneMinute;

  /// No description provided for @paymentConfigGraceFinalizePending.
  ///
  /// In en, this message translates to:
  /// **'Grace period ended — finishing activation…'**
  String get paymentConfigGraceFinalizePending;

  /// No description provided for @paymentConfigGraceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Grace period in progress'**
  String get paymentConfigGraceUnknown;

  /// No description provided for @paymentConfigVersionAndSort.
  ///
  /// In en, this message translates to:
  /// **'Version: v{version} · Order: {sortOrder}'**
  String paymentConfigVersionAndSort(int version, int sortOrder);

  /// No description provided for @paymentConfigActivatedAt.
  ///
  /// In en, this message translates to:
  /// **'Activated: {datetime}'**
  String paymentConfigActivatedAt(String datetime);

  /// No description provided for @paymentConfigEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get paymentConfigEditAction;

  /// No description provided for @paymentConfigEditTypeLocked.
  ///
  /// In en, this message translates to:
  /// **'Type and network cannot be changed when editing.'**
  String get paymentConfigEditTypeLocked;

  /// No description provided for @paymentConfigDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load configuration for editing.'**
  String get paymentConfigDetailLoadFailed;

  /// No description provided for @paymentConfigStatusActiveUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get paymentConfigStatusActiveUpper;

  /// No description provided for @paymentConfigStatusTransitioningUpper.
  ///
  /// In en, this message translates to:
  /// **'TRANSITIONING'**
  String get paymentConfigStatusTransitioningUpper;

  /// No description provided for @paymentConfigStatusInactiveUpper.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get paymentConfigStatusInactiveUpper;

  /// No description provided for @paymentConfigMethodTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Method type'**
  String get paymentConfigMethodTypeLabel;

  /// No description provided for @paymentConfigNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get paymentConfigNetworkLabel;

  /// No description provided for @paymentConfigDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get paymentConfigDisplayNameLabel;

  /// No description provided for @paymentConfigDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: PayOS MB Bank'**
  String get paymentConfigDisplayNameHint;

  /// No description provided for @paymentConfigRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get paymentConfigRequired;

  /// No description provided for @paymentConfigGracePeriodEffectHelper.
  ///
  /// In en, this message translates to:
  /// **'Wait time after activation before taking effect'**
  String get paymentConfigGracePeriodEffectHelper;

  /// No description provided for @paymentConfigCredentialsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get paymentConfigCredentialsSectionTitle;

  /// No description provided for @paymentConfigHideAction.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get paymentConfigHideAction;

  /// No description provided for @paymentConfigShowAction.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get paymentConfigShowAction;

  /// No description provided for @paymentConfigMainnetWarning.
  ///
  /// In en, this message translates to:
  /// **'MAINNET - this configuration affects real funds. Review carefully before activation.'**
  String get paymentConfigMainnetWarning;

  /// No description provided for @paymentConfigMainnetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable if this is a mainnet network (real funds)'**
  String get paymentConfigMainnetSubtitle;

  /// No description provided for @paymentConfigRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate (1 VND -> X USDT)'**
  String get paymentConfigRateLabel;

  /// No description provided for @paymentConfigCreateConfigAction.
  ///
  /// In en, this message translates to:
  /// **'Create configuration'**
  String get paymentConfigCreateConfigAction;

  /// No description provided for @paymentConfigSaveChangesAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get paymentConfigSaveChangesAction;

  /// No description provided for @paymentConfigCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Configuration created'**
  String get paymentConfigCreatedSuccess;

  /// No description provided for @paymentConfigUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Configuration updated'**
  String get paymentConfigUpdatedSuccess;

  /// No description provided for @paymentConfigUnknownError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get paymentConfigUnknownError;

  /// No description provided for @paymentConfigMaskedHelper.
  ///
  /// In en, this message translates to:
  /// **'Hidden - tap \"Show\" to reveal'**
  String get paymentConfigMaskedHelper;

  /// No description provided for @paymentConfigRuntimeTab.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get paymentConfigRuntimeTab;

  /// No description provided for @paymentConfigRuntimeSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save runtime settings'**
  String get paymentConfigRuntimeSaveAll;

  /// No description provided for @paymentConfigRuntimeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load platform settings.'**
  String get paymentConfigRuntimeLoadFailed;

  /// No description provided for @paymentConfigRuntimeSaved.
  ///
  /// In en, this message translates to:
  /// **'Runtime settings saved.'**
  String get paymentConfigRuntimeSaved;

  /// No description provided for @paymentConfigRuntimeIntro.
  ///
  /// In en, this message translates to:
  /// **'These values apply without redeploying the API. Environment variables still act as defaults when a key is not stored in the database.'**
  String get paymentConfigRuntimeIntro;

  /// No description provided for @paymentConfigRuntimeSectionCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get paymentConfigRuntimeSectionCore;

  /// No description provided for @paymentConfigRuntimeSectionTech.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure & RPC'**
  String get paymentConfigRuntimeSectionTech;

  /// No description provided for @paymentConfigRuntimeSectionFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance & limits'**
  String get paymentConfigRuntimeSectionFinance;

  /// No description provided for @paymentConfigRuntimeSourceEnv.
  ///
  /// In en, this message translates to:
  /// **'Default (env)'**
  String get paymentConfigRuntimeSourceEnv;

  /// No description provided for @paymentConfigRuntimeSourceDb.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get paymentConfigRuntimeSourceDb;

  /// No description provided for @paymentConfigRuntimeTypeString.
  ///
  /// In en, this message translates to:
  /// **'string'**
  String get paymentConfigRuntimeTypeString;

  /// No description provided for @paymentConfigRuntimeTypeInteger.
  ///
  /// In en, this message translates to:
  /// **'integer'**
  String get paymentConfigRuntimeTypeInteger;

  /// No description provided for @paymentConfigRuntimeTypeBoolean.
  ///
  /// In en, this message translates to:
  /// **'boolean'**
  String get paymentConfigRuntimeTypeBoolean;

  /// No description provided for @paymentConfigRuntimeTypeFloat.
  ///
  /// In en, this message translates to:
  /// **'float'**
  String get paymentConfigRuntimeTypeFloat;

  /// No description provided for @runtimeSettingWalletSyncIntervalName.
  ///
  /// In en, this message translates to:
  /// **'Wallet sync interval (ms)'**
  String get runtimeSettingWalletSyncIntervalName;

  /// No description provided for @runtimeSettingWalletSyncIntervalDesc.
  ///
  /// In en, this message translates to:
  /// **'Interval for wallet sync workers (milliseconds).'**
  String get runtimeSettingWalletSyncIntervalDesc;

  /// No description provided for @runtimeSettingWalletReconciliationThresholdName.
  ///
  /// In en, this message translates to:
  /// **'Reconciliation discrepancy threshold'**
  String get runtimeSettingWalletReconciliationThresholdName;

  /// No description provided for @runtimeSettingWalletReconciliationThresholdDesc.
  ///
  /// In en, this message translates to:
  /// **'Absolute balance discrepancy treated as acceptable for reconciliation.'**
  String get runtimeSettingWalletReconciliationThresholdDesc;

  /// No description provided for @runtimeSettingTronNileFullHostName.
  ///
  /// In en, this message translates to:
  /// **'Tron Nile RPC URL'**
  String get runtimeSettingTronNileFullHostName;

  /// No description provided for @runtimeSettingTronNileFullHostDesc.
  ///
  /// In en, this message translates to:
  /// **'Full node HTTP API for TRON Nile testnet.'**
  String get runtimeSettingTronNileFullHostDesc;

  /// No description provided for @runtimeSettingTronShastaFullHostName.
  ///
  /// In en, this message translates to:
  /// **'Tron Shasta RPC URL'**
  String get runtimeSettingTronShastaFullHostName;

  /// No description provided for @runtimeSettingTronShastaFullHostDesc.
  ///
  /// In en, this message translates to:
  /// **'Full node HTTP API for TRON Shasta testnet.'**
  String get runtimeSettingTronShastaFullHostDesc;

  /// No description provided for @runtimeSettingTronDefaultNetworkName.
  ///
  /// In en, this message translates to:
  /// **'Default Tron network'**
  String get runtimeSettingTronDefaultNetworkName;

  /// No description provided for @runtimeSettingTronDefaultNetworkDesc.
  ///
  /// In en, this message translates to:
  /// **'TRON_NILE or TRON_SHASTA. Changing may require API restart for some processes.'**
  String get runtimeSettingTronDefaultNetworkDesc;

  /// No description provided for @runtimeSettingSolanaDevnetUrlName.
  ///
  /// In en, this message translates to:
  /// **'Solana Devnet RPC URL'**
  String get runtimeSettingSolanaDevnetUrlName;

  /// No description provided for @runtimeSettingSolanaDevnetUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'JSON RPC endpoint for Solana devnet.'**
  String get runtimeSettingSolanaDevnetUrlDesc;

  /// No description provided for @runtimeSettingEthSepoliaRpcUrlName.
  ///
  /// In en, this message translates to:
  /// **'Ethereum Sepolia RPC URL'**
  String get runtimeSettingEthSepoliaRpcUrlName;

  /// No description provided for @runtimeSettingEthSepoliaRpcUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'JSON-RPC URL for Sepolia testnet.'**
  String get runtimeSettingEthSepoliaRpcUrlDesc;

  /// No description provided for @runtimeSettingEthSepoliaChainIdName.
  ///
  /// In en, this message translates to:
  /// **'Ethereum Sepolia chain ID'**
  String get runtimeSettingEthSepoliaChainIdName;

  /// No description provided for @runtimeSettingEthSepoliaChainIdDesc.
  ///
  /// In en, this message translates to:
  /// **'EIP-155 chain ID for Sepolia (e.g. 11155111).'**
  String get runtimeSettingEthSepoliaChainIdDesc;

  /// No description provided for @runtimeSettingBlockchainAllowTestSignatureName.
  ///
  /// In en, this message translates to:
  /// **'Allow test signature bypass'**
  String get runtimeSettingBlockchainAllowTestSignatureName;

  /// No description provided for @runtimeSettingBlockchainAllowTestSignatureDesc.
  ///
  /// In en, this message translates to:
  /// **'When true (non-production rules apply), linking may accept TEST_SIG:: payloads. Editing from UI is blocked in production unless ALLOW_UI_TEST_SIGNATURE=true.'**
  String get runtimeSettingBlockchainAllowTestSignatureDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxName.
  ///
  /// In en, this message translates to:
  /// **'Global auto-approve withdraw max (native)'**
  String get runtimeSettingBlockchainWithdrawAutoMaxName;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxDesc.
  ///
  /// In en, this message translates to:
  /// **'Default max native amount for auto-processed withdrawals.'**
  String get runtimeSettingBlockchainWithdrawAutoMaxDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxEthSepoliaName.
  ///
  /// In en, this message translates to:
  /// **'Auto max withdraw — ETH Sepolia'**
  String get runtimeSettingBlockchainWithdrawAutoMaxEthSepoliaName;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxEthSepoliaDesc.
  ///
  /// In en, this message translates to:
  /// **'Per-chain cap for ETH_SEPOLIA; falls back to global when empty.'**
  String get runtimeSettingBlockchainWithdrawAutoMaxEthSepoliaDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetName.
  ///
  /// In en, this message translates to:
  /// **'Auto max withdraw — Solana devnet'**
  String get runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetName;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetDesc.
  ///
  /// In en, this message translates to:
  /// **'Per-chain cap for SOLANA_DEVNET; falls back to global when empty.'**
  String get runtimeSettingBlockchainWithdrawAutoMaxSolanaDevnetDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxTronNileName.
  ///
  /// In en, this message translates to:
  /// **'Auto max withdraw — Tron Nile'**
  String get runtimeSettingBlockchainWithdrawAutoMaxTronNileName;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxTronNileDesc.
  ///
  /// In en, this message translates to:
  /// **'Per-chain cap for TRON_NILE; falls back to global when empty.'**
  String get runtimeSettingBlockchainWithdrawAutoMaxTronNileDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxTronShastaName.
  ///
  /// In en, this message translates to:
  /// **'Auto max withdraw — Tron Shasta'**
  String get runtimeSettingBlockchainWithdrawAutoMaxTronShastaName;

  /// No description provided for @runtimeSettingBlockchainWithdrawAutoMaxTronShastaDesc.
  ///
  /// In en, this message translates to:
  /// **'Per-chain cap for TRON_SHASTA; falls back to global when empty.'**
  String get runtimeSettingBlockchainWithdrawAutoMaxTronShastaDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawEthSymbolName.
  ///
  /// In en, this message translates to:
  /// **'Withdraw symbol — Ethereum'**
  String get runtimeSettingBlockchainWithdrawEthSymbolName;

  /// No description provided for @runtimeSettingBlockchainWithdrawEthSymbolDesc.
  ///
  /// In en, this message translates to:
  /// **'Currency symbol used for ETH-family chains (must exist in DB).'**
  String get runtimeSettingBlockchainWithdrawEthSymbolDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawSolSymbolName.
  ///
  /// In en, this message translates to:
  /// **'Withdraw symbol — Solana'**
  String get runtimeSettingBlockchainWithdrawSolSymbolName;

  /// No description provided for @runtimeSettingBlockchainWithdrawSolSymbolDesc.
  ///
  /// In en, this message translates to:
  /// **'Currency symbol used for Solana devnet withdrawals.'**
  String get runtimeSettingBlockchainWithdrawSolSymbolDesc;

  /// No description provided for @runtimeSettingBlockchainWithdrawTronSymbolName.
  ///
  /// In en, this message translates to:
  /// **'Withdraw symbol — Tron'**
  String get runtimeSettingBlockchainWithdrawTronSymbolName;

  /// No description provided for @runtimeSettingBlockchainWithdrawTronSymbolDesc.
  ///
  /// In en, this message translates to:
  /// **'Currency symbol used for Tron withdrawals (e.g. TRX).'**
  String get runtimeSettingBlockchainWithdrawTronSymbolDesc;

  /// No description provided for @runtimeSettingPlatformCashCurrencySymbolName.
  ///
  /// In en, this message translates to:
  /// **'Platform cash symbol'**
  String get runtimeSettingPlatformCashCurrencySymbolName;

  /// No description provided for @runtimeSettingPlatformCashCurrencySymbolDesc.
  ///
  /// In en, this message translates to:
  /// **'Internal ledger symbol for cash leg of deposits (typically USDT).'**
  String get runtimeSettingPlatformCashCurrencySymbolDesc;

  /// No description provided for @runtimeSettingBlockchainDepositTrxToUsdtRateName.
  ///
  /// In en, this message translates to:
  /// **'Fallback rate TRX → USDT'**
  String get runtimeSettingBlockchainDepositTrxToUsdtRateName;

  /// No description provided for @runtimeSettingBlockchainDepositTrxToUsdtRateDesc.
  ///
  /// In en, this message translates to:
  /// **'Used when price oracle unavailable; 1 TRX = X USDT.'**
  String get runtimeSettingBlockchainDepositTrxToUsdtRateDesc;

  /// No description provided for @runtimeSettingBlockchainDepositEthToUsdtRateName.
  ///
  /// In en, this message translates to:
  /// **'Fallback rate ETH → USDT'**
  String get runtimeSettingBlockchainDepositEthToUsdtRateName;

  /// No description provided for @runtimeSettingBlockchainDepositEthToUsdtRateDesc.
  ///
  /// In en, this message translates to:
  /// **'Used when price oracle unavailable.'**
  String get runtimeSettingBlockchainDepositEthToUsdtRateDesc;

  /// No description provided for @runtimeSettingBlockchainDepositSolToUsdtRateName.
  ///
  /// In en, this message translates to:
  /// **'Fallback rate SOL → USDT'**
  String get runtimeSettingBlockchainDepositSolToUsdtRateName;

  /// No description provided for @runtimeSettingBlockchainDepositSolToUsdtRateDesc.
  ///
  /// In en, this message translates to:
  /// **'Used when price oracle unavailable.'**
  String get runtimeSettingBlockchainDepositSolToUsdtRateDesc;

  /// No description provided for @treasuryCreateWalletFab.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get treasuryCreateWalletFab;

  /// No description provided for @treasuryCreateWalletDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create transaction wallet'**
  String get treasuryCreateWalletDialogTitle;

  /// No description provided for @treasuryCreateWalletCta.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get treasuryCreateWalletCta;

  /// No description provided for @treasuryChainLabel.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get treasuryChainLabel;

  /// No description provided for @treasuryPurposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get treasuryPurposeLabel;

  /// No description provided for @treasuryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get treasuryTypeLabel;

  /// No description provided for @treasuryLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get treasuryLabelOptional;

  /// No description provided for @treasuryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get treasuryFilterAll;

  /// No description provided for @treasuryNoWalletsYet.
  ///
  /// In en, this message translates to:
  /// **'No transaction wallets yet. Tap \"Create wallet\" to start.'**
  String get treasuryNoWalletsYet;

  /// No description provided for @treasuryOpsGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get treasuryOpsGuideTitle;

  /// No description provided for @treasuryOpsGuideSummary.
  ///
  /// In en, this message translates to:
  /// **'Sweep: move funds to the main wallet. Fund: send from main to this wallet.'**
  String get treasuryOpsGuideSummary;

  /// No description provided for @treasuryOpsPublicAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Public address'**
  String get treasuryOpsPublicAddressLabel;

  /// No description provided for @treasuryOpsAddressCopiedSnack.
  ///
  /// In en, this message translates to:
  /// **'Public address copied to clipboard.'**
  String get treasuryOpsAddressCopiedSnack;

  /// No description provided for @treasuryStatusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get treasuryStatusActive;

  /// No description provided for @treasuryStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get treasuryStatusInactive;

  /// No description provided for @treasuryBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get treasuryBalanceLabel;

  /// No description provided for @treasurySweepAction.
  ///
  /// In en, this message translates to:
  /// **'Sweep to main'**
  String get treasurySweepAction;

  /// No description provided for @treasurySweepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sweep funds from this wallet to the main wallet'**
  String get treasurySweepTooltip;

  /// No description provided for @treasurySweepDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sweep to main wallet'**
  String get treasurySweepDialogTitle;

  /// No description provided for @treasurySweepTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Sweep to'**
  String get treasurySweepTargetLabel;

  /// No description provided for @treasuryFundAction.
  ///
  /// In en, this message translates to:
  /// **'Fund wallet'**
  String get treasuryFundAction;

  /// No description provided for @treasuryFundTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fund this wallet from the main wallet'**
  String get treasuryFundTooltip;

  /// No description provided for @treasurySweepQueued.
  ///
  /// In en, this message translates to:
  /// **'Sweep request received. This card\'s balance will update when the on-chain transfer completes.'**
  String get treasurySweepQueued;

  /// No description provided for @treasurySweepFailed.
  ///
  /// In en, this message translates to:
  /// **'Sweep failed'**
  String get treasurySweepFailed;

  /// No description provided for @treasuryFundDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund from main wallet'**
  String get treasuryFundDialogTitle;

  /// No description provided for @treasuryAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get treasuryAmountLabel;

  /// No description provided for @treasuryAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 0.5'**
  String get treasuryAmountHint;

  /// No description provided for @treasuryCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get treasuryCancelAction;

  /// No description provided for @treasuryConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get treasuryConfirmAction;

  /// No description provided for @treasuryFundQueued.
  ///
  /// In en, this message translates to:
  /// **'Fund request received. This card\'s balance will update when the on-chain transfer completes.'**
  String get treasuryFundQueued;

  /// No description provided for @treasuryWalletPendingOnChainBadge.
  ///
  /// In en, this message translates to:
  /// **'Processing on-chain…'**
  String get treasuryWalletPendingOnChainBadge;

  /// No description provided for @treasuryQueuedBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Balance shown is unchanged until the chain confirms.'**
  String get treasuryQueuedBalanceHint;

  /// No description provided for @treasuryPendingOnChainTooltipGeneric.
  ///
  /// In en, this message translates to:
  /// **'A Fund or Sweep is processing on-chain. The balance on this card has not updated yet.'**
  String get treasuryPendingOnChainTooltipGeneric;

  /// No description provided for @treasuryPendingOnChainTooltipWithId.
  ///
  /// In en, this message translates to:
  /// **'Operation {operationId} is pending on-chain. The balance will not reflect new funds until it completes.'**
  String treasuryPendingOnChainTooltipWithId(String operationId);

  /// No description provided for @treasuryFundFailed.
  ///
  /// In en, this message translates to:
  /// **'Fund failed'**
  String get treasuryFundFailed;

  /// No description provided for @treasuryOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasury operations'**
  String get treasuryOperationsTitle;

  /// No description provided for @treasuryNoOperations.
  ///
  /// In en, this message translates to:
  /// **'No operations yet'**
  String get treasuryNoOperations;

  /// No description provided for @treasuryTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'On-chain transactions'**
  String get treasuryTransactionsTitle;

  /// No description provided for @treasuryNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get treasuryNoTransactions;

  /// No description provided for @treasurySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Tx hash, operation id, address…'**
  String get treasurySearchHint;

  /// No description provided for @treasuryHistorySearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get treasuryHistorySearchLabel;

  /// No description provided for @treasuryHistoryIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get treasuryHistoryIdLabel;

  /// No description provided for @treasuryHistoryTxHash.
  ///
  /// In en, this message translates to:
  /// **'Tx hash'**
  String get treasuryHistoryTxHash;

  /// No description provided for @treasuryHistoryFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get treasuryHistoryFrom;

  /// No description provided for @treasuryHistoryTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get treasuryHistoryTo;

  /// No description provided for @treasuryHistoryTypeFund.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get treasuryHistoryTypeFund;

  /// No description provided for @treasuryHistoryTypeSweep.
  ///
  /// In en, this message translates to:
  /// **'Sweep'**
  String get treasuryHistoryTypeSweep;

  /// No description provided for @treasuryHistoryStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get treasuryHistoryStatusPending;

  /// No description provided for @treasuryHistoryStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get treasuryHistoryStatusProcessing;

  /// No description provided for @treasuryHistoryStatusConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming'**
  String get treasuryHistoryStatusConfirming;

  /// No description provided for @treasuryHistoryStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get treasuryHistoryStatusCompleted;

  /// No description provided for @treasuryHistoryStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get treasuryHistoryStatusFailed;

  /// No description provided for @treasuryHistoryLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get treasuryHistoryLoadMore;

  /// No description provided for @apiErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get apiErrorGeneric;

  /// No description provided for @apiErrorTxWalletNonZeroBalance.
  ///
  /// In en, this message translates to:
  /// **'Sweep funds first (on-chain balance must be at most {maxAmount} {symbol})'**
  String apiErrorTxWalletNonZeroBalance(String maxAmount, String symbol);

  /// No description provided for @apiErrorTxWalletNonZeroBalanceShort.
  ///
  /// In en, this message translates to:
  /// **'Sweep funds first — reduce on-chain balance before deleting this wallet.'**
  String get apiErrorTxWalletNonZeroBalanceShort;

  /// No description provided for @apiErrorTxWalletUsdtNonZero.
  ///
  /// In en, this message translates to:
  /// **'Move TRC-20 USDT off this wallet before deleting it.'**
  String get apiErrorTxWalletUsdtNonZero;

  /// No description provided for @apiErrorTxWalletDefaultDepositDelete.
  ///
  /// In en, this message translates to:
  /// **'Unset this wallet as the user deposit default before deleting it.'**
  String get apiErrorTxWalletDefaultDepositDelete;

  /// No description provided for @apiErrorTxWalletOperationInFlight.
  ///
  /// In en, this message translates to:
  /// **'Wait for pending Fund or Sweep operations to finish before deleting this wallet.'**
  String get apiErrorTxWalletOperationInFlight;

  /// No description provided for @apiErrorTxWalletExists.
  ///
  /// In en, this message translates to:
  /// **'A transaction wallet with this chain and purpose already exists.'**
  String get apiErrorTxWalletExists;

  /// No description provided for @apiErrorTreasuryWalletInactive.
  ///
  /// In en, this message translates to:
  /// **'This transaction wallet is inactive.'**
  String get apiErrorTreasuryWalletInactive;

  /// No description provided for @apiErrorTreasuryWalletLocked.
  ///
  /// In en, this message translates to:
  /// **'Another treasury operation is running on this wallet. Try again shortly.'**
  String get apiErrorTreasuryWalletLocked;

  /// No description provided for @apiErrorDefaultUserDepositDeactivate.
  ///
  /// In en, this message translates to:
  /// **'You cannot deactivate the current default user deposit wallet.'**
  String get apiErrorDefaultUserDepositDeactivate;

  /// No description provided for @treasuryWalletCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction wallet created'**
  String get treasuryWalletCreatedSuccess;

  /// No description provided for @treasuryOpsDeleteWalletTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction wallet'**
  String get treasuryOpsDeleteWalletTooltip;

  /// No description provided for @treasuryOpsDeleteWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction wallet?'**
  String get treasuryOpsDeleteWalletTitle;

  /// No description provided for @treasuryOpsDeleteWalletBody.
  ///
  /// In en, this message translates to:
  /// **'Removes this Fund/Sweep wallet from the system. You must sweep funds first (near-zero balance), finish any pending Fund/Sweep, and unset it as the user deposit default if applicable.'**
  String get treasuryOpsDeleteWalletBody;

  /// No description provided for @treasuryOpsDeleteWalletSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Transaction wallet deleted.'**
  String get treasuryOpsDeleteWalletSuccessSnack;

  /// No description provided for @treasuryOpsDeleteWalletAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get treasuryOpsDeleteWalletAction;

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
  /// **'Create Tron operational wallets under Payment configuration → Treasury (purpose DEPOSIT or BOTH), then pick the default deposit address per chain here.'**
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

  /// No description provided for @managedWalletClearDefaultDeposit.
  ///
  /// In en, this message translates to:
  /// **'Remove default'**
  String get managedWalletClearDefaultDeposit;

  /// No description provided for @managedWalletClearDefaultDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove default deposit?'**
  String get managedWalletClearDefaultDepositTitle;

  /// No description provided for @managedWalletClearDefaultDepositBody.
  ///
  /// In en, this message translates to:
  /// **'This chain will have no default deposit address until you set another wallet. On-chain deposits for this network stay disabled until then.'**
  String get managedWalletClearDefaultDepositBody;

  /// No description provided for @managedWalletClearDefaultDepositAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get managedWalletClearDefaultDepositAction;

  /// No description provided for @managedWalletClearDefaultDepositSuccess.
  ///
  /// In en, this message translates to:
  /// **'Default deposit address removed.'**
  String get managedWalletClearDefaultDepositSuccess;

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

  /// No description provided for @depositMethodUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Deposit not available'**
  String get depositMethodUnavailable;

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

  /// No description provided for @adminCurrenciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin - Currencies'**
  String get adminCurrenciesTitle;

  /// No description provided for @adminCurrenciesCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new coin'**
  String get adminCurrenciesCreateTitle;

  /// No description provided for @adminCurrenciesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete coin'**
  String get adminCurrenciesDeleteTitle;

  /// No description provided for @adminCurrenciesDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this coin?'**
  String get adminCurrenciesDeleteConfirmMessage;

  /// No description provided for @adminCurrenciesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {symbol}'**
  String adminCurrenciesEditTitle(String symbol);

  /// No description provided for @adminCurrenciesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminCurrenciesEdit;

  /// No description provided for @adminCurrenciesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminCurrenciesCancel;

  /// No description provided for @adminCurrenciesCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get adminCurrenciesCreateAction;

  /// No description provided for @adminCurrenciesSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminCurrenciesSaveAction;

  /// No description provided for @adminCurrenciesDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminCurrenciesDeleteAction;

  /// No description provided for @adminCurrenciesHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get adminCurrenciesHide;

  /// No description provided for @adminCurrenciesShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get adminCurrenciesShow;

  /// No description provided for @adminCurrenciesTradableLabel.
  ///
  /// In en, this message translates to:
  /// **'Tradable'**
  String get adminCurrenciesTradableLabel;

  /// No description provided for @adminCurrenciesActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminCurrenciesActiveLabel;

  /// No description provided for @adminCurrenciesStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminCurrenciesStatusLabel;

  /// No description provided for @adminCurrenciesNameInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminCurrenciesNameInputLabel;

  /// No description provided for @adminCurrenciesPrecisionScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Precision Scale'**
  String get adminCurrenciesPrecisionScaleLabel;

  /// No description provided for @adminCurrenciesMinWithdrawLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Withdraw'**
  String get adminCurrenciesMinWithdrawLabel;

  /// No description provided for @adminCurrenciesFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get adminCurrenciesFieldRequired;

  /// No description provided for @adminCurrenciesRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get adminCurrenciesRetryAction;

  /// No description provided for @adminCurrenciesCreateNewCoin.
  ///
  /// In en, this message translates to:
  /// **'Create new coin'**
  String get adminCurrenciesCreateNewCoin;

  /// No description provided for @adminCurrenciesNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get adminCurrenciesNoData;

  /// No description provided for @adminCurrenciesSymbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get adminCurrenciesSymbolLabel;

  /// No description provided for @adminCurrenciesCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Coin created successfully!'**
  String get adminCurrenciesCreateSuccess;

  /// No description provided for @adminCurrenciesUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Coin updated successfully!'**
  String get adminCurrenciesUpdateSuccess;

  /// No description provided for @adminCurrenciesDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Coin deleted successfully!'**
  String get adminCurrenciesDeleteSuccess;

  /// No description provided for @depositDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get depositDetailStatus;

  /// No description provided for @depositDetailOrderCode.
  ///
  /// In en, this message translates to:
  /// **'Order Code'**
  String get depositDetailOrderCode;

  /// No description provided for @depositDetailCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get depositDetailCopied;

  /// No description provided for @depositDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get depositDetailCreatedAt;

  /// No description provided for @depositDetailUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at'**
  String get depositDetailUpdatedAt;

  /// No description provided for @depositDetailUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get depositDetailUserId;

  /// No description provided for @depositDetailViewUser.
  ///
  /// In en, this message translates to:
  /// **'View user'**
  String get depositDetailViewUser;

  /// No description provided for @depositStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get depositStatusPaid;

  /// No description provided for @depositStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get depositStatusPending;

  /// No description provided for @depositStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get depositStatusCancelled;

  /// No description provided for @withdrawalDetailInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Information'**
  String get withdrawalDetailInfoTitle;

  /// No description provided for @withdrawalDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get withdrawalDetailAmount;

  /// No description provided for @withdrawalDetailChain.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get withdrawalDetailChain;

  /// No description provided for @withdrawalDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get withdrawalDetailStatus;

  /// No description provided for @withdrawalDetailCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get withdrawalDetailCopied;

  /// No description provided for @withdrawalDetailAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get withdrawalDetailAddress;

  /// No description provided for @withdrawalDetailTxHash.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash'**
  String get withdrawalDetailTxHash;

  /// No description provided for @withdrawalDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get withdrawalDetailCreatedAt;

  /// No description provided for @withdrawalDetailUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at'**
  String get withdrawalDetailUpdatedAt;

  /// No description provided for @withdrawalDetailUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get withdrawalDetailUserId;

  /// No description provided for @withdrawalDetailViewUser.
  ///
  /// In en, this message translates to:
  /// **'View user'**
  String get withdrawalDetailViewUser;

  /// No description provided for @withdrawalStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get withdrawalStatusCompleted;

  /// No description provided for @withdrawalStatusConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming'**
  String get withdrawalStatusConfirming;

  /// No description provided for @withdrawalStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get withdrawalStatusPending;

  /// No description provided for @withdrawalStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get withdrawalStatusFailed;

  /// No description provided for @withdrawalDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Details'**
  String get withdrawalDetailTitle;

  /// No description provided for @withdrawalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal not found'**
  String get withdrawalNotFound;

  /// No description provided for @withdrawalApprovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal approved'**
  String get withdrawalApprovedSnack;

  /// No description provided for @withdrawalApproveButton.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get withdrawalApproveButton;

  /// No description provided for @withdrawalRejectButton.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get withdrawalRejectButton;

  /// No description provided for @withdrawalRejectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject withdrawal'**
  String get withdrawalRejectDialogTitle;

  /// No description provided for @withdrawalRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get withdrawalRejectReasonHint;

  /// No description provided for @withdrawalRejectedSnack.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal rejected'**
  String get withdrawalRejectedSnack;

  /// No description provided for @withdrawalUserInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get withdrawalUserInfoTitle;

  /// No description provided for @withdrawalBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get withdrawalBalanceLabel;

  /// No description provided for @withdrawalTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Information'**
  String get withdrawalTransactionTitle;

  /// No description provided for @withdrawalNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get withdrawalNetworkLabel;

  /// No description provided for @withdrawalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get withdrawalAmountLabel;

  /// No description provided for @withdrawalDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get withdrawalDestinationLabel;

  /// No description provided for @withdrawalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get withdrawalTimeLabel;

  /// No description provided for @withdrawalTxHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Tx Hash'**
  String get withdrawalTxHashLabel;

  /// No description provided for @withdrawalStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get withdrawalStatusRequested;

  /// No description provided for @withdrawalStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get withdrawalStatusApproved;

  /// No description provided for @withdrawalStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get withdrawalStatusSent;

  /// No description provided for @withdrawalStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get withdrawalStatusLabel;

  /// No description provided for @withdrawalStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get withdrawalStatusRejected;

  /// No description provided for @adminCurrenciesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search currencies...'**
  String get adminCurrenciesSearchHint;

  /// No description provided for @adminCurrenciesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminCurrenciesFilterAll;

  /// No description provided for @adminCurrenciesFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminCurrenciesFilterActive;

  /// No description provided for @adminCurrenciesFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get adminCurrenciesFilterInactive;

  /// No description provided for @adminCurrenciesTradingLabel.
  ///
  /// In en, this message translates to:
  /// **'Trading'**
  String get adminCurrenciesTradingLabel;

  /// No description provided for @adminCurrenciesFilterTradable.
  ///
  /// In en, this message translates to:
  /// **'Tradable'**
  String get adminCurrenciesFilterTradable;

  /// No description provided for @adminCurrenciesFilterPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get adminCurrenciesFilterPaused;

  /// No description provided for @adminCurrenciesNoCoinsFound.
  ///
  /// In en, this message translates to:
  /// **'No coins found'**
  String get adminCurrenciesNoCoinsFound;

  /// No description provided for @adminCurrenciesCreateCoin.
  ///
  /// In en, this message translates to:
  /// **'Create coin'**
  String get adminCurrenciesCreateCoin;

  /// No description provided for @adminCurrenciesDeleteConfirmWithPair.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{symbol} — {name}\"?\nThis action cannot be undone.'**
  String adminCurrenciesDeleteConfirmWithPair(String symbol, String name);

  /// No description provided for @adminCurrenciesListMeta.
  ///
  /// In en, this message translates to:
  /// **'Precision: {precision} · Min withdraw: {minWithdraw}'**
  String adminCurrenciesListMeta(String precision, String minWithdraw);

  /// No description provided for @adminCurrenciesTradableBadgeOn.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get adminCurrenciesTradableBadgeOn;

  /// No description provided for @adminCurrenciesTradableBadgeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get adminCurrenciesTradableBadgeOff;

  /// No description provided for @adminCurrenciesTradingPausedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Trading paused'**
  String get adminCurrenciesTradingPausedTooltip;

  /// No description provided for @adminShowingCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} {label}'**
  String adminShowingCount(int shown, int total, String label);

  /// No description provided for @adminRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminRetryButton;

  /// No description provided for @payosTransitioningBanner.
  ///
  /// In en, this message translates to:
  /// **'PayOS payment method will be activated in {minutes} minute(s)'**
  String payosTransitioningBanner(int minutes);

  /// No description provided for @payosTransitioningGraceMinutes.
  ///
  /// In en, this message translates to:
  /// **'Activation in {minutes} minute(s)'**
  String payosTransitioningGraceMinutes(int minutes);

  /// No description provided for @payosTransitioningUnderOneMinute.
  ///
  /// In en, this message translates to:
  /// **'PayOS will be activated in less than a minute'**
  String get payosTransitioningUnderOneMinute;

  /// No description provided for @payosTransitioningFinalizePending.
  ///
  /// In en, this message translates to:
  /// **'PayOS activation is finishing — please wait'**
  String get payosTransitioningFinalizePending;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @snackbarOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get snackbarOk;

  /// No description provided for @adminUserDetailTabWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get adminUserDetailTabWallets;

  /// No description provided for @adminUserDetailTabAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get adminUserDetailTabAdjust;

  /// No description provided for @adminUserDetailTabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminUserDetailTabOrders;

  /// No description provided for @adminUserDetailTabOnchain.
  ///
  /// In en, this message translates to:
  /// **'On-chain'**
  String get adminUserDetailTabOnchain;

  /// No description provided for @adminUserDetailTabSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get adminUserDetailTabSecurity;

  /// No description provided for @adminUserDetailCreatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get adminUserDetailCreatedAtLabel;

  /// No description provided for @withdrawalManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Management'**
  String get withdrawalManagementTitle;

  /// No description provided for @withdrawalManagementTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get withdrawalManagementTabPending;

  /// No description provided for @withdrawalManagementTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get withdrawalManagementTabAll;

  /// No description provided for @withdrawalApproveAllSmallTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve All'**
  String get withdrawalApproveAllSmallTitle;

  /// No description provided for @withdrawalApproveAllSmallContent.
  ///
  /// In en, this message translates to:
  /// **'Approve all pending withdrawals?'**
  String get withdrawalApproveAllSmallContent;

  /// No description provided for @withdrawalApproveAllProcess.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get withdrawalApproveAllProcess;

  /// No description provided for @withdrawalProcessedSnack.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals processed successfully'**
  String get withdrawalProcessedSnack;

  /// No description provided for @withdrawalStatsPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String withdrawalStatsPendingCount(int count);

  /// No description provided for @adminFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAll;

  /// No description provided for @withdrawalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by user ID or wallet address...'**
  String get withdrawalSearchHint;

  /// No description provided for @withdrawalNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No withdrawal requests'**
  String get withdrawalNoRequests;

  /// No description provided for @drawerTransactionMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Transaction Monitoring'**
  String get drawerTransactionMonitoring;

  /// No description provided for @adminTabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminTabOrders;

  /// No description provided for @adminTabDeposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get adminTabDeposits;

  /// No description provided for @adminTabWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get adminTabWithdrawals;

  /// No description provided for @orderStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get orderStatusOpen;

  /// No description provided for @orderStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partially Filled'**
  String get orderStatusPartial;

  /// No description provided for @orderStatusFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get orderStatusFilled;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get orderStatusRejected;

  /// No description provided for @filterByUserId.
  ///
  /// In en, this message translates to:
  /// **'Filter by User ID'**
  String get filterByUserId;

  /// No description provided for @adminPairIdFilterHint.
  ///
  /// In en, this message translates to:
  /// **'pair_id (UUID) or symbol e.g. OG/USDT — filter & reconcile'**
  String get adminPairIdFilterHint;

  /// No description provided for @adminReconcileMatchingButton.
  ///
  /// In en, this message translates to:
  /// **'Re-run matching'**
  String get adminReconcileMatchingButton;

  /// No description provided for @adminReconcileMatchingPairRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter pair_id (UUID) or symbol BASE/QUOTE.'**
  String get adminReconcileMatchingPairRequired;

  /// No description provided for @adminOrderPairIdLabel.
  ///
  /// In en, this message translates to:
  /// **'pair_id'**
  String get adminOrderPairIdLabel;

  /// No description provided for @adminOrderPairIdCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy pair_id for reconcile field'**
  String get adminOrderPairIdCopyTooltip;

  /// No description provided for @adminOrderPairIdCopied.
  ///
  /// In en, this message translates to:
  /// **'pair_id copied'**
  String get adminOrderPairIdCopied;

  /// No description provided for @adminReconcileMatchingConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-run order matching?'**
  String get adminReconcileMatchingConfirmTitle;

  /// No description provided for @adminReconcileMatchingConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Retry matching for all open orders on this pair: {pairId}'**
  String adminReconcileMatchingConfirmMessage(String pairId);

  /// No description provided for @adminReconcileMatchingRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get adminReconcileMatchingRun;

  /// No description provided for @adminReconcileMatchingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminReconcileMatchingCancel;

  /// No description provided for @adminReconcileMatchingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reconcile done. Trades: {trades}, still open: {open}, outcome: {reason}'**
  String adminReconcileMatchingSuccess(int trades, int open, String reason);

  /// No description provided for @adminReconcileReasonAllMatched.
  ///
  /// In en, this message translates to:
  /// **'all matched'**
  String get adminReconcileReasonAllMatched;

  /// No description provided for @adminReconcileReasonNoProgress.
  ///
  /// In en, this message translates to:
  /// **'no further matches'**
  String get adminReconcileReasonNoProgress;

  /// No description provided for @adminReconcileReasonMaxRounds.
  ///
  /// In en, this message translates to:
  /// **'stopped (safety limit)'**
  String get adminReconcileReasonMaxRounds;

  /// No description provided for @adminOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get adminOrdersEmpty;

  /// No description provided for @adminOrdersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String adminOrdersCountLabel(int count);

  /// No description provided for @adminDepositsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No deposits'**
  String get adminDepositsEmpty;

  /// No description provided for @adminDepositsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} deposits'**
  String adminDepositsCountLabel(int count);

  /// No description provided for @adminWithdrawalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No withdrawals'**
  String get adminWithdrawalsEmpty;

  /// No description provided for @adminWithdrawalsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} withdrawals'**
  String adminWithdrawalsCountLabel(int count);

  /// No description provided for @orderDetailTypeLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get orderDetailTypeLimitLabel;

  /// No description provided for @orderDetailTypeMarketLabel.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get orderDetailTypeMarketLabel;

  /// No description provided for @adminOrderListBuyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy Price'**
  String get adminOrderListBuyPriceLabel;

  /// No description provided for @adminOrderListSellPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Sell Price'**
  String get adminOrderListSellPriceLabel;

  /// No description provided for @adminOrderListMarketPriceHint.
  ///
  /// In en, this message translates to:
  /// **'(Market Order)'**
  String get adminOrderListMarketPriceHint;

  /// No description provided for @adminUserLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminUserLabel;

  /// No description provided for @orderDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get orderDetailAmount;

  /// No description provided for @orderDetailPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get orderDetailPrice;

  /// No description provided for @adminOrderCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Code'**
  String get adminOrderCodeLabel;

  /// No description provided for @adminTxHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Tx Hash'**
  String get adminTxHashLabel;

  /// No description provided for @orderDetailSideBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get orderDetailSideBuy;

  /// No description provided for @orderDetailSideSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get orderDetailSideSell;

  /// No description provided for @orderDetailOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderDetailOrderId;

  /// No description provided for @orderDetailCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get orderDetailCopied;

  /// No description provided for @orderDetailPair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get orderDetailPair;

  /// No description provided for @orderDetailSide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get orderDetailSide;

  /// No description provided for @orderDetailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get orderDetailType;

  /// No description provided for @orderDetailTimeInForce.
  ///
  /// In en, this message translates to:
  /// **'Time in force'**
  String get orderDetailTimeInForce;

  /// No description provided for @orderDetailFilledAmount.
  ///
  /// In en, this message translates to:
  /// **'Filled amount'**
  String get orderDetailFilledAmount;

  /// No description provided for @orderDetailAvgPrice.
  ///
  /// In en, this message translates to:
  /// **'Average price'**
  String get orderDetailAvgPrice;

  /// No description provided for @orderDetailRemainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get orderDetailRemainingAmount;

  /// No description provided for @orderDetailFilledPct.
  ///
  /// In en, this message translates to:
  /// **'Filled %'**
  String get orderDetailFilledPct;

  /// No description provided for @orderDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get orderDetailCreatedAt;

  /// No description provided for @orderDetailUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at'**
  String get orderDetailUpdatedAt;

  /// No description provided for @orderDetailUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get orderDetailUserId;

  /// No description provided for @orderDetailViewUser.
  ///
  /// In en, this message translates to:
  /// **'View user'**
  String get orderDetailViewUser;

  /// No description provided for @depositDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Details'**
  String get depositDetailTitle;

  /// No description provided for @depositDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get depositDetailAmount;

  /// No description provided for @drawerSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get drawerSectionGeneral;

  /// No description provided for @drawerSectionAdministration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get drawerSectionAdministration;

  /// No description provided for @drawerSectionAdminUsers.
  ///
  /// In en, this message translates to:
  /// **'Admin Users'**
  String get drawerSectionAdminUsers;

  /// No description provided for @drawerSectionAdminOps.
  ///
  /// In en, this message translates to:
  /// **'Admin Operations'**
  String get drawerSectionAdminOps;

  /// No description provided for @drawerTransactionMonitoringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Orders, deposits, withdrawals'**
  String get drawerTransactionMonitoringSubtitle;

  /// No description provided for @drawerCoinManagement.
  ///
  /// In en, this message translates to:
  /// **'Coin Management'**
  String get drawerCoinManagement;

  /// No description provided for @drawerCoinManagementSubtitleCrud.
  ///
  /// In en, this message translates to:
  /// **'Create, update, delete'**
  String get drawerCoinManagementSubtitleCrud;

  /// No description provided for @drawerCoinManagementSubtitleView.
  ///
  /// In en, this message translates to:
  /// **'Read-only currency view'**
  String get drawerCoinManagementSubtitleView;

  /// No description provided for @drawerSectionAdminSystem.
  ///
  /// In en, this message translates to:
  /// **'Admin System'**
  String get drawerSectionAdminSystem;

  /// No description provided for @drawerSectionFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get drawerSectionFinance;

  /// No description provided for @drawerPaymentConfig.
  ///
  /// In en, this message translates to:
  /// **'Payment Configuration'**
  String get drawerPaymentConfig;

  /// No description provided for @drawerPaymentConfigSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Methods, wallets, activation'**
  String get drawerPaymentConfigSubtitle;

  /// No description provided for @drawerTreasuryMainWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Hot Wallets'**
  String get drawerTreasuryMainWalletsTitle;

  /// No description provided for @drawerTreasuryMainWalletsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keys, approvals, MFA'**
  String get drawerTreasuryMainWalletsSubtitle;

  /// No description provided for @treasuryMainWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Hot Wallets Management'**
  String get treasuryMainWalletsTitle;

  /// No description provided for @treasuryMainWalletsTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active Wallets'**
  String get treasuryMainWalletsTabActive;

  /// No description provided for @treasuryMainWalletsTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get treasuryMainWalletsTabPending;

  /// No description provided for @treasuryMainWalletsEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No active main wallets found.'**
  String get treasuryMainWalletsEmptyActive;

  /// No description provided for @treasuryMainWalletsEmptyPending.
  ///
  /// In en, this message translates to:
  /// **'No pending wallets for approval.'**
  String get treasuryMainWalletsEmptyPending;

  /// No description provided for @treasuryMainWalletChipDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get treasuryMainWalletChipDefault;

  /// No description provided for @treasuryMainWalletLabelNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get treasuryMainWalletLabelNone;

  /// No description provided for @treasuryMainWalletTooltipSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get treasuryMainWalletTooltipSetDefault;

  /// No description provided for @treasuryMainWalletTooltipApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get treasuryMainWalletTooltipApprove;

  /// No description provided for @treasuryMainWalletTooltipReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get treasuryMainWalletTooltipReject;

  /// No description provided for @treasuryMainWalletUnknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get treasuryMainWalletUnknownTime;

  /// No description provided for @treasuryMainWalletCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance} {symbol}\nLabel: {label}'**
  String treasuryMainWalletCardSubtitle(
      String balance, String symbol, String label);

  /// No description provided for @treasuryMainWalletPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Added at: {dateTime}'**
  String treasuryMainWalletPendingSubtitle(String dateTime);

  /// No description provided for @treasuryTrc20UsdtBalanceLine.
  ///
  /// In en, this message translates to:
  /// **'USDT (TRC-20): {balance}'**
  String treasuryTrc20UsdtBalanceLine(String balance);

  /// No description provided for @treasuryMainWalletBalanceLine.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance} {symbol}'**
  String treasuryMainWalletBalanceLine(String balance, String symbol);

  /// No description provided for @treasuryMainWalletLabelLine.
  ///
  /// In en, this message translates to:
  /// **'Label: {label}'**
  String treasuryMainWalletLabelLine(String label);

  /// No description provided for @treasuryMainWalletPublicAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Public address'**
  String get treasuryMainWalletPublicAddressLabel;

  /// No description provided for @treasuryMainWalletCopyAddressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy public address'**
  String get treasuryMainWalletCopyAddressTooltip;

  /// No description provided for @treasuryMainWalletCopiedAddressSnack.
  ///
  /// In en, this message translates to:
  /// **'Public address copied to clipboard.'**
  String get treasuryMainWalletCopiedAddressSnack;

  /// No description provided for @treasuryMainWalletRevealPrivateKeyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Private key (email OTP)'**
  String get treasuryMainWalletRevealPrivateKeyTooltip;

  /// No description provided for @treasuryMainWalletMenuCopyPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Copy private key'**
  String get treasuryMainWalletMenuCopyPrivateKey;

  /// No description provided for @treasuryMainWalletMenuEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit label'**
  String get treasuryMainWalletMenuEditLabel;

  /// No description provided for @treasuryMainWalletMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Request removal (Risk must approve)'**
  String get treasuryMainWalletMenuDelete;

  /// No description provided for @treasuryMainWalletRevealKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy private key'**
  String get treasuryMainWalletRevealKeyTitle;

  /// No description provided for @treasuryMainWalletRevealKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Send OTP to your email, enter the code, then copy the key.'**
  String get treasuryMainWalletRevealKeyHint;

  /// No description provided for @treasuryMainWalletRevealKeyCopy.
  ///
  /// In en, this message translates to:
  /// **'Reveal and copy'**
  String get treasuryMainWalletRevealKeyCopy;

  /// No description provided for @treasuryMainWalletCopiedPrivateKeySnack.
  ///
  /// In en, this message translates to:
  /// **'Private key copied to clipboard.'**
  String get treasuryMainWalletCopiedPrivateKeySnack;

  /// No description provided for @treasuryMainWalletEditLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit label'**
  String get treasuryMainWalletEditLabelTitle;

  /// No description provided for @treasuryMainWalletEditLabelSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get treasuryMainWalletEditLabelSave;

  /// No description provided for @treasuryMainWalletLabelUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Label updated.'**
  String get treasuryMainWalletLabelUpdatedSnack;

  /// No description provided for @treasuryMainWalletDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Request wallet removal?'**
  String get treasuryMainWalletDeleteTitle;

  /// No description provided for @treasuryMainWalletDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'A Risk Officer must approve before the wallet is removed. You cannot request removal of the default wallet if another active wallet exists for the chain.'**
  String get treasuryMainWalletDeleteBody;

  /// No description provided for @treasuryMainWalletDeleteSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Removal requested — pending Risk approval.'**
  String get treasuryMainWalletDeleteSuccessSnack;

  /// No description provided for @treasuryMainWalletDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get treasuryMainWalletDeleteAction;

  /// No description provided for @treasuryMainWalletChipPendingDeletion.
  ///
  /// In en, this message translates to:
  /// **'Pending deletion'**
  String get treasuryMainWalletChipPendingDeletion;

  /// No description provided for @treasuryMainWalletPendingDeletionHint.
  ///
  /// In en, this message translates to:
  /// **'Removal awaiting Risk Officer approval. This wallet is not used for Fund/Sweep until approved or cancelled.'**
  String get treasuryMainWalletPendingDeletionHint;

  /// No description provided for @treasuryMainWalletTooltipApproveDeletion.
  ///
  /// In en, this message translates to:
  /// **'Approve deletion (remove wallet)'**
  String get treasuryMainWalletTooltipApproveDeletion;

  /// No description provided for @treasuryMainWalletTooltipRejectDeletion.
  ///
  /// In en, this message translates to:
  /// **'Reject deletion (restore wallet)'**
  String get treasuryMainWalletTooltipRejectDeletion;

  /// No description provided for @treasuryChainTronNile.
  ///
  /// In en, this message translates to:
  /// **'TRON — Nile testnet'**
  String get treasuryChainTronNile;

  /// No description provided for @treasuryChainTronMainnet.
  ///
  /// In en, this message translates to:
  /// **'TRON — Mainnet'**
  String get treasuryChainTronMainnet;

  /// No description provided for @treasuryChainBscTestnet.
  ///
  /// In en, this message translates to:
  /// **'BNB Smart Chain — Testnet'**
  String get treasuryChainBscTestnet;

  /// No description provided for @treasuryChainBscMainnet.
  ///
  /// In en, this message translates to:
  /// **'BNB Smart Chain — Mainnet'**
  String get treasuryChainBscMainnet;

  /// No description provided for @treasuryChainSolanaDevnet.
  ///
  /// In en, this message translates to:
  /// **'Solana — Devnet'**
  String get treasuryChainSolanaDevnet;

  /// No description provided for @treasuryChainSolanaMainnet.
  ///
  /// In en, this message translates to:
  /// **'Solana — Mainnet'**
  String get treasuryChainSolanaMainnet;

  /// No description provided for @treasuryChainTronShasta.
  ///
  /// In en, this message translates to:
  /// **'TRON — Shasta testnet'**
  String get treasuryChainTronShasta;

  /// No description provided for @treasuryChainEthSepolia.
  ///
  /// In en, this message translates to:
  /// **'Ethereum — Sepolia'**
  String get treasuryChainEthSepolia;

  /// No description provided for @treasuryChainEthMainnet.
  ///
  /// In en, this message translates to:
  /// **'Ethereum — Mainnet'**
  String get treasuryChainEthMainnet;

  /// No description provided for @treasuryImportWalletDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import main wallet ({chainName})'**
  String treasuryImportWalletDialogTitle(String chainName);

  /// No description provided for @treasuryImportWalletLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get treasuryImportWalletLabelOptional;

  /// No description provided for @treasuryImportWalletPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Private key'**
  String get treasuryImportWalletPrivateKey;

  /// No description provided for @treasuryImportWalletMfaCode.
  ///
  /// In en, this message translates to:
  /// **'MFA code'**
  String get treasuryImportWalletMfaCode;

  /// No description provided for @treasuryImportWalletSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get treasuryImportWalletSendOtp;

  /// No description provided for @treasuryImportWalletImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get treasuryImportWalletImport;

  /// No description provided for @treasuryImportWalletMfaSentSnack.
  ///
  /// In en, this message translates to:
  /// **'MFA code sent to your email.'**
  String get treasuryImportWalletMfaSentSnack;

  /// No description provided for @treasuryImportWalletMfaFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Failed to send MFA: {error}'**
  String treasuryImportWalletMfaFailedSnack(String error);

  /// No description provided for @treasuryImportWalletRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Private key and MFA code are required.'**
  String get treasuryImportWalletRequiredSnack;

  /// No description provided for @treasuryImportWalletOtpStepHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Send OTP, enter the code from your email, and confirm. You can enter the label and private key only after the code is verified.'**
  String get treasuryImportWalletOtpStepHint;

  /// No description provided for @treasuryImportWalletConfirmOtp.
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get treasuryImportWalletConfirmOtp;

  /// No description provided for @treasuryImportWalletOtpEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email.'**
  String get treasuryImportWalletOtpEmpty;

  /// No description provided for @treasuryImportWalletOtpVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify: {message}'**
  String treasuryImportWalletOtpVerifyFailed(String message);

  /// No description provided for @treasuryImportWalletPrivateKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Private key is required.'**
  String get treasuryImportWalletPrivateKeyRequired;

  /// No description provided for @treasuryImportWalletMistakeTronAddress.
  ///
  /// In en, this message translates to:
  /// **'This looks like a TRON address (starts with T), not a private key. Paste the 64-character hex private key from your wallet export.'**
  String get treasuryImportWalletMistakeTronAddress;

  /// No description provided for @treasuryImportWalletMistakeEvmAddress.
  ///
  /// In en, this message translates to:
  /// **'This looks like an EVM wallet address (0x…), not a private key. Paste the 64-character hex private key from your wallet export.'**
  String get treasuryImportWalletMistakeEvmAddress;

  /// No description provided for @treasuryImportWalletSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Wallet imported to pending approvals.'**
  String get treasuryImportWalletSuccessSnack;

  /// No description provided for @treasuryImportWalletErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String treasuryImportWalletErrorSnack(String error);

  /// No description provided for @treasuryImportWalletMfaExpiredOnImport.
  ///
  /// In en, this message translates to:
  /// **'This email code expired or was already used. Tap Send OTP for a new code, confirm it, then try importing again.'**
  String get treasuryImportWalletMfaExpiredOnImport;

  /// No description provided for @treasuryImportWalletMfaExpiredOnImportSnack.
  ///
  /// In en, this message translates to:
  /// **'OTP expired or invalid. Tap Send OTP for a new code.'**
  String get treasuryImportWalletMfaExpiredOnImportSnack;

  /// No description provided for @drawerWithdrawalManagement.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Management'**
  String get drawerWithdrawalManagement;

  /// No description provided for @drawerWithdrawalManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and process requests'**
  String get drawerWithdrawalManagementSubtitle;

  /// No description provided for @drawerManagedWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'User deposits & managed wallets'**
  String get drawerManagedWalletsTitle;

  /// No description provided for @drawerManagedWalletsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default deposit addresses, priority chain, company wallets'**
  String get drawerManagedWalletsSubtitle;

  /// No description provided for @drawerBlockchainHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Blockchain hub'**
  String get drawerBlockchainHubTitle;

  /// No description provided for @drawerBlockchainHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-chain deposits, withdrawals, tools'**
  String get drawerBlockchainHubSubtitle;

  /// No description provided for @drawerSectionTreasuryDeposits.
  ///
  /// In en, this message translates to:
  /// **'Treasury & deposits'**
  String get drawerSectionTreasuryDeposits;

  /// No description provided for @managedWalletOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Owner: {userIdShort}'**
  String managedWalletOwnerHint(String userIdShort);

  /// No description provided for @drawerSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get drawerSectionAccount;

  /// No description provided for @profileFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get profileFirstName;

  /// No description provided for @profileLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get profileLastName;

  /// No description provided for @ordersPayosUsdtHint.
  ///
  /// In en, this message translates to:
  /// **'Use PayOS to top up VND and buy USDT for trading.'**
  String get ordersPayosUsdtHint;

  /// No description provided for @priceHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 65000'**
  String get priceHintExample;

  /// No description provided for @amountHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0.01'**
  String get amountHintExample;

  /// No description provided for @maxAmountButton.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get maxAmountButton;

  /// No description provided for @amountMaxDecimals.
  ///
  /// In en, this message translates to:
  /// **'Amount supports up to {max} decimal places'**
  String amountMaxDecimals(int max);

  /// No description provided for @priceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Price must be positive'**
  String get priceMustBePositive;

  /// No description provided for @priceMaxDecimals.
  ///
  /// In en, this message translates to:
  /// **'Price supports up to {max} decimal places'**
  String priceMaxDecimals(int max);

  /// No description provided for @tickerBid.
  ///
  /// In en, this message translates to:
  /// **'Bid'**
  String get tickerBid;

  /// No description provided for @tickerAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get tickerAsk;

  /// No description provided for @ticker24hHigh.
  ///
  /// In en, this message translates to:
  /// **'24h High'**
  String get ticker24hHigh;

  /// No description provided for @ticker24hLow.
  ///
  /// In en, this message translates to:
  /// **'24h Low'**
  String get ticker24hLow;

  /// No description provided for @tickerVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get tickerVolume;

  /// No description provided for @orderColumnSide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get orderColumnSide;

  /// No description provided for @orderColumnTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get orderColumnTime;

  /// No description provided for @timeSecondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String timeSecondsShort(int seconds);

  /// No description provided for @timeMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String timeMinutesShort(int minutes);

  /// No description provided for @timeHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String timeHoursShort(int hours);

  /// No description provided for @ordersSelectPairFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a trading pair first'**
  String get ordersSelectPairFirst;

  /// No description provided for @myOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open orders'**
  String get myOrdersEmpty;

  /// No description provided for @ordersMyOrdersWithCount.
  ///
  /// In en, this message translates to:
  /// **'My Orders ({count})'**
  String ordersMyOrdersWithCount(int count);

  /// No description provided for @orderBookColumnSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get orderBookColumnSize;

  /// No description provided for @orderBookColumnCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get orderBookColumnCount;

  /// No description provided for @marketPriceAbbrev.
  ///
  /// In en, this message translates to:
  /// **'MKT'**
  String get marketPriceAbbrev;

  /// No description provided for @orderFilledQuantity.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get orderFilledQuantity;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsSeedColor.
  ///
  /// In en, this message translates to:
  /// **'Seed color'**
  String get settingsSeedColor;

  /// No description provided for @walletDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet Debug'**
  String get walletDebugTitle;

  /// No description provided for @adminUserListRoleAll.
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get adminUserListRoleAll;

  /// No description provided for @adminUserListRoleTrader.
  ///
  /// In en, this message translates to:
  /// **'Trader'**
  String get adminUserListRoleTrader;

  /// No description provided for @adminUserListRoleVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified user'**
  String get adminUserListRoleVerified;

  /// No description provided for @adminUserListRoleMarketMaker.
  ///
  /// In en, this message translates to:
  /// **'Market maker'**
  String get adminUserListRoleMarketMaker;

  /// No description provided for @adminUserListRoleSupport.
  ///
  /// In en, this message translates to:
  /// **'Support agent'**
  String get adminUserListRoleSupport;

  /// No description provided for @adminUserListRoleRiskOfficer.
  ///
  /// In en, this message translates to:
  /// **'Risk officer'**
  String get adminUserListRoleRiskOfficer;

  /// No description provided for @adminUserListRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminUserListRoleAdmin;

  /// No description provided for @adminUserListRoleFinanceManager.
  ///
  /// In en, this message translates to:
  /// **'Finance manager'**
  String get adminUserListRoleFinanceManager;

  /// No description provided for @adminUserListRoleGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get adminUserListRoleGuest;

  /// No description provided for @adminUserListStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminUserListStatusActive;

  /// No description provided for @adminUserListStatusBanned.
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get adminUserListStatusBanned;

  /// No description provided for @adminUserListStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminUserListStatusPending;

  /// No description provided for @adminUserListTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin User List'**
  String get adminUserListTitle;

  /// No description provided for @adminUserListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search users by name, email or ID'**
  String get adminUserListSearchHint;

  /// No description provided for @adminUserListRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminUserListRoleLabel;

  /// No description provided for @adminUserListStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminUserListStatusLabel;

  /// No description provided for @adminUserListTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total users: {count}'**
  String adminUserListTotalUsers(int count);

  /// No description provided for @adminUserListNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminUserListNoUsersFound;

  /// No description provided for @adminUserListSelectUserPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a user to view details'**
  String get adminUserListSelectUserPlaceholder;

  /// No description provided for @adminUserDetailNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get adminUserDetailNoteLabel;

  /// No description provided for @adminWalletAdjustSelectUserRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a user'**
  String get adminWalletAdjustSelectUserRequired;

  /// No description provided for @adminWalletAdjustError.
  ///
  /// In en, this message translates to:
  /// **'Adjustment failed'**
  String get adminWalletAdjustError;

  /// No description provided for @adminWalletAdjustUserIdRequired.
  ///
  /// In en, this message translates to:
  /// **'User ID is required'**
  String get adminWalletAdjustUserIdRequired;

  /// No description provided for @adminWalletAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet Adjustment'**
  String get adminWalletAdjustTitle;

  /// No description provided for @adminWalletAdjustDepositWithdrawTab.
  ///
  /// In en, this message translates to:
  /// **'Deposit/Withdraw'**
  String get adminWalletAdjustDepositWithdrawTab;

  /// No description provided for @adminWalletAdjustHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get adminWalletAdjustHistoryTab;

  /// No description provided for @adminWalletAdjustUseUserMgmt.
  ///
  /// In en, this message translates to:
  /// **'Use User Management'**
  String get adminWalletAdjustUseUserMgmt;

  /// No description provided for @adminWalletAdjustUseUserMgmtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick user from admin user list'**
  String get adminWalletAdjustUseUserMgmtSubtitle;

  /// No description provided for @adminWalletAdjustOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminWalletAdjustOpen;

  /// No description provided for @adminWalletAdjustOperationType.
  ///
  /// In en, this message translates to:
  /// **'Operation type'**
  String get adminWalletAdjustOperationType;

  /// No description provided for @adminWalletAdjustInfo.
  ///
  /// In en, this message translates to:
  /// **'Adjustment Information'**
  String get adminWalletAdjustInfo;

  /// No description provided for @adminWalletAdjustSelectUserHint.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID'**
  String get adminWalletAdjustSelectUserHint;

  /// No description provided for @adminWalletAdjustAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get adminWalletAdjustAmountLabel;

  /// No description provided for @adminWalletAdjustAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter adjustment amount'**
  String get adminWalletAdjustAmountHint;

  /// No description provided for @adminWalletAdjustAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get adminWalletAdjustAmountRequired;

  /// No description provided for @adminWalletAdjustAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get adminWalletAdjustAmountInvalid;

  /// No description provided for @adminWalletAdjustAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get adminWalletAdjustAmountMustBePositive;

  /// No description provided for @adminWalletAdjustNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get adminWalletAdjustNoteLabel;

  /// No description provided for @adminWalletAdjustReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for adjustment'**
  String get adminWalletAdjustReasonHint;

  /// No description provided for @adminWalletAdjustDepositTab.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get adminWalletAdjustDepositTab;

  /// No description provided for @adminWalletAdjustWithdrawTab.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get adminWalletAdjustWithdrawTab;

  /// No description provided for @adminWalletAdjustProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get adminWalletAdjustProcessing;

  /// No description provided for @adminWalletAdjustDepositBalance.
  ///
  /// In en, this message translates to:
  /// **'Deposit to balance'**
  String get adminWalletAdjustDepositBalance;

  /// No description provided for @adminWalletAdjustWithdrawBalance.
  ///
  /// In en, this message translates to:
  /// **'Withdraw from balance'**
  String get adminWalletAdjustWithdrawBalance;

  /// No description provided for @adminWalletHistoryUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get adminWalletHistoryUserIdLabel;

  /// No description provided for @adminWalletSearchUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Search by User ID'**
  String get adminWalletSearchUserIdHint;

  /// No description provided for @adminWalletSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get adminWalletSearchButton;

  /// No description provided for @adminWalletSearchByUserList.
  ///
  /// In en, this message translates to:
  /// **'Search by user list'**
  String get adminWalletSearchByUserList;

  /// No description provided for @adminWalletNoAdjustmentHistory.
  ///
  /// In en, this message translates to:
  /// **'No adjustment history'**
  String get adminWalletNoAdjustmentHistory;

  /// No description provided for @adminWalletTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get adminWalletTargetLabel;

  /// No description provided for @adminWalletActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Actor'**
  String get adminWalletActorLabel;

  /// No description provided for @homeLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm logout'**
  String get homeLogoutConfirmTitle;

  /// No description provided for @homeLogoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get homeLogoutConfirmContent;

  /// No description provided for @homeLogoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeLogoutCancel;

  /// No description provided for @homeLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get homeLogoutConfirm;

  /// No description provided for @homeFailedToLoadUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user information'**
  String get homeFailedToLoadUser;

  /// No description provided for @homeGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get homeGoToLogin;

  /// No description provided for @homeAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeAppTitle;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @homeCryptoPlatform.
  ///
  /// In en, this message translates to:
  /// **'Crypto trading platform'**
  String get homeCryptoPlatform;

  /// No description provided for @homeAuthReady.
  ///
  /// In en, this message translates to:
  /// **'Authentication ready'**
  String get homeAuthReady;

  /// No description provided for @homeLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get homeLastUpdated;

  /// No description provided for @wcLoginTitleWeb.
  ///
  /// In en, this message translates to:
  /// **'Login with wallet (Web)'**
  String get wcLoginTitleWeb;

  /// No description provided for @wcLoginTitleNative.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect login'**
  String get wcLoginTitleNative;

  /// No description provided for @wcReownDesktopUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a network, tap “Create QR code”, scan with your phone wallet, then sign when asked.'**
  String get wcReownDesktopUnsupportedBody;

  /// No description provided for @wcReownMissingProjectId.
  ///
  /// In en, this message translates to:
  /// **'Missing WALLETCONNECT_PROJECT_ID (or REOWN_PROJECT_ID) in .env'**
  String get wcReownMissingProjectId;

  /// No description provided for @wcReownInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not initialize Reown: {error}'**
  String wcReownInitFailed(String error);

  /// No description provided for @wcReownSessionNoEvmAddress.
  ///
  /// In en, this message translates to:
  /// **'Session has no EVM address (eip155). Choose an EVM wallet / Sepolia.'**
  String get wcReownSessionNoEvmAddress;

  /// No description provided for @wcReownNoSignature.
  ///
  /// In en, this message translates to:
  /// **'Wallet did not return a signature.'**
  String get wcReownNoSignature;

  /// No description provided for @wcReownLoginError.
  ///
  /// In en, this message translates to:
  /// **'Wallet login error: {error}'**
  String wcReownLoginError(String error);

  /// No description provided for @wcReownQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Open QR, connect your phone wallet, then sign the login message (Sepolia).'**
  String get wcReownQrDescription;

  /// No description provided for @wcReownOpenQrButton.
  ///
  /// In en, this message translates to:
  /// **'Open WalletConnect QR (Reown)'**
  String get wcReownOpenQrButton;

  /// No description provided for @wcAdvancedLegacyQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Other: Server QR code'**
  String get wcAdvancedLegacyQrTitle;

  /// No description provided for @wcAdvancedLegacyQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you prefer not to use Reown above'**
  String get wcAdvancedLegacyQrSubtitle;

  /// No description provided for @wcManualFlowIntroWeb.
  ///
  /// In en, this message translates to:
  /// **'Create a QR, scan with your wallet, sign the message, then finish on the web app.'**
  String get wcManualFlowIntroWeb;

  /// No description provided for @wcManualFlowIntroNative.
  ///
  /// In en, this message translates to:
  /// **'Create a QR and scan with your phone; the app completes login when the server receives the signature.'**
  String get wcManualFlowIntroNative;

  /// No description provided for @wcNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get wcNetworkLabel;

  /// No description provided for @wcCreateQr.
  ///
  /// In en, this message translates to:
  /// **'Create QR code'**
  String get wcCreateQr;

  /// No description provided for @wcCreateQrNew.
  ///
  /// In en, this message translates to:
  /// **'Create new QR code'**
  String get wcCreateQrNew;

  /// No description provided for @wcRelayDisabledBanner.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect relay is off on the server (missing project id). This QR is not scannable — set WALLETCONNECT_PROJECT_ID on the API, restart, create a new QR. Or sign the message and paste address + signature below.'**
  String get wcRelayDisabledBanner;

  /// No description provided for @wcQrFooterLoginShort.
  ///
  /// In en, this message translates to:
  /// **'Scan with your phone wallet and sign the message below.'**
  String get wcQrFooterLoginShort;

  /// No description provided for @wcMessageToSign.
  ///
  /// In en, this message translates to:
  /// **'Message to sign'**
  String get wcMessageToSign;

  /// No description provided for @wcCopyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get wcCopyMessage;

  /// No description provided for @wcMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get wcMessageCopied;

  /// No description provided for @wcCompletingLogin.
  ///
  /// In en, this message translates to:
  /// **'Completing sign-in…'**
  String get wcCompletingLogin;

  /// No description provided for @wcSignedWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet address used to sign'**
  String get wcSignedWalletAddress;

  /// No description provided for @wcSignatureField.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get wcSignatureField;

  /// No description provided for @wcVerifyAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify & sign in'**
  String get wcVerifyAndLogin;

  /// No description provided for @wcWebRecommendExtension.
  ///
  /// In en, this message translates to:
  /// **'Tron: use TronLink on Chrome. EVM: open the QR section below.'**
  String get wcWebRecommendExtension;

  /// No description provided for @wcWebAdvancedWcTitle.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect QR / paste signature'**
  String get wcWebAdvancedWcTitle;

  /// No description provided for @wcWebAdvancedWcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Desktop, mobile wallet, or no extension'**
  String get wcWebAdvancedWcSubtitle;

  /// No description provided for @wcWebTronLinkExtension.
  ///
  /// In en, this message translates to:
  /// **'TronLink (Chrome)'**
  String get wcWebTronLinkExtension;

  /// No description provided for @wcEnterAddressAndSignature.
  ///
  /// In en, this message translates to:
  /// **'Enter wallet address and signature.'**
  String get wcEnterAddressAndSignature;

  /// No description provided for @wcSessionExpiredCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Create a new QR code.'**
  String get wcSessionExpiredCreateNew;

  /// No description provided for @desktopTronlinkDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'TronLink'**
  String get desktopTronlinkDialogTitle;

  /// No description provided for @desktopTronlinkDialogBody.
  ///
  /// In en, this message translates to:
  /// **'TronLink works in Chrome (web) only. On this app: sign in with email or open the web version.'**
  String get desktopTronlinkDialogBody;

  /// No description provided for @desktopTronlinkDialogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get desktopTronlinkDialogOk;

  /// No description provided for @wcLinkDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Link digital wallet'**
  String get wcLinkDialogTitle;

  /// No description provided for @wcLinkDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect via WalletConnect • High security'**
  String get wcLinkDialogSubtitle;

  /// No description provided for @wcQrScanHintEvm.
  ///
  /// In en, this message translates to:
  /// **'Open Trust Wallet or MetaMask Mobile → Scan QR'**
  String get wcQrScanHintEvm;

  /// No description provided for @wcQrScanHintSolana.
  ///
  /// In en, this message translates to:
  /// **'Solana: open Phantom or Solflare Mobile → Scan QR (MetaMask is mainly for Ethereum; WalletConnect on Solana needs a Solana-capable wallet).'**
  String get wcQrScanHintSolana;

  /// No description provided for @wcQrCopyUri.
  ///
  /// In en, this message translates to:
  /// **'Copy URI'**
  String get wcQrCopyUri;

  /// No description provided for @wcQrUriCopied.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect URI copied'**
  String get wcQrUriCopied;

  /// No description provided for @wcQrWalletLinkedCard.
  ///
  /// In en, this message translates to:
  /// **'Wallet linked successfully!'**
  String get wcQrWalletLinkedCard;

  /// No description provided for @wcSessionExpiredFiveMin.
  ///
  /// In en, this message translates to:
  /// **'Session expired (5 minutes)'**
  String get wcSessionExpiredFiveMin;

  /// No description provided for @wcQrCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new QR'**
  String get wcQrCreateNew;

  /// No description provided for @wcStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Awaiting…'**
  String get wcStatusIdle;

  /// No description provided for @wcStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for QR scan'**
  String get wcStatusPending;

  /// No description provided for @wcStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Wallet connected, waiting for signature…'**
  String get wcStatusConnected;

  /// No description provided for @wcStatusSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed successfully!'**
  String get wcStatusSigned;

  /// No description provided for @wcStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get wcStatusExpired;

  /// No description provided for @wcStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get wcStatusFailed;

  /// No description provided for @wcLinkChooseBlockchain.
  ///
  /// In en, this message translates to:
  /// **'Choose blockchain'**
  String get wcLinkChooseBlockchain;

  /// No description provided for @wcTooltipTronlinkChrome.
  ///
  /// In en, this message translates to:
  /// **'Use TronLink extension (Chrome)'**
  String get wcTooltipTronlinkChrome;

  /// No description provided for @wcTooltipWalletConnect.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect'**
  String get wcTooltipWalletConnect;

  /// No description provided for @wcTronChromeExtensionWebOnly.
  ///
  /// In en, this message translates to:
  /// **'TronLink is handled via Chrome extension — only available on web.'**
  String get wcTronChromeExtensionWebOnly;

  /// No description provided for @wcTronChromeOnlyLong.
  ///
  /// In en, this message translates to:
  /// **'Tron is only supported via TronLink extension on Chrome. Please open the site in Chrome to link your Tron wallet.'**
  String get wcTronChromeOnlyLong;

  /// No description provided for @wcCreateQrButton.
  ///
  /// In en, this message translates to:
  /// **'Generate connection QR'**
  String get wcCreateQrButton;

  /// No description provided for @wcCancelReselect.
  ///
  /// In en, this message translates to:
  /// **'Cancel and choose again'**
  String get wcCancelReselect;

  /// No description provided for @wcPrivateKeyStaysInWallet.
  ///
  /// In en, this message translates to:
  /// **'Your private key never leaves your wallet.'**
  String get wcPrivateKeyStaysInWallet;

  /// No description provided for @wcCreatingSession.
  ///
  /// In en, this message translates to:
  /// **'Creating connection…'**
  String get wcCreatingSession;

  /// No description provided for @wcSessionCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create WalletConnect session. Try again.'**
  String get wcSessionCreateFailed;

  /// No description provided for @wcSessionExpiredNewQr.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please create a new QR code.'**
  String get wcSessionExpiredNewQr;

  /// No description provided for @wcSessionWcFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect failed (connection or signing). Create a new QR code or try again.'**
  String get wcSessionWcFailedRetry;

  /// No description provided for @wcWcSupportsEvmSolanaTron.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect supports Ethereum Sepolia and Solana Devnet. For Tron, use the TronLink extension on Chrome.'**
  String get wcWcSupportsEvmSolanaTron;

  /// No description provided for @wcSignWithTronlinkExtension.
  ///
  /// In en, this message translates to:
  /// **'Sign with TronLink extension'**
  String get wcSignWithTronlinkExtension;

  /// No description provided for @wcTronlinkSignFailed.
  ///
  /// In en, this message translates to:
  /// **'TronLink signing failed.'**
  String get wcTronlinkSignFailed;

  /// No description provided for @wcTronlinkSignMessage.
  ///
  /// In en, this message translates to:
  /// **'TronLink link wallet'**
  String get wcTronlinkSignMessage;

  /// No description provided for @wcOpenWalletOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Open with wallet on phone'**
  String get wcOpenWalletOnPhone;

  /// No description provided for @wcWalletNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'{name} is not installed'**
  String wcWalletNotInstalled(String name);

  /// No description provided for @wcDownloadFromStore.
  ///
  /// In en, this message translates to:
  /// **'Download from {store}'**
  String wcDownloadFromStore(String store);

  /// No description provided for @wcOpenWalletNamed.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String wcOpenWalletNamed(String name);

  /// No description provided for @wcStoreGooglePlay.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get wcStoreGooglePlay;

  /// No description provided for @wcStoreAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get wcStoreAppStore;

  /// No description provided for @wcLinkedWalletAddedToList.
  ///
  /// In en, this message translates to:
  /// **'The wallet has been added to your linked list.'**
  String get wcLinkedWalletAddedToList;

  /// No description provided for @onchainOperatorSandboxBanner.
  ///
  /// In en, this message translates to:
  /// **'On-chain deployment is in Sandbox mode. Use test networks only — not real mainnet funds.'**
  String get onchainOperatorSandboxBanner;

  /// No description provided for @onchainSandboxShort.
  ///
  /// In en, this message translates to:
  /// **'Sandbox'**
  String get onchainSandboxShort;
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
