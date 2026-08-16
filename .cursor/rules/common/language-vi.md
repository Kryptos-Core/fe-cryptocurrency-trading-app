# Ngôn ngữ phản hồi — Tiếng Việt có dấu (FE)

> Quy tắc bắt buộc cho mọi AI agent / assistant / sub-agent làm việc trong repo Flutter frontend này.
> Bản sao của rule gốc ở workspace root — đặt tại đây để áp dụng khi FE repo được mở độc lập.

## Nguyên tắc chính

Mọi **phản hồi, lập kế hoạch, tài liệu, thông điệp, commit message tiếng Việt, comment mô tả trong tài liệu `.md`, báo cáo review widget / UI / UX, walk-through kiến trúc Clean Architecture feature-first, hướng dẫn onboarding Flutter, RCA, post-mortem, v.v.** đều **BẮT BUỘC** dùng **tiếng Việt có dấu chuẩn chính tả**.

Áp dụng cho:

- Câu trả lời chat trực tiếp cho user.
- Mọi bản kế hoạch FE (`feature plan`, `widget refactor plan`, `state management migration`, `route plan`, `task_list`, v.v.).
- Mọi tài liệu Markdown trong repo (`README`, `ARCHITECTURE.md`, `VIBE_CODE.md`, `CONTRIBUTING-RULES.md`, `docs/security-zones.md`, runbook, ADR, RFC).
- Mô tả PR, commit message body, review note từ `code-reviewer` / `flutter-reviewer` / `dart-reviewer`.
- Output từ sub-agent (`planner`, `tdd-guide`, `e2e-runner`, `dart-build-resolver`).

## Phạm vi áp dụng

| Áp dụng | Không áp dụng |
|---------|---------------|
| Văn xuôi, giải thích, mô tả, câu hỏi, heading | Source code (identifier, class, widget, function, variable) |
| Comment giải thích bằng tiếng Việt trong file `.md` | Comment code (giữ tiếng Anh để codebase nhất quán) |
| Bảng biểu, danh sách, mục lục, narrative | Chuỗi log, error message runtime, console output |
| Thông điệp cho user / stakeholder | Tên file, tên thư mục, tên package, env var |
| Câu trả lời từ sub-agent | API name, route name, JSON key, Hive box, Socket.IO event |
| Tài liệu kỹ thuật (RFC, ADR, runbook) | Dart code, query SQL, regex pattern, CLI command |

## Quy tắc cụ thể

1. **Dấu thanh điệu là bắt buộc.** Ví dụ đúng: `lập kế hoạch`, `triển khai`, `kiểm thử`, `phản hồi`, `tài liệu`, `giao diện`, `ràng buộc`, `lỗi`, `cảnh báo`, `mục tiêu`, `đề xuất`, `thay đổi`, `quyết định`, `xử lý`, `màn hình`, `tiện ích`, `trạng thái`, `điều hướng`, `tương tác`, `hiển thị`, `cảnh báo`, `xác thực`, `phân quyền`, `ví`, `giao dịch`, `số dư`, `nạp`, `rút`, `chuyển`, `gửi nhận dữ liệu`. Không viết không dấu.

2. **Thuật ngữ kỹ thuật giữ nguyên tiếng Anh** — chèn trong câu tiếng Việt khi cần:
   - Flutter / Dart / Provider / GetIt / Dio / GoRouter / Hive / Socket.IO / WalletConnect / Reown AppKit.
   - `widget`, `scaffold`, `build`, `state`, `state management`, `bloc`, `provider`, `riverpod`, `notifier`, `stream`, `future`, `isolate`.
   - `feature`, `data layer`, `domain layer`, `application layer`, `presentation layer`, `repository`, `use case`, `entity`, `dto`, `mapper`.
   - `go_router`, `route`, `deep link`, `navigation`, `push`, `pop`, `guard`.
   - `Hive box`, `SharedPreferences`, `secure storage`, `Dio interceptor`, `Socket.IO event`.
   - `import_lint`, `flutter analyze`, `dart format`, `flutter test`, `coverage`.
   - `commit`, `pull request`, `merge`, `rebase`, `rollback`, `hotfix`, `refactor`, `sprint`, `backlog`.
   - `cold start`, `hot reload`, `hot restart`, `build runner`, `code generation`, `freezed`, `json_serializable`.

3. **Khi dịch / diễn giải tài liệu tiếng Anh** sang tiếng Việt, giữ nguyên tên riêng, tên thư viện, version, command. Ví dụ: `Flutter 3` không viết thành `Khung Flutter 3`. Không dịch các thuật ngữ chuẩn ngành đã có trong `ARCHITECTURE.md`.

4. **Số, mã lệnh, đường dẫn, URL, version giữ nguyên** dạng gốc — không Việt hóa.

5. **Dấu câu tiếng Việt**: dùng đúng chuẩn. Tránh viết tắt kiểu `ko`, `dc`, `vs`, `j` — thay bằng `không`, `được`, `và`/`so với` trong văn xuôi.

6. **Không trộn ngôn ngữ câu** một cách tùy tiện. Câu tiếng Việt phải có cấu trúc tiếng Việt; chỉ chèn thuật ngữ Anh khi cần thiết.

7. **Thuật ngữ nghiệp vụ crypto/UI** ưu tiên giữ Anh: `wallet`, `swap`, `bridge`, `on-ramp`, `off-ramp`, `approval`, `allowance`, `gas`, `nonce`, `tx hash`, `chain id`, `token`. Nếu phải diễn giải thì ghi Anh trước rồi giải thích tiếng Việt trong ngoặc.

## Khi nào dùng tiếng Anh

- User chủ động yêu cầu phản hồi bằng tiếng Anh (`trả lời bằng tiếng Anh`, `English please`).
- Output là source code, config, schema, migration, query — những thứ không phải văn xuôi.
- Tên file, tên thư mục, identifier, route URL, env var, Hive box name.
- Khi trích dẫn nguyên văn từ tài liệu / spec / RFC tiếng Anh.

## Kiểm tra nhanh trước khi gửi phản hồi

- [ ] Văn xuôi tiếng Việt có đầy đủ dấu thanh điệu.
- [ ] Thuật ngữ Flutter / Dart / crypto đã giữ đúng dạng tiếng Anh phổ biến trong ngành.
- [ ] Không lẫn câu tiếng Anh dài trong đoạn tiếng Việt (trừ khi trích dẫn).
- [ ] Tiêu đề heading đã Việt hóa (nếu là tài liệu hướng dẫn nội bộ).
- [ ] Source code, identifier, route, env var, Hive box không bị Việt hóa.
- [ ] Thuật ngữ Clean Architecture (`feature`, `data/domain/application/presentation`, `repository`, `use case`) khớp với `ARCHITECTURE.md`.

## Lý do áp dụng

- Người dùng và team frontend là người Việt, dấu thanh điệu là chuẩn giao tiếp chính thức.
- Viết không dấu gây mơ hồ nghĩa, khó đọc, giảm chất lượng tài liệu kỹ thuật.
- Duy trì nhất quán ngôn ngữ trong cả hệ thống tài liệu FE (`ARCHITECTURE.md`, `VIBE_CODE.md`, `CONTRIBUTING-RULES.md`, PR body, commit message, review note).
- Thuật ngữ tiếng Anh giữ nguyên giúp tra cứu nhanh, tránh dịch sai kỹ thuật cho các feature nhạy cảm (`wallet`, `auth`, `payments`, `trading`, `on-ramp`).
