import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// ============================================================================
/// LIGHTWEIGHT CHARTS WIDGET (TradingView v4.1)
/// High-performance canvas-based charting via WebView
/// ============================================================================

/// Lightweight Charts Widget - Real-time candlestick charting
class LightweightChartsWidget extends StatefulWidget {
  final List<OHLCData> candles;
  final String pairSymbol;
  final String interval;
  /// BCP 47 tag (e.g. vi-VN) for TradingView time axis via `Intl.DateTimeFormat`.
  final String? localeTag;
  final Function(int?)? onCandleTap;
  final EdgeInsets padding;

  const LightweightChartsWidget({
    super.key,
    required this.candles,
    required this.pairSymbol,
    this.interval = '1m',
    this.localeTag,
    this.onCandleTap,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  State<LightweightChartsWidget> createState() =>
      _LightweightChartsWidgetState();
}

class _LightweightChartsWidgetState extends State<LightweightChartsWidget> {
  final _controller = WebviewController();
  final Logger _logger = Logger();
  bool _isReady = false;
  bool _isInitialized = false;
  bool _isSupported = true;
  String? _initError;
  int _readyAttempts = 0;
  static const int _maxReadyAttempts = 40;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      _logger.i('🔄 Initializing WebView...');
      await _controller.initialize();

      final htmlPath = await _ensureLocalHtmlAsset();
      _logger.i('Loading HTML from: $htmlPath');

      await _controller.loadUrl('file:///$htmlPath');
      _logger.i('✅ WebView initialized and URL loaded');

      // Wait for page load
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isInitialized = true);
        _logger.i('✅ WebView marked as initialized');
        await _checkIfReady();
      }
    } on MissingPluginException catch (e) {
      _logger.e('❌ WebView plugin not available: $e');
      if (mounted) {
        setState(() {
          _isSupported = false;
          _initError =
              'WebView plugin is unavailable on this build. Try running flutter clean and rebuilding the Windows app.';
        });
      }
    } catch (e) {
      _logger.e('❌ Error initializing webview: $e');
      if (mounted) {
        setState(() {
          _isSupported = false;
          _initError = 'Failed to initialize the chart view.';
        });
      }
    }
  }

  Future<String> _ensureLocalHtmlAsset() async {
    final data = await rootBundle.load('assets/lightweight_chart.html');
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}${Platform.pathSeparator}lightweight_chart.html';
    final file = File(filePath);
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkIfReady() async {
    try {
      _logger.i('🔍 Checking if chart is ready...');
      final result = await _controller.executeScript(
          '(() => { try { return (window.LWChartAPI && window.LWChartAPI.isReady && window.LWChartAPI.isReady()) ? "true" : "false"; } catch (e) { return "error"; } })()');
      _logger.i('📊 Chart API ready check result: $result');

      final isReady = result.toString().contains('true');
      if (isReady) {
        if (mounted) {
          setState(() => _isReady = true);
          _logger.i(
              '✅ Chart API is ready! Candle count: ${widget.candles.length}');
          if (widget.candles.isNotEmpty) {
            await _sendCandlesToChart();
          } else {
            _logger.w('⚠️ No candles available to send to chart');
          }
        }
        return;
      }

      _readyAttempts++;
      if (_readyAttempts >= _maxReadyAttempts) {
        _logger.e('❌ Chart API did not become ready in time');
        if (mounted) {
          setState(() {
            _isSupported = false;
            _initError =
                'Chart resources failed to load. Please check network access or asset loading.';
          });
        }
        return;
      }
    } catch (e) {
      _logger.e('❌ Error checking chart readiness: $e');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted && _isSupported) {
      await _checkIfReady();
    }
  }

  @override
  void didUpdateWidget(LightweightChartsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isReady) return;
    final localeChanged = oldWidget.localeTag != widget.localeTag;
    final pairChanged = oldWidget.pairSymbol != widget.pairSymbol;
    if (pairChanged) {
      _controller.executeScript('window.LWChartAPI.clearChart()');
    }
    if (widget.candles.isEmpty) {
      if (!pairChanged) {
        _controller.executeScript('window.LWChartAPI.clearChart()');
      }
      return;
    }
    final len = widget.candles.length;
    final oldLen = oldWidget.candles.length;
    final lastChanged = len == oldLen &&
        len > 0 &&
        (widget.candles.last.openTime != oldWidget.candles.last.openTime ||
            widget.candles.last.close != oldWidget.candles.last.close);
    if (pairChanged || oldLen != len || lastChanged || localeChanged) {
      _sendCandlesToChart();
    }
  }

  Future<void> _sendCandlesToChart() async {
    if (!_isReady || widget.candles.isEmpty) return;

    try {
      final tag = (widget.localeTag != null && widget.localeTag!.trim().isNotEmpty)
          ? widget.localeTag!.trim()
          : 'en-US';
      await _controller.executeScript(
        'window.LWChartAPI.setLocale(${jsonEncode(tag)})',
      );
      final list = widget.candles.map(_candleToJson).toList();
      await _controller.executeScript(
        'window.LWChartAPI.setCandles(${jsonEncode(list)})',
      );
      _logger.i('📊 Set ${list.length} candles to TradingView chart');
    } catch (e) {
      _logger.e('Error updating chart: $e');
    }
  }

  Map<String, dynamic> _candleToJson(OHLCData candle) {
    return {
      'pair_id': candle.pairId,
      'symbol': widget.pairSymbol,
      'interval': candle.interval,
      'open_time': candle.openTime,
      'close_time': candle.closeTime,
      'open': candle.open.toString(),
      'high': candle.high.toString(),
      'low': candle.low.toString(),
      'close': candle.close.toString(),
      'volume': candle.volume.toString(),
      'is_closed': candle.isClosed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Stack(
        children: [
          if (!_isSupported)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: Colors.orange[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _initError ?? 'Chart view is not available.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Chart WebView
          if (_isInitialized && _isSupported)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Webview(_controller),
            ),

          // Loading indicator
          if (!_isReady && _isSupported)
            Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),

          // Empty state
          if (_isReady && widget.candles.isEmpty && _isSupported)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Waiting for chart data...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
