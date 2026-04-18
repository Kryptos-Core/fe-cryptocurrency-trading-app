# Tests

- **Feature tests** — `test/features/<feature>/...` mirror `lib/features/<feature>/` (screens, presentation, providers, domain, data, …).
- **Core tests** — `test/core/...` — utils, services, constants shared.
- **Support fakes** — `test/support/` — stubs, empty repositories; import tương đối theo độ sâu (ví dụ `../../support/...` từ `test/features/home/`) hoặc `package:crypto_trading_app/...` khi phù hợp.

Widget và unit tests có thể import `package:crypto_trading_app/features/...` trực tiếp.

**Navigation / router:** app production dùng **`MaterialApp.router`** + `GoRouter`. Test chỉ pump `MainScreen` với `MaterialApp(home: ...)` có thể đủ nếu không gọi `context.push`; nếu test bấm control mở route, cần bọc **`MaterialApp.router`** + `createAppRouter` và đủ `Provider` như [`lib/app/app.dart`](../lib/app/app.dart).

**Rào chặn import (CI):** `dart run import_lint` — rules trong `import_analysis_options.yaml` ở root. Xem thêm [`ARCHITECTURE.md`](../ARCHITECTURE.md).
