---
applyTo: "**"
---

# VS Code / GitHub Copilot — Flutter repo (workspace = root repo này)

- **Mở folder:** thư mục gốc của **repo Flutter** (có `pubspec.yaml`) — không phụ thuộc monorepo cha.
- **Vibe Code (chuẩn team):** [VIBE_CODE.md](../VIBE_CODE.md).
- **Luật theo file:** `.github/instructions/*.instructions.md` — Copilot gộp khi `applyTo` khớp (glob tính từ root repo).
- **Nguồn chỉnh sửa:** `.cursor/rules/` rồi cập nhật mirror `.github/instructions/` **trong cùng repo** (`applyTo` khớp `globs`).
- **Lưu ý:** [gợi ý inline khi gõ](https://code.visualstudio.com/docs/copilot/ai-powered-suggestions) **không** dùng custom instructions; **Chat / Agent** mới dùng các file trên.
