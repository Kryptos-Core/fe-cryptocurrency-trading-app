param([string[]]$Roots = @("lib", "test"))
$r = [ordered]@{}
# Entities / blockchain / managed_wallet (must be early)
$r['package:crypto_trading_app/domain/entities/blockchain/'] = 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/'
$r['package:crypto_trading_app/domain/entities/managed_wallet/'] = 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/'
$r['package:crypto_trading_app/domain/facades/trading_facade.dart'] = 'package:crypto_trading_app/features/trading/application/services/trading_facade.dart'
$r['package:crypto_trading_app/domain/models/system_config.dart'] = 'package:crypto_trading_app/features/settings/domain/models/system_config.dart'
$r['package:crypto_trading_app/domain/models/runtime_setting_row.dart'] = 'package:crypto_trading_app/features/settings/domain/models/runtime_setting_row.dart'
# Domain repositories
$r['package:crypto_trading_app/domain/repositories/currencies_repository.dart'] = 'package:crypto_trading_app/features/markets/domain/repositories/currencies_repository.dart'
$r['package:crypto_trading_app/domain/repositories/markets_repository.dart'] = 'package:crypto_trading_app/features/markets/domain/repositories/markets_repository.dart'
$r['package:crypto_trading_app/domain/repositories/exchange_rate_repository.dart'] = 'package:crypto_trading_app/features/markets/domain/repositories/exchange_rate_repository.dart'
$r['package:crypto_trading_app/domain/repositories/deposit_repository.dart'] = 'package:crypto_trading_app/features/deposits/domain/repositories/deposit_repository.dart'
$r['package:crypto_trading_app/domain/repositories/notification_repository.dart'] = 'package:crypto_trading_app/features/notifications/domain/repositories/notification_repository.dart'
$r['package:crypto_trading_app/domain/repositories/managed_wallets_repository.dart'] = 'package:crypto_trading_app/features/managed_wallets/domain/repositories/managed_wallets_repository.dart'
$r['package:crypto_trading_app/domain/repositories/blockchain_repository.dart'] = 'package:crypto_trading_app/features/blockchain/domain/repositories/blockchain_repository.dart'
# Domain entities (single files)
$r['package:crypto_trading_app/domain/entities/currency.dart'] = 'package:crypto_trading_app/features/markets/domain/entities/currency.dart'
$r['package:crypto_trading_app/domain/entities/market_pair.dart'] = 'package:crypto_trading_app/features/markets/domain/entities/market_pair.dart'
$r['package:crypto_trading_app/domain/entities/market_price.dart'] = 'package:crypto_trading_app/features/markets/domain/entities/market_price.dart'
$r['package:crypto_trading_app/domain/entities/exchange_rate_preview.dart'] = 'package:crypto_trading_app/features/markets/domain/entities/exchange_rate_preview.dart'
$r['package:crypto_trading_app/domain/entities/deposit.dart'] = 'package:crypto_trading_app/features/deposits/domain/entities/deposit.dart'
$r['package:crypto_trading_app/domain/entities/notification_entity.dart'] = 'package:crypto_trading_app/features/notifications/domain/entities/notification_entity.dart'
$r['package:crypto_trading_app/domain/entities/order.dart'] = 'package:crypto_trading_app/features/orders/domain/entities/order.dart'
$r['package:crypto_trading_app/domain/entities/order_book_level.dart'] = 'package:crypto_trading_app/features/orders/domain/entities/order_book_level.dart'
$r['package:crypto_trading_app/domain/entities/user.dart'] = 'package:crypto_trading_app/features/user/domain/entities/user.dart'
$r['package:crypto_trading_app/domain/entities/user_security_change.dart'] = 'package:crypto_trading_app/features/user/domain/entities/user_security_change.dart'
$r['package:crypto_trading_app/domain/entities/wallet.dart'] = 'package:crypto_trading_app/features/wallets/domain/entities/wallet.dart'
$r['package:crypto_trading_app/domain/entities/wallet_balance.dart'] = 'package:crypto_trading_app/features/wallets/domain/entities/wallet_balance.dart'
$r['package:crypto_trading_app/domain/entities/wallet_transaction.dart'] = 'package:crypto_trading_app/features/wallets/domain/entities/wallet_transaction.dart'
$r['package:crypto_trading_app/domain/entities/admin_wallet_adjustment.dart'] = 'package:crypto_trading_app/features/admin/wallet_adjust/domain/entities/admin_wallet_adjustment.dart'
# Data datasources
$r['package:crypto_trading_app/data/datasources/auth_remote_datasource.dart'] = 'package:crypto_trading_app/features/auth/data/datasources/auth_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/user_remote_datasource.dart'] = 'package:crypto_trading_app/features/user/data/datasources/user_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/currencies_remote_datasource.dart'] = 'package:crypto_trading_app/features/markets/data/datasources/currencies_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/markets_remote_datasource.dart'] = 'package:crypto_trading_app/features/markets/data/datasources/markets_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/exchange_remote_datasource.dart'] = 'package:crypto_trading_app/features/markets/data/datasources/exchange_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/dashboard_remote_datasource.dart'] = 'package:crypto_trading_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/deposit_remote_datasource.dart'] = 'package:crypto_trading_app/features/deposits/data/datasources/deposit_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/notification_remote_datasource.dart'] = 'package:crypto_trading_app/features/notifications/data/datasources/notification_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/treasury_remote_datasource.dart'] = 'package:crypto_trading_app/features/treasury/data/datasources/treasury_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/market_maker_remote_datasource.dart'] = 'package:crypto_trading_app/features/admin/market_maker/data/datasources/market_maker_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/payment_config_remote_datasource.dart'] = 'package:crypto_trading_app/features/admin/payment_config/data/datasources/payment_config_remote_datasource.dart'
$r['package:crypto_trading_app/data/datasources/withdrawal_admin_remote_datasource.dart'] = 'package:crypto_trading_app/features/admin/withdrawal_management/data/datasources/withdrawal_admin_remote_datasource.dart'
# Data repositories
$r['package:crypto_trading_app/data/repositories/currencies_repository_impl.dart'] = 'package:crypto_trading_app/features/markets/data/repositories/currencies_repository_impl.dart'
$r['package:crypto_trading_app/data/repositories/markets_repository_impl.dart'] = 'package:crypto_trading_app/features/markets/data/repositories/markets_repository_impl.dart'
$r['package:crypto_trading_app/data/repositories/exchange_rate_repository_impl.dart'] = 'package:crypto_trading_app/features/markets/data/repositories/exchange_rate_repository_impl.dart'
$r['package:crypto_trading_app/data/repositories/deposit_repository_impl.dart'] = 'package:crypto_trading_app/features/deposits/data/repositories/deposit_repository_impl.dart'
$r['package:crypto_trading_app/data/repositories/notification_repository_impl.dart'] = 'package:crypto_trading_app/features/notifications/data/repositories/notification_repository_impl.dart'
$r['package:crypto_trading_app/data/repositories/blockchain_repository_impl.dart'] = 'package:crypto_trading_app/features/blockchain/data/repositories/blockchain_repository_impl.dart'
$r['package:crypto_trading_app/data/repositories/managed_wallets_repository_impl.dart'] = 'package:crypto_trading_app/features/managed_wallets/data/repositories/managed_wallets_repository_impl.dart'
$r['package:crypto_trading_app/data/repositories/system_config_repository.dart'] = 'package:crypto_trading_app/features/settings/data/repositories/system_config_repository.dart'
# Data models — batch by prefix is unsafe; list common
$models = @{
  'auth_response_model.dart' = 'features/auth/data/models/auth_response_model.dart'
  'user_model.dart' = 'features/user/data/models/user_model.dart'
  'currency_model.dart' = 'features/markets/data/models/currency_model.dart'
  'currency_model.g.dart' = 'features/markets/data/models/currency_model.g.dart'
  'market_pair_model.dart' = 'features/markets/data/models/market_pair_model.dart'
  'market_pair_model.g.dart' = 'features/markets/data/models/market_pair_model.g.dart'
  'paginated_currencies_response.dart' = 'features/markets/data/models/paginated_currencies_response.dart'
  'paginated_currencies_response.g.dart' = 'features/markets/data/models/paginated_currencies_response.g.dart'
  'paginated_markets_response.dart' = 'features/markets/data/models/paginated_markets_response.dart'
  'paginated_markets_response.g.dart' = 'features/markets/data/models/paginated_markets_response.g.dart'
  'trade_model.dart' = 'features/markets/data/models/trade_model.dart'
  'trade_model.g.dart' = 'features/markets/data/models/trade_model.g.dart'
  'ohlcv_response.dart' = 'features/markets/data/models/ohlcv_response.dart'
  'ohlcv_response.g.dart' = 'features/markets/data/models/ohlcv_response.g.dart'
  'rate_preview_model.dart' = 'features/markets/data/models/rate_preview_model.dart'
  'market_price_model.dart' = 'features/markets/data/models/market_price_model.dart'
  'create_currency_dto.dart' = 'features/markets/data/models/create_currency_dto.dart'
  'create_currency_dto.g.dart' = 'features/markets/data/models/create_currency_dto.g.dart'
  'create_market_pair_dto.dart' = 'features/markets/data/models/create_market_pair_dto.dart'
  'create_market_pair_dto.g.dart' = 'features/markets/data/models/create_market_pair_dto.g.dart'
  'update_currency_dto.dart' = 'features/markets/data/models/update_currency_dto.dart'
  'update_currency_dto.g.dart' = 'features/markets/data/models/update_currency_dto.g.dart'
  'update_market_pair_dto.dart' = 'features/markets/data/models/update_market_pair_dto.dart'
  'update_market_pair_dto.g.dart' = 'features/markets/data/models/update_market_pair_dto.g.dart'
  'order_model.dart' = 'features/orders/data/models/order_model.dart'
  'create_order_request_dto.dart' = 'features/orders/data/models/create_order_request_dto.dart'
  'order_book_level_model.dart' = 'features/markets/data/models/order_book_level_model.dart'
  'deposit_model.dart' = 'features/deposits/data/models/deposit_model.dart'
  'dashboard_summary_model.dart' = 'features/dashboard/data/models/dashboard_summary_model.dart'
  'notification_model.dart' = 'features/notifications/data/models/notification_model.dart'
  'treasury_model.dart' = 'features/treasury/data/models/treasury_model.dart'
  'chain_picker_options_model.dart' = 'features/treasury/data/models/chain_picker_options_model.dart'
  'chain_network_catalog_item_model.dart' = 'features/treasury/data/models/chain_network_catalog_item_model.dart'
  'market_maker_config_model.dart' = 'features/admin/market_maker/data/models/market_maker_config_model.dart'
  'market_maker_form_defaults_model.dart' = 'features/admin/market_maker/data/models/market_maker_form_defaults_model.dart'
  'payment_method_config_model.dart' = 'features/admin/payment_config/data/models/payment_method_config_model.dart'
  'exchange_sync_result.dart' = 'features/admin/payment_config/data/models/exchange_sync_result.dart'
  'admin_enums_snapshot.dart' = 'features/admin/payment_config/data/models/admin_enums_snapshot.dart'
  'admin_withdrawal_model.dart' = 'features/admin/withdrawal_management/data/models/admin_withdrawal_model.dart'
  'admin_wallet_adjustment_model.dart' = 'features/admin/wallet_adjust/data/models/admin_wallet_adjustment_model.dart'
  'wallet_model.dart' = 'features/wallets/data/models/wallet_model.dart'
  'wallet_model.g.dart' = 'features/wallets/data/models/wallet_model.g.dart'
  'wallet_balance_model.dart' = 'features/wallets/data/models/wallet_balance_model.dart'
  'wallet_balance_model.g.dart' = 'features/wallets/data/models/wallet_balance_model.g.dart'
  'wallet_transaction_model.dart' = 'features/wallets/data/models/wallet_transaction_model.dart'
  'wallet_transaction_model.g.dart' = 'features/wallets/data/models/wallet_transaction_model.g.dart'
}
foreach ($kv in $models.GetEnumerator()) {
  $old = "package:crypto_trading_app/data/models/$($kv.Key)"
  $new = "package:crypto_trading_app/$($kv.Value)"
  $r[$old] = $new
}

foreach ($root in $Roots) {
  if (-not (Test-Path $root)) { continue }
  Get-ChildItem $root -Recurse -Filter "*.dart" -File | ForEach-Object {
    $path = $_.FullName
    $c = Get-Content $path -Raw -Encoding UTF8
    $n = $c
    foreach ($k in $r.Keys) {
      $n = $n.Replace([string]$k, [string]$r[$k])
    }
    if ($n -ne $c) {
      [System.IO.File]::WriteAllText($path, $n, [System.Text.UTF8Encoding]::new($false))
    }
  }
}
