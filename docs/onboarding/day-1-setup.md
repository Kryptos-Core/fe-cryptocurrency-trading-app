# Onboarding Flutter — Ngày 1

Chào mừng đến team FE! Tài liệu này giúp bạn setup môi trường và vibe code trong ngày đầu.

## 1. Clone và Setup

```bash
# Clone repo FE (không cần clone monorepo cha)
git clone <fe-repo-url>
cd fe-cryptocurrency-trading-app

# Kiểm tra Flutter version
flutter --version
# Yêu cầu: Flutter >= 3.0.0

# Cài dependencies
flutter pub get

# Tạo file .env từ template
cp .env.example .env
# Hỏi Tech Lead để lấy giá trị cho API_BASE_URL, WS_URL

# Kiểm tra project build được
flutter analyze
flutter test
```

## 2. Cài IDE

### Cursor (Khuyến nghị — có ECC tích hợp)

1. Tải [Cursor](https://cursor.sh)
2. `File → Open Folder` → chọn thư mục `fe-cryptocurrency-trading-app/` (cùng cấp `pubspec.yaml`)
3. Cursor tự load `.cursor/rules/` và `.cursor/hooks/` — không cần cấu hình thêm
4. Cài extensions: Dart, Flutter (từ Dart Code team)

### VS Code (Alternative)

1. Tải VS Code
2. Mở đúng folder `fe-cryptocurrency-trading-app/`
3. Cài extensions: Dart, Flutter
4. Rules Cursor không apply trong VS Code — nhưng CLAUDE.md và AGENTS.md vẫn có ích

### Claude Code (CLI)

```bash
npm install -g @anthropic-ai/claude-code
cd fe-cryptocurrency-trading-app
claude   # Đọc .claude/CLAUDE.md tự động
```

## 3. Cấu trúc Dự án (5 phút)

```
lib/
├── core/           # Shared (DI, constants, network, services)
├── data/           # Data layer (API calls, local storage)
├── domain/         # Business logic (entities, use cases, abstract repos)
├── presentation/   # UI (providers, widgets)
└── screens/        # Screens hiện có
```

**Quy tắc vàng:** `domain/` không được import Flutter hoặc Dio. Logic nghiệp vụ sống ở đây.

## 4. Chạy App

```bash
# Kết nối thiết bị hoặc bật emulator trước
flutter devices

# Chạy development
flutter run

# Chạy với env cụ thể
flutter run --dart-define-from-file=.env
```

## 5. Task đầu tiên

Sau khi setup xong, hỏi Tech Lead để được assign task "Good First Issue" — thường là:
- Fix UI bug nhỏ
- Thêm localization key mới
- Viết widget test cho component có sẵn

## 6. Hỏi gì thì hỏi ở đâu

- Technical: channel `#fe-dev` trên Slack/Discord team
- Urgent/blocking: tag Tech Lead FE trực tiếp
- Review PR: assign ít nhất 1 người trong team FE
