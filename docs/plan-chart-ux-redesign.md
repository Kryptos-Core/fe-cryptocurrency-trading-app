# Plan: Thiết kế lại UI/UX biểu đồ Market Detail

> **Ngày tạo**: 2026-04-15
> **Trạng thái**: DRAFT - Chờ xác nhận
> **Phạm vi**: Tab "Biểu đồ" (Lightweight Charts) + Tab "Pro Chart" (TradingView Widget)
> **Tệp chính bị ảnh hưởng**: 6 tệp

---

## 1. Tóm tắt vấn đề hiện tại

### 1.1 Scroll bị xung đột (CẢ 2 TAB)

**Vấn đề**: Khi chuột đang focus vào biểu đồ và người dùng scroll (hoặc Ctrl+Scroll), trang vẫn bị cuộn lên/xuống, làm mất biểu đồ khỏi viewport.

**Nguyên nhân gốc (Flutter side)**:
- Biểu đồ nằm trong `SingleChildScrollView` ([market_detail_screen.dart:256](lib/screens/market_detail_screen.dart#L256))
- Flutter không tự động chặn scroll event khi con trỏ nằm trên WebView
- WebView (`webview_windows`) không tự capture mouse wheel event

**Nguyên nhân gốc (HTML side)**:
- Tab Lightweight Charts: `handleScroll: false, handleScale: false` ([lightweight_chart.html:231-232](assets/lightweight_chart.html#L231)) — biểu đồ hoàn toàn tĩnh, không xử lý scroll
- Tab Pro Chart: TradingView widget tự xử lý zoom bên trong iframe, nhưng event vẫn bubble lên Flutter WebView → `SingleChildScrollView`

### 1.2 Chú thích (Legend/Overlay) che nội dung biểu đồ

**Vấn đề**: Overlay info (tên cặp, interval, số nến) nằm đè lên góc trái trên biểu đồ, che mất một phần candlestick.

**Nguyên nhân**:
- Tab Lightweight Charts: `div.overlay-info` có `position: absolute; top: 14px; left: 14px` ([lightweight_chart.html:19-33](assets/lightweight_chart.html#L19)) với `min-width: 220px`, padding lớn, che ~15% diện tích biểu đồ
- Tab Pro Chart: `hide_legend: false` ([tradingview_pro_chart_html.dart:84](lib/core/utils/tradingview_pro_chart_html.dart#L84))

### 1.3 Chú thích bị zoom theo biểu đồ (Pro Chart)

**Vấn đề**: Khi Ctrl+Scroll phóng to/thu nhỏ Pro Chart, legend/toolbar cũng bị phóng to/thu nhỏ theo, gây khó chịu và khó đọc.

**Nguyên nhân**: TradingView widget nằm hoàn toàn trong WebView — khi WebView bị zoom (do Ctrl+Scroll), toàn bộ nội dung bên trong (bao gồm legend, toolbar) đều bị scale. Đây là zoom ở cấp WebView (browser zoom), không phải chart zoom.

### 1.4 Chỉ có crosshair dọc, thiếu crosshair ngang

**Vấn đề**: Khi hover vào biểu đồ chỉ thấy đường dọc (vertical crosshair), không có đường ngang (horizontal crosshair) để xem giá tại vị trí con trỏ.

**Nguyên nhân**:
- Tab Lightweight Charts: Không có cấu hình crosshair ([lightweight_chart.html](assets/lightweight_chart.html)) — mặc định Lightweight Charts v4.1 chỉ hiện crosshair khi `handleScroll`/`handleScale` enabled
- Tab Pro Chart: TradingView widget mặc định có crosshair đầy đủ, nhưng có thể bị ảnh hưởng bởi `disabled_features`

---

## 2. Giải pháp thiết kế

### Nguyên tắc thiết kế

| Nguyên tắc | Áp dụng |
|-------------|---------|
| **Scroll isolation** | Biểu đồ phải "nuốt" scroll event khi chuột nằm trên nó |
| **Zoom = chart zoom, không phải browser zoom** | Ctrl+Scroll phải zoom nội dung biểu đồ, không zoom toàn bộ WebView |
| **Legend không che nội dung** | Chú thích phải nhỏ gọn, trong suốt, hoặc nằm ngoài vùng biểu đồ |
| **Legend không bị scale** | Legend phải giữ kích thước cố định bất kể zoom level |
| **Crosshair đầy đủ** | Cả đường dọc lẫn đường ngang khi hover |

---

## 3. Kế hoạch triển khai chi tiết

### Phase 1: Fix scroll isolation (Flutter side)

**Tệp**: `lib/screens/market_detail_screen.dart`

**Thay đổi**:

1. **Wrap biểu đồ WebView bằng `Listener` + disable `SingleChildScrollView` khi chuột nằm trên biểu đồ**:

```
Giải pháp: Sử dụng MouseRegion + ScrollController để chặn scroll event
khi con trỏ nằm trên vùng biểu đồ.

Cụ thể:
- Thêm state `_isHoveringChart` vào _TradingChartWidget (chuyển từ StatelessWidget → StatefulWidget)
- Wrap SizedBox chứa TabBarView bằng MouseRegion(onEnter/onExit)
- Khi _isHoveringChart == true: wrap bằng Listener(onPointerSignal: absorb scroll)
  hoặc dùng NotificationListener<ScrollNotification> để chặn
```

**Cách tiếp cận cụ thể**:
```dart
// Pseudocode
MouseRegion(
  onEnter: (_) => setState(() => _isHoveringChart = true),
  onExit: (_) => setState(() => _isHoveringChart = false),
  child: Listener(
    onPointerSignal: (event) {
      if (_isHoveringChart && event is PointerScrollEvent) {
        // Chặn event không cho bubble lên SingleChildScrollView
        // Forward scroll event xuống WebView thông qua JS
      }
    },
    child: SizedBox(
      height: 520,
      child: TabBarView(...)
    ),
  ),
)
```

**Độ phức tạp**: MEDIUM
**Rủi ro**: Cần test kỹ trên Windows — `webview_windows` có thể không forward PointerSignal tự động

---

### Phase 2: Bật tương tác cho Lightweight Charts (Tab 1)

**Tệp**: `assets/lightweight_chart.html`

**Thay đổi**:

1. **Bật scroll/zoom cho biểu đồ**:
```javascript
// TRước:
handleScroll: false,
handleScale: false,

// SAU:
handleScroll: { mouseWheel: true, pressedMouseMove: true },
handleScale: { mouseWheel: true, pinchToZoom: true, axisPressedMouseMove: true },
```

2. **Thêm crosshair configuration đầy đủ** (cả dọc + ngang):
```javascript
crosshair: {
  mode: LightweightCharts.CrosshairMode.Normal,
  vertLine: {
    color: 'rgba(99, 102, 241, 0.4)',
    width: 1,
    style: LightweightCharts.LineStyle.Dashed,
    labelVisible: true,
    labelBackgroundColor: '#6366f1',
  },
  horzLine: {
    color: 'rgba(99, 102, 241, 0.4)',
    width: 1,
    style: LightweightCharts.LineStyle.Dashed,
    labelVisible: true,
    labelBackgroundColor: '#6366f1',
  },
},
```

3. **Chặn browser-level zoom (Ctrl+Scroll) trong WebView**:
```javascript
// Thêm vào cuối script:
document.addEventListener('wheel', (e) => {
  if (e.ctrlKey) {
    e.preventDefault(); // Chặn browser zoom
    // Lightweight Charts đã xử lý zoom qua handleScale
  }
}, { passive: false });
```

4. **Thêm nút reset zoom** (double-click hoặc nút):
```javascript
// Double-click để reset view
container.addEventListener('dblclick', () => {
  const timeScale = ChartState.chart.timeScale();
  timeScale.fitContent();
});
```

Expose thêm API:
```javascript
window.LWChartAPI.resetZoom = () => {
  ChartState.chart.timeScale().fitContent();
};
```

**Độ phức tạp**: LOW-MEDIUM
**Rủi ro**: LOW — Lightweight Charts API có sẵn các option này

---

### Phase 3: Redesign overlay info (Tab 1 - Lightweight Charts)

**Tệp**: `assets/lightweight_chart.html`

**Thay đổi**: Thiết kế lại overlay info để không che biểu đồ

**Phương án chọn: Compact inline bar phía trên biểu đồ**

```
Thay vì overlay đè lên biểu đồ, chuyển sang thanh thông tin nhỏ gọn
nằm TRÊN biểu đồ (không overlap).

Layout mới:
┌─────────────────────────────────────────┐
│ BTC/USDT  │ 1m │ 500 nến │ OHLC hover  │  ← Compact bar (24px high)
├─────────────────────────────────────────┤
│                                         │
│           CANDLESTICK CHART             │  ← Chiều cao đầy đủ
│                                         │
│   ── volume bars ──                     │
└─────────────────────────────────────────┘
```

**CSS thay đổi**:
```css
/* XÓA: overlay-info absolute positioning */
/* THÊM: compact top bar */
.chart-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 4px 12px;
  font-size: 12px;
  background: #f8f9fc;
  border-bottom: 1px solid rgba(0,0,0,0.06);
  height: 28px;
  flex-shrink: 0;
}
```

**HTML thay đổi**:
```html
<!-- Layout mới -->
<div id="chart-wrapper" style="display:flex;flex-direction:column;height:100%">
  <div class="chart-header" id="chart-info">
    <span class="pair-name" id="pair-name">--</span>
    <span class="separator">│</span>
    <span class="stat-value" id="interval-info">1m</span>
    <span class="separator">│</span>
    <span class="stat-value" id="candle-count">0</span> nến
    <span class="separator">│</span>
    <span id="ohlc-hover" class="ohlc-hover"></span>
  </div>
  <div id="chart-container" style="flex:1;min-height:0"></div>
</div>
```

**Thêm OHLC hover info**: Khi di chuột qua nến, hiện O/H/L/C/V trên thanh header thay vì tooltip che biểu đồ:
```javascript
ChartState.chart.subscribeCrosshairMove((param) => {
  const ohlcEl = document.getElementById('ohlc-hover');
  if (!param || !param.seriesData || param.seriesData.size === 0) {
    ohlcEl.textContent = '';
    return;
  }
  const data = param.seriesData.get(ChartState.candlestickSeries);
  if (data) {
    ohlcEl.textContent =
      `O: ${data.open}  H: ${data.high}  L: ${data.low}  C: ${data.close}`;
  }
});
```

**Độ phức tạp**: MEDIUM
**Rủi ro**: LOW — chỉ thay đổi HTML/CSS/JS, không ảnh hưởng logic Flutter

---

### Phase 4: Fix Pro Chart — ngăn browser zoom + legend

**Tệp**: `lib/core/utils/tradingview_pro_chart_html.dart`

**Thay đổi**:

1. **Chặn Ctrl+Scroll browser zoom** (để TradingView tự xử lý chart zoom):
```javascript
// Thêm vào HTML trước khi tạo widget:
document.addEventListener('wheel', function(e) {
  if (e.ctrlKey) {
    e.preventDefault();
  }
}, { passive: false });

// Chặn Ctrl+Plus/Minus browser zoom
document.addEventListener('keydown', function(e) {
  if (e.ctrlKey && (e.key === '+' || e.key === '-' || e.key === '=')) {
    e.preventDefault();
  }
});
```

2. **Ẩn/thu gọn legend TradingView** (tránh che nội dung):
```javascript
// Thay đổi options:
hide_legend: true,           // Ẩn legend để không che biểu đồ
hide_top_toolbar: false,     // Giữ toolbar để user vẫn điều khiển được

// HOẶC nếu muốn giữ legend nhưng không chiếm diện tích:
// Dùng disabled_features để collapse legend mặc định
disabled_features: [
  'use_localstorage_for_settings',
  'legend_inplace_edit',     // Không cho sửa legend inline
],
enabled_features: [
  'collapse_sidebar',         // Cho phép collapse sidebar
],
```

3. **Đảm bảo crosshair đầy đủ** (dọc + ngang):
```javascript
// TradingView widget mặc định có crosshair đầy đủ
// Đảm bảo không disable qua disabled_features
// Kiểm tra: không có 'header_indicators' hay 'hide_resolution_in_legend' trong disabled_features
```

**Độ phức tạp**: LOW
**Rủi ro**: LOW — TradingView widget API có sẵn các option này

---

### Phase 5: Fix Pro Chart — ngăn WebView zoom ở cấp Flutter

**Tệp**: `lib/screens/market_detail_screen.dart` (widget `_ProChartTab`)

**Thay đổi**:

Hiện tại `_ProChartTab` dùng `WebviewController` trực tiếp. Cần đảm bảo WebView không tự zoom khi nhận Ctrl+Scroll:

```dart
// Trong _ProChartTabState, sau khi controller initialize:
// Tắt WebView built-in zoom
await _webCtrl.setZoomFactor(1.0); // nếu API hỗ trợ

// HOẶC: Inject JS ngay sau page load để chặn browser zoom
await _webCtrl.executeScript('''
  document.addEventListener('wheel', function(e) {
    if (e.ctrlKey) e.preventDefault();
  }, { passive: false });
''');
```

Ngoài ra, kiểm tra `webview_windows` có API `setZoomFactor` hoặc `isZoomControlEnabled`:
```dart
// webview_windows ^0.4.0 — kiểm tra có method nào:
// _webCtrl.setZoomFactor(1.0);
// Hoặc dùng WebView2 settings: put_IsZoomControlEnabled(false)
```

**Độ phức tạp**: MEDIUM
**Rủi ro**: MEDIUM — phụ thuộc vào API của `webview_windows` package. Nếu package không hỗ trợ disable zoom, cần fallback sang JS injection.

---

### Phase 6: Thêm nút Reset Zoom + UX improvements

**Tệp**: `lib/screens/market_detail_screen.dart`, `assets/lightweight_chart.html`

**Thay đổi**:

1. **Nút "Reset" trên Flutter** (cho cả 2 tab):
```dart
// Thêm IconButton ở góc phải TabBar
Row(
  children: [
    Expanded(child: TabBar(...)),
    IconButton(
      icon: const Icon(Icons.zoom_out_map, size: 18),
      tooltip: 'Reset zoom',
      onPressed: () {
        // Tab 1: gọi JS resetZoom
        // Tab 2: inject JS chart.resetData() hoặc tương đương
      },
    ),
  ],
)
```

2. **Visual hint khi scroll** (Tab 1): Hiện tooltip nhỏ "Scroll to zoom / Drag to pan" khi hover lần đầu

3. **Responsive chart height**: Tăng chiều cao biểu đồ một chút để bù cho compact header:
```dart
// Trước: height: 520 (Pro) / 480 (nội bộ)
// Sau: height: 540 (Pro) / 500 (nội bộ)
// Hoặc tốt hơn: dùng LayoutBuilder để tính % theo viewport
```

**Độ phức tạp**: LOW
**Rủi ro**: LOW

---

## 4. Tóm tắt thay đổi theo tệp

| # | Tệp | Thay đổi | Phase |
|---|------|----------|-------|
| 1 | `lib/screens/market_detail_screen.dart` | Scroll isolation (MouseRegion + Listener), chuyển `_TradingChartWidget` thành StatefulWidget, nút Reset zoom, tăng chiều cao | 1, 5, 6 |
| 2 | `assets/lightweight_chart.html` | Bật handleScroll/handleScale, thêm crosshair config, redesign overlay → compact header, thêm OHLC hover, chặn browser zoom, double-click reset, expose resetZoom API | 2, 3, 6 |
| 3 | `lib/core/utils/tradingview_pro_chart_html.dart` | Chặn browser zoom (JS inject), ẩn/thu gọn legend, đảm bảo crosshair | 4 |
| 4 | `lib/presentation/widgets/lightweight_charts_widget.dart` | Forward scroll event nếu cần, method resetZoom() public | 1, 6 |
| 5 | `test/core/utils/tradingview_pro_chart_html_test.dart` | Cập nhật test cho HTML mới (disabled features, zoom prevention) | 4 |
| 6 | `test/` (widget test mới nếu cần) | Test scroll isolation behavior | 1 |

---

## 5. Thứ tự triển khai

```
Phase 1 (Scroll Isolation)  ──→  Phase 2 (Enable LW interaction)
          │                              │
          │                              ▼
          │                    Phase 3 (Redesign overlay)
          │
          ▼
Phase 4 (Pro Chart legend + zoom)  ──→  Phase 5 (Flutter-side WebView zoom)
                                               │
                                               ▼
                                        Phase 6 (Reset + UX polish)
```

**Khuyến nghị**: Phase 1 + 2 + 3 có thể chạy song song với Phase 4 + 5 vì ảnh hưởng tệp khác nhau.

---

## 6. Đánh giá rủi ro

| Rủi ro | Mức độ | Giải pháp |
|--------|--------|-----------|
| `webview_windows` không hỗ trợ disable zoom | MEDIUM | Fallback: JS `preventDefault` trên `wheel` + `keydown` event |
| Lightweight Charts v4.1 crosshair config khác v4.2+ | LOW | Đã verify: `CrosshairMode` có từ v3, stable trong v4.1 |
| Scroll isolation ảnh hưởng UX scroll trang | LOW | MouseRegion exit → trả lại scroll cho trang bình thường |
| TradingView widget API thay đổi `hide_legend` behavior | LOW | Đã verify: `hide_legend` stable từ widget v1 |
| Performance khi thêm crosshair move subscriber | LOW | Chỉ update 1 DOM element text, negligible |

---

## 7. Tiêu chí hoàn thành (Definition of Done)

- [ ] Scroll chuột trên biểu đồ KHÔNG cuộn trang
- [ ] Ctrl+Scroll trên biểu đồ zoom NỘI DUNG biểu đồ (không zoom browser)
- [ ] Chú thích/Legend KHÔNG che nội dung biểu đồ
- [ ] Legend/Toolbar KHÔNG bị scale khi zoom biểu đồ
- [ ] Crosshair hiện CẢ đường dọc VÀ đường ngang khi hover
- [ ] Crosshair hiện giá trị O/H/L/C trên header bar (Tab 1)
- [ ] Có nút Reset zoom hoạt động cho cả 2 tab
- [ ] Double-click reset zoom (Tab 1)
- [ ] Test đã pass cho HTML builder mới
- [ ] Không regression cho real-time data streaming
- [ ] Không regression cho interval selector

---

## 8. Ước tính thời gian (không cam kết)

| Phase | Mô tả | Complexity |
|-------|--------|------------|
| 1 | Scroll isolation (Flutter) | MEDIUM |
| 2 | Enable LW Charts interaction | LOW |
| 3 | Redesign overlay info | MEDIUM |
| 4 | Pro Chart legend + browser zoom | LOW |
| 5 | Flutter-side WebView zoom control | MEDIUM |
| 6 | Reset zoom + UX polish | LOW |

**Tổng complexity**: MEDIUM

---

**WAITING FOR CONFIRMATION**: Tiến hành triển khai theo plan này? (yes/no/modify)
