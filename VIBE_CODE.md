# Vibe Code — Flutter frontend

`VIBE_CODE.md` là chuẩn AI-assisted development của team FE. Tài liệu này là nguồn luật trung tâm cho Cursor, Claude Code và Codex CLI trong repo Flutter này.

## Workspace policy

- Chỉ mở **repo Flutter này** làm workspace, cùng cấp với `pubspec.yaml`, `lib/`, `.cursor/`.
- Không dùng parent monorepo như một workspace chung.
- Nếu task liên quan BE, tách thành task riêng và chuyển sang repo backend.

## Source of truth

- `ARCHITECTURE.md` — feature-first Clean Architecture / FSD
- `docs/security-zones.md` — vùng rủi ro bảo mật
- `docs/onboarding/day-1-setup.md` — setup ngày đầu
- `CONTRIBUTING-RULES.md` — conventions + PR process
- `README.md` — setup, cấu trúc, và cách chạy
- `.cursor/rules/` — rules theo ngữ cảnh
- `.cursor/AGENTS.md` — hướng dẫn Cursor
- `.claude/CLAUDE.md` — ngữ cảnh Claude Code
- `.codex/AGENTS.md` — ngữ cảnh Codex CLI
- `.agents/skills/` — skill Codex CLI

## Stack boundary

- Flutter / Dart only.
- Không thêm NestJS, SQL migrations, hoặc Node scripts vào repo này.
- API contract thay đổi phải phối hợp với team BE qua tài liệu / OpenAPI / rule `api-design`.

## Skill allowlist

Ưu tiên các skill phục vụ Flutter/Dart:

- `dart-flutter-patterns`
- `tdd-workflow`
- `security-review`
- `verification-loop`
- `documentation-lookup`
- `code-tour`
- `api-design` khi cần làm contract consumer

Nếu một skill không phục vụ Flutter/Dart thì không load mặc định.

## Architecture and SOLID

- Feature-first Clean Architecture với 4 lớp: domain, data, application, presentation.
- `domain/` không import Flutter, Dio, Hive, Firebase, hoặc local storage package.
- `data/` xử lý mapping, remote/local source, repository implementation.
- `application/` chứa use case, orchestration, và state logic.
- `presentation/` chỉ xử lý UI, widget state, và interaction.
- `lib/app/` giữ router, DI, app shell; `lib/core/` giữ infrastructure dùng chung.
- Ưu tiên bất biến, `Freezed`, và `Either<Failure, T>` cho flow nghiệp vụ.

## Quality gates

Trước khi coi xong:

- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `flutter analyze --fatal-infos`
- `dart run import_lint`
- `flutter test --coverage`

Widget mới nên có test cơ bản. Use case và repository mới nên có test riêng.

## Security rules

- Không lưu private key hoặc seed phrase trong SharedPreferences; dùng secure storage.
- Không log dữ liệu nhạy cảm như token, private key, hoặc address kèm balance.
- Luôn dùng `obscureText: true` cho input seed phrase.
- Luôn xác nhận trước các hành động tài chính như đặt lệnh hoặc rút/nạp.
- JWT phải được lưu an toàn và refresh qua interceptor.

## What not to do

- Không thêm code backend vào repo này.
- Không import package backend-only vào domain layer.
- Không dùng `Navigator.push(MaterialPageRoute(...))` khi `go_router` hoặc route shell đã đủ.
- Không commit `.env` hoặc secret thật.

## Optional upstream

Repo upstream ECC có thể dùng để đồng bộ máy cá nhân, nhưng không phải workflow mặc định của team. Ngày thường chỉ làm việc trong repo Flutter này.
