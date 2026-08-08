# Backend–Frontend Error Code Contract

The frontend mirrors backend error codes. The sources of truth are the backend's `docs/ERROR_CODES.md` registry and `src/common/errors/error-codes.enum.ts`. Each backend code has a stable string value, an HTTP status, and a user-facing entry in `src/common/i18n/messages.ts` for both EN and VI, with optional `{vars}` interpolation.

## Adding a new error code

1. The BE team adds the code to `ErrorCode`, adds EN and VI messages in `messages.ts`, and records the code and HTTP status in `docs/ERROR_CODES.md`.
2. The FE developer reads the registry and adds the matching `apiError<PascalCase>` key to both `lib/core/l10n/app_en.arb` and `lib/core/l10n/app_vi.arb`.
3. Add the matching `case '<CODE>':` branch to the switch in `lib/core/utils/api_error_localizer.dart`.
4. Verify user-visible error surfaces call `localizeApiError(l10n, code: e.code, message: e.message)` for a `ServerException`; snackbars and toasts are not translated automatically.

If a backend code is missing from the switch, `localizeApiError` falls back to the server-provided message or `l10n.apiErrorGeneric`. This degrades gracefully, but every new code should still be mapped.
