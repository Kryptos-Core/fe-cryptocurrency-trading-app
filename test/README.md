# Tests

- **Feature tests** — `test/features/<feature>/...` mirror `lib/features/<feature>/` (screens, presentation, domain, data, v.v.).
- **Core tests** — `test/core/...` for shared utils, services, constants.
- **Support fakes** — `test/support/` (stubs, empty repositories) dùng chung; import tương đối từ từng file test (ví dụ `../../../support/...`).

Widget và unit tests có thể import `package:crypto_trading_app/features/...` trực tiếp.

**Rào chặn import (CI):** `dart run import_lint` (cấu hình `import_analysis_options.yaml` ở root).
