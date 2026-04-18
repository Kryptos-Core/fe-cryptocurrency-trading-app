# `lib/shared/`

Thư mục **dự phòng** cho code **dùng chép nhiều feature** mà không muốn gán vào một feature cụ thể — ví dụ:

- Kiểu/trợ giúp domain nhỏ (không phải DTO của một API cụ thể).
- Widget/picker được tái dùng sau khi tách khỏi một feature.

**Không nhầm với `lib/core/`:** `core` chứa hạ tầng app (network, theme, formatter, widget atom), không gắn business vocabulary của một nghiệp vụ cụ thể. Chi tiết phân tầng: [`ARCHITECTURE.md`](../../ARCHITECTURE.md).

Hiện **chưa có file Dart** tại đây; UI chọn currency / cặp giao dịch vẫn chủ yếu trong `features/markets/presentation/widgets/`.
