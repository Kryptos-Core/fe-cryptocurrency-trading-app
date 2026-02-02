/// # Hướng Dẫn Tích Hợp Wallet API trong Flutter
///
/// ## 📋 Nội dung
///
/// 1. [Kiến Trúc Ứng Dụng](#kiến-trúc-ứng-dụng)
/// 2. [Quy Trình Vận Hành](#quy-trình-vận-hành)
/// 3. [Các Ví Dụ Thực Tế](#các-ví-dụ-thực-tế)
/// 4. [Xử Lý Lỗi](#xử-lý-lỗi)
/// 5. [Best Practices](#best-practices)
///
/// ---
///
/// ## 🏗️ Kiến Trúc Ứng Dụng
///
/// Dự án sử dụng **Clean Architecture** với 4 layer:
///
/// ```
/// Presentation Layer (UI, Screens, Widgets)
///        ↓
/// Domain Layer (Use Cases, Entities, Repositories Interface)
///        ↓
/// Data Layer (DTOs, Data Sources, Repository Implementation)
///        ↓
/// Core Layer (Network, Validation, DI)
/// ```
///
/// ### Wallet Implementation Layers
///
/// **Domain Layer:**
/// - `lib/domain/entities/wallet_balance.dart` - WalletBalance entity
/// - `lib/domain/entities/wallet_transaction.dart` - Transaction entities
/// - `lib/domain/repositories/wallet_repository.dart` - Repository interface
/// - `lib/domain/usecases/get_wallet_balance_usecase.dart` - Fetch balance use case
/// - `lib/domain/usecases/execute_wallet_transaction_usecase.dart` - Execute transaction use case
///
/// **Data Layer:**
/// - `lib/data/models/wallet_balance_model.dart` - WalletBalance DTO
/// - `lib/data/models/wallet_transaction_model.dart` - Transaction DTO
/// - `lib/data/datasources/wallet_remote_datasource.dart` - API calls
/// - `lib/data/datasources/wallet_local_datasource.dart` - Local caching
/// - `lib/data/repositories/wallet_repository_impl.dart` - Repository implementation
///
/// **Presentation Layer:**
/// - `lib/presentation/providers/wallets_provider.dart` - State management
/// - Various screens and widgets using the provider
///
/// **Core Layer:**
/// - `lib/core/utils/wallet_validation_util.dart` - Validation utilities
/// - `lib/core/di/injection_container.dart` - Dependency injection
///
/// ---
///
/// ## ⚙️ Quy Trình Vận Hành
///
/// ### Quy Trình 1: Fetch Wallet Balance
///
/// **Flow:**
/// 1. User opens Wallet screen
/// 2. Screen calls `provider.fetchBalance(currencyId: 1)`
/// 3. Provider calls `getWalletBalanceApiUseCase`
/// 4. Use case calls repository method
/// 5. Repository calls remote data source
/// 6. Remote data source makes HTTP request to `/wallets/balance?currencyId=1`
/// 7. API returns balance data
/// 8. Data is cached locally via Hive
/// 9. UI updates with new balance
///
/// **Code Flow:**
/// ```
/// WalletsScreen
///   └─> WalletsProvider.fetchBalance()
///       └─> GetWalletBalanceApiUseCase()
///           └─> WalletRepositoryImpl.getBalance()
///               ├─> WalletRemoteDataSourceImpl.getBalance()
///               │   └─> DioClient.get('/wallets/balance')
///               └─> WalletLocalDataSourceImpl.cacheBalance()
/// ```
///
/// ### Quy Trình 2: Execute Transaction (CREDIT/DEBIT/FREEZE/UNFREEZE/TRANSFER)
///
/// **Flow:**
/// 1. User performs action (deposit, withdraw, place order, cancel order, transfer)
/// 2. Screen calls appropriate provider method:
///    - `provider.deposit()` - for CREDIT
///    - `provider.withdraw()` - for DEBIT
///    - `provider.freezeBalance()` - for FREEZE
///    - `provider.unfreezeBalance()` - for UNFREEZE
///    - `provider.transfer()` - for TRANSFER
/// 3. Provider creates `WalletTransactionRequest`
/// 4. Provider calls `executeWalletTransactionApiUseCase`
/// 5. Use case validates and calls repository
/// 6. Repository calls remote data source
/// 7. Remote data source makes HTTP request to `POST /wallets/transactions`
/// 8. API executes transaction with double-entry accounting
/// 9. New balance is returned and cached
/// 10. UI updates with transaction result
///
/// **Code Flow:**
/// ```
/// DepositScreen
///   └─> WalletsProvider.deposit()
///       └─> ExecuteWalletTransactionApiUseCase()
///           └─> WalletRepositoryImpl.executeTransaction()
///               ├─> WalletRemoteDataSourceImpl.executeTransaction()
///               │   └─> DioClient.post('/wallets/transactions')
///               └─> WalletLocalDataSourceImpl.cacheBalance()
/// ```
///
/// ---
///
/// ## 💡 Các Ví Dụ Thực Tế
///
/// ### Ví Dụ 1: Fetch và Hiển Thị Wallet Balance
///
/// **Screen Code:**
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:provider/provider.dart';
/// import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
/// import 'package:crypto_trading_app/core/utils/wallet_validation_util.dart';
///
/// class WalletBalanceScreen extends StatefulWidget {
///   @override
///   State<WalletBalanceScreen> createState() => _WalletBalanceScreenState();
/// }
///
/// class _WalletBalanceScreenState extends State<WalletBalanceScreen> {
///   @override
///   void initState() {
///     super.initState();
///     // Fetch balance when screen loads
///     WidgetsBinding.instance.addPostFrameCallback((_) {
///       context.read<WalletsProvider>().fetchBalance(
///         currencyId: 1, // BTC
///         forceRefresh: true,
///       );
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('Bitcoin Wallet')),
///       body: Consumer<WalletsProvider>(
///         builder: (context, provider, _) {
///           // Loading state
///           if (provider.state == WalletState.loading) {
///             return const Center(child: CircularProgressIndicator());
///           }
///
///           // Error state
///           if (provider.state == WalletState.error) {
///             return Center(
///               child: Column(
///                 mainAxisAlignment: MainAxisAlignment.center,
///                 children: [
///                   Text('Error: ${provider.error}'),
///                   ElevatedButton(
///                     onPressed: () => provider.fetchBalance(currencyId: 1),
///                     child: const Text('Retry'),
///                   ),
///                 ],
///               ),
///             );
///           }
///
///           // Success state
///           final balance = provider.balance;
///           if (balance == null) {
///             return const Center(child: Text('No balance data'));
///           }
///
///           return SingleChildScrollView(
///             padding: const EdgeInsets.all(16.0),
///             child: Column(
///               children: [
///                 // Available balance card
///                 Card(
///                   child: Padding(
///                     padding: const EdgeInsets.all(16.0),
///                     child: Column(
///                       crossAxisAlignment: CrossAxisAlignment.start,
///                       children: [
///                         const Text('Available Balance',
///                             style: TextStyle(color: Colors.grey)),
///                         const SizedBox(height: 8),
///                         Text(
///                           '${balance.available} BTC',
///                           style: const TextStyle(
///                             fontSize: 24,
///                             fontWeight: FontWeight.bold,
///                             color: Colors.green,
///                           ),
///                         ),
///                       ],
///                     ),
///                   ),
///                 ),
///                 const SizedBox(height: 16),
///
///                 // Frozen balance card
///                 Card(
///                   child: Padding(
///                     padding: const EdgeInsets.all(16.0),
///                     child: Column(
///                       crossAxisAlignment: CrossAxisAlignment.start,
///                       children: [
///                         const Text('Frozen Balance (Locked)',
///                             style: TextStyle(color: Colors.grey)),
///                         const SizedBox(height: 8),
///                         Text(
///                           '${balance.frozen} BTC',
///                           style: const TextStyle(
///                             fontSize: 24,
///                             fontWeight: FontWeight.bold,
///                             color: Colors.orange,
///                           ),
///                         ),
///                       ],
///                     ),
///                   ),
///                 ),
///                 const SizedBox(height: 16),
///
///                 // Total balance card
///                 Card(
///                   color: Colors.blue.shade50,
///                   child: Padding(
///                     padding: const EdgeInsets.all(16.0),
///                     child: Row(
///                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
///                       children: [
///                         const Column(
///                           crossAxisAlignment: CrossAxisAlignment.start,
///                           children: [
///                             Text('Total Balance',
///                                 style: TextStyle(color: Colors.grey)),
///                             SizedBox(height: 8),
///                           ],
///                         ),
///                         Text(
///                           '${balance.total} BTC',
///                           style: const TextStyle(
///                             fontSize: 20,
///                             fontWeight: FontWeight.bold,
///                             color: Colors.blue,
///                           ),
///                         ),
///                       ],
///                     ),
///                   ),
///                 ),
///               ],
///             ),
///           );
///         },
///       ),
///     );
///   }
/// }
/// ```
///
/// ### Ví Dụ 2: Nạp Tiền (Deposit)
///
/// **Screen Code:**
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:provider/provider.dart';
/// import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
/// import 'package:crypto_trading_app/core/utils/wallet_validation_util.dart';
///
/// class DepositScreen extends StatefulWidget {
///   final int depositId; // Assuming deposit is already created
///
///   const DepositScreen({required this.depositId});
///
///   @override
///   State<DepositScreen> createState() => _DepositScreenState();
/// }
///
/// class _DepositScreenState extends State<DepositScreen> {
///   final _amountController = TextEditingController();
///   bool _isProcessing = false;
///   String? _errorMessage;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('Deposit Bitcoin')),
///       body: Padding(
///         padding: const EdgeInsets.all(16.0),
///         child: SingleChildScrollView(
///           child: Column(
///             children: [
///               TextField(
///                 controller: _amountController,
///                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
///                 decoration: InputDecoration(
///                   labelText: const Text('Amount (BTC)'),
///                   hintText: 'e.g., 5.5',
///                   errorText: _errorMessage,
///                 ),
///               ),
///               const SizedBox(height: 24),
///               SizedBox(
///                 width: double.infinity,
///                 child: Consumer<WalletsProvider>(
///                   builder: (context, provider, _) {
///                     return ElevatedButton(
///                       onPressed: _isProcessing ? null : _handleDeposit,
///                       child: _isProcessing
///                           ? const SizedBox(
///                               height: 20,
///                               width: 20,
///                               child: CircularProgressIndicator(strokeWidth: 2),
///                             )
///                           : const Text('Confirm Deposit'),
///                     );
///                   },
///                 ),
///               ),
///             ],
///           ),
///         ),
///       ),
///     );
///   }
///
///   Future<void> _handleDeposit() async {
///     final amount = _amountController.text.trim();
///
///     // Validation
///     final error = WalletValidationUtil.getAmountErrorMessage(amount);
///     if (error.isNotEmpty) {
///       setState(() => _errorMessage = error);
///       return;
///     }
///
///     setState(() {
///       _isProcessing = true;
///       _errorMessage = null;
///     });
///
///     final provider = context.read<WalletsProvider>();
///     final result = await provider.deposit(
///       amount: amount,
///       currencyId: 1, // BTC
///       depositId: widget.depositId,
///     );
///
///     if (!mounted) return;
///
///     if (result != null) {
///       // Success
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(
///           content: Text('Deposit successful! New balance: ${result.newBalance.available} BTC'),
///           backgroundColor: Colors.green,
///         ),
///       );
///       Navigator.pop(context);
///     } else {
///       // Failed
///       setState(() => _errorMessage = provider.error);
///     }
///
///     setState(() => _isProcessing = false);
///   }
///
///   @override
///   void dispose() {
///     _amountController.dispose();
///     super.dispose();
///   }
/// }
/// ```
///
/// ### Ví Dụ 3: Đặt Lệnh Mua (Freeze Balance)
///
/// **Code:**
/// ```dart
/// Future<void> placeBuyOrder(
///   BuildContext context, {
///   required String amount,
///   required double price,
///   required int currencyId,
///   required int orderId,
/// }) async {
///   final provider = context.read<WalletsProvider>();
///
///   // Calculate total cost
///   final totalCost = (double.parse(amount) * price).toString();
///
///   // Validate amount
///   final error = WalletValidationUtil.validateTransactionRequest(
///     WalletTransactionRequest(
///       currencyId: currencyId,
///       amount: totalCost,
///       action: WalletTransactionAction.freeze,
///       refType: WalletReferenceType.order,
///       refId: orderId,
///     ),
///   );
///
///   if (error.isNotEmpty) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text('Validation error: $error')),
///     );
///     return;
///   }
///
///   // Freeze the balance
///   final result = await provider.freezeBalance(
///     amount: totalCost,
///     currencyId: currencyId,
///     orderId: orderId,
///   );
///
///   if (result != null) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       const SnackBar(
///         content: Text('Order placed! Money has been locked'),
///         backgroundColor: Colors.green,
///       ),
///     );
///   }
/// }
/// ```
///
/// ### Ví Dụ 4: Hủy Lệnh (Unfreeze Balance)
///
/// **Code:**
/// ```dart
/// Future<void> cancelOrder(
///   BuildContext context, {
///   required String frozenAmount,
///   required int currencyId,
///   required int orderId,
/// }) async {
///   final provider = context.read<WalletsProvider>();
///
///   final result = await provider.unfreezeBalance(
///     amount: frozenAmount,
///     currencyId: currencyId,
///     orderId: orderId,
///   );
///
///   if (result != null) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       const SnackBar(
///         content: Text('Order cancelled. Money has been unlocked'),
///         backgroundColor: Colors.green,
///       ),
///     );
///   }
/// }
/// ```
///
/// ### Ví Dụ 5: Chuyển Tiền (Transfer)
///
/// **Code:**
/// ```dart
/// Future<void> transferFunds(
///   BuildContext context, {
///   required String amount,
///   required int currencyId,
///   required int targetUserId,
///   required int transferId,
/// }) async {
///   final provider = context.read<WalletsProvider>();
///
///   final result = await provider.transfer(
///     amount: amount,
///     currencyId: currencyId,
///     transferId: transferId,
///     targetUserId: targetUserId,
///   );
///
///   if (result != null) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(
///         content: Text('Transfer successful! $amount transferred to User #$targetUserId'),
///         backgroundColor: Colors.green,
///       ),
///     );
///   }
/// }
/// ```
///
/// ---
///
/// ## ⚠️ Xử Lý Lỗi
///
/// ### Common Errors
///
/// **1. Validation Error (400)**
/// ```dart
/// // Amount validation
/// if (!WalletValidationUtil.isValidDecimalAmount(amount)) {
///   showError('Invalid amount format');
/// }
/// ```
///
/// **2. Insufficient Balance**
/// ```dart
/// final hasBalance = WalletValidationUtil.hasSufficientBalance(
///   available: balance.available,
///   required: amount,
/// );
/// if (!hasBalance) {
///   showError('Insufficient balance');
/// }
/// ```
///
/// **3. Network Error (Offline)**
/// ```dart
/// // The repository automatically returns cached balance if available
/// // If cache is also unavailable, it returns NetworkFailure
/// if (provider.state == WalletState.error &&
///     provider.error?.contains('Network') == true) {
///   showError('No internet connection. Using cached data.');
/// }
/// ```
///
/// **4. Authentication Error (401)**
/// ```dart
/// // Token service handles token refresh automatically
/// // If refresh fails, user is redirected to login
/// if (provider.error?.contains('Authentication') == true) {
///   Navigator.of(context).pushReplacementNamed('/login');
/// }
/// ```
///
/// ---
///
/// ## 🎯 Best Practices
///
/// ### 1. Always Validate Before Transaction
/// ```dart
/// final request = WalletTransactionRequest(...);
/// final validationError = WalletValidationUtil.validateTransactionRequest(request);
/// if (validationError.isNotEmpty) {
///   // Show error
///   return;
/// }
/// ```
///
/// ### 2. Use Decimal Strings for Amounts
/// ```dart
/// // ❌ WRONG
/// final amount = 5.5; // Double - precision loss
///
/// // ✅ RIGHT
/// final amount = '5.5'; // String - exact precision
/// ```
///
/// ### 3. Cache for Offline Support
/// ```dart
/// // WalletsProvider automatically caches balance
/// // If network is unavailable, cached data is returned
/// await provider.fetchBalance(currencyId: 1);
/// // If offline, cached data is shown instead
/// ```
///
/// ### 4. Handle Loading States
/// ```dart
/// if (provider.state == WalletState.loading) {
///   // Show loading indicator
///   return CircularProgressIndicator();
/// }
/// ```
///
/// ### 5. Implement Optimistic Updates
/// ```dart
/// // Update UI immediately after user action
/// setBalance(newBalance);
///
/// // Then call API
/// final result = await provider.deposit(...);
///
/// // If failed, rollback UI
/// if (result == null) {
///   setBalance(previousBalance);
/// }
/// ```
///
/// ### 6. Use Provider Methods for Common Operations
/// ```dart
/// // Instead of creating raw request:
/// // ❌ await provider.executeTransaction(...)
///
/// // Use helper methods:
/// // ✅ await provider.deposit(...)
/// // ✅ await provider.withdraw(...)
/// // ✅ await provider.freezeBalance(...)
/// // ✅ await provider.unfreezeBalance(...)
/// // ✅ await provider.transfer(...)
/// ```
///
/// ---
///
/// ## 📞 FAQ
///
/// **Q: Khi nào cần forceRefresh?**
/// A: Sử dụng forceRefresh=true khi muốn tải từ API, bỏ qua cache.
/// Thường dùng khi user swipe-to-refresh hoặc sau khi transaction thành công.
///
/// **Q: Làm thế nào để handle offline mode?**
/// A: Repository tự động return cached data nếu network error xảy ra.
/// Không cần code đặc biệt, caching được handle tự động.
///
/// **Q: Available vs Frozen balance là gì?**
/// A: Available = có thể dùng. Frozen = bị khóa (đang đặt lệnh).
/// Total = Available + Frozen
///
/// **Q: TRANSFER action khác DEBIT thế nào?**
/// A: DEBIT rút tiền ra khỏi hệ thống (rút ngoài).
/// TRANSFER chuyển tiền sang user khác (vẫn trong hệ thống).
///
/// ---
///
/// Bạn đã sẵn sàng tích hợp Wallet API. Chúc mừng! 🚀
///
library wallet_integration_guide;
