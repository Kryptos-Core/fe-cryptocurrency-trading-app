# Kryptos Core (Flutter) — Kiến trúc ứng dụng

Ứng dụng **crypto_trading_app** tổ chức theo **Clean Architecture feature-first**, 4 lớp trong mỗi feature (`data` / `domain` / `application` / `presentation`), nền tảng **Android · iOS · Windows · Web** qua Flutter; mạng **Dio + Socket.IO**, DI **GetIt**, state UI **Provider**.

## Luồng phụ thuộc (tóm tắt)

```
presentation (screens, providers, widgets)
       ↓
application (usecases, facade / orchestration services)
       ↓
domain (entities, repository contracts)
       ↑
data (datasources, DTO/models, repository impl)
       ↓
core (network, error, responsive, theme, localization, widgets chung)
```

- **`sl` (`get_it`)**: singleton — `DioClient`, repositories, một số `ChangeNotifier`.
- **`provider`**: `MultiProvider` trong [`lib/app/app.dart`](lib/app/app.dart).

## Cấu trúc `lib/` (snapshot)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── bootstrap/
│   ├── di/injection_container.dart      # Composition root GetIt
│   └── router/app_routes.dart           # Hằng tab shell / đường gốc
├── core/
│   ├── constants/
│   ├── network/
│   ├── error/
│   ├── localization/
│   ├── theme/
│   ├── responsive/
│   ├── widgets/                       # Atom UI dùng chung
│   ├── gen_l10n/                     # codegen — không sửa tay
│   └── l10n/                         # *.arb
└── features/
    ├── auth/
    ├── home/
    ├── dashboard/
    ├── markets/
    ├── trading/
    ├── wallets/
    ├── orders/
    ├── deposits/
    ├── withdrawals/
    ├── blockchain/
    ├── managed_wallets/
    ├── treasury/
    ├── notifications/
    ├── profile/
    ├── settings/
    ├── user/                          # Entity user + datasource dùng chéo (admin/profile)
    └── admin/                       # users, transactions, currencies, markets, wallet_adjust,
                                    # security_requests, broadcast, payment_config,
                                    # withdrawal_management, market_maker, fiat_withdrawals, …
```

Mỗi feature có thể có đủ `data/` · `domain/` · `application/` · `presentation/` (feature “mỏng” có thể không có `data/`).

## Đa nền tảng & responsive

- Phân nhánh native **conditional import**: ví dụ [`lib/core/utils/checkout_tab_preopen.dart`](lib/core/utils/checkout_tab_preopen.dart), wallet auth connectors trong [`lib/core/wallet_auth/`](lib/core/wallet_auth/).
- Layout: [`lib/core/responsive/app_responsive.dart`](lib/core/responsive/app_responsive.dart).

## i18n

ARB: [`lib/core/l10n/`](lib/core/l10n/) · cấu hình [`l10n.yaml`](l10n.yaml) (`arb-dir`, `output-dir`: `lib/core/gen_l10n`). Chạy codegen: `flutter gen-l10n`.

## Kiểm thử

Thư mục [`test/`](test/) đang chứa widget/unit tests theo nhóm chức năng; import trỏ trực tiếp `package:crypto_trading_app/features/...`.
