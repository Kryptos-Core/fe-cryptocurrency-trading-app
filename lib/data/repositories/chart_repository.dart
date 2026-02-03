import 'dart:async';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:logger/logger.dart';

/// Repository Interface - Abstraction (Dependency Inversion Principle)
/// Defines contracts for chart data operations
abstract class IChartRepository {
  Future<List<OHLCData>> getHistoricalCandles(int pairId, String interval,
      {int limit = 500});

  Future<void> subscribeToRealtimeUpdates(int pairId, String interval);
  Future<void> unsubscribeFromRealtimeUpdates(int pairId);
  Stream<OHLCData> get candleStream;
  Stream<TickerData> get tickStream;
}

/// Concrete Repository Implementation
/// Implements: Repository Pattern, Adapter Pattern
class ChartRepository implements IChartRepository {
  final IWebSocketService _webSocketService;
  final DioClient _dioClient;
  final Logger _logger = Logger();

  // Streams for external listeners
  final StreamController<OHLCData> _candleStreamController =
      StreamController<OHLCData>.broadcast();
  final StreamController<TickerData> _tickStreamController =
      StreamController<TickerData>.broadcast();

  ChartRepository({
    required IWebSocketService webSocketService,
    required DioClient dioClient,
  })  : _webSocketService = webSocketService,
        _dioClient = dioClient;

  @override
  Stream<OHLCData> get candleStream => _candleStreamController.stream;

  @override
  Stream<TickerData> get tickStream => _tickStreamController.stream;

  /// Fetch historical candles from API
  @override
  Future<List<OHLCData>> getHistoricalCandles(
    int pairId,
    String interval, {
    int limit = 500,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/markets/$pairId/candles',
        queryParameters: {
          'interval': interval,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final candlesJson = (data['data'] ?? []) as List;

        final candles = candlesJson
            .map((c) => OHLCData.fromJson(c as Map<String, dynamic>))
            .toList();

        _logger.i('📚 Loaded ${candles.length} historical candles');
        return candles;
      } else {
        throw Exception('Failed to load candles: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching historical candles: $e');
      rethrow;
    }
  }

  /// Subscribe to realtime candle updates
  @override
  Future<void> subscribeToRealtimeUpdates(int pairId, String interval) async {
    try {
      _webSocketService.subscribeToPair(
        pairId,
        ['ticker', 'ohlc'],
        interval: interval,
      );

      // Listen to WebSocket messages
      _webSocketService.messageStream.listen((message) {
        if (message.type == 'ohlc') {
          try {
            final candle = OHLCData.fromJson(message.data);
            _candleStreamController.add(candle);
          } catch (e) {
            _logger.e('Error parsing candle: $e');
          }
        } else if (message.type == 'ticker') {
          try {
            final tick = TickerData.fromJson(message.data);
            _tickStreamController.add(tick);
          } catch (e) {
            _logger.e('Error parsing tick: $e');
          }
        }
      });

      _logger.i('✅ Subscribed to pair $pairId updates');
    } catch (e) {
      _logger.e('Error subscribing to realtime updates: $e');
      rethrow;
    }
  }

  /// Unsubscribe from realtime updates
  @override
  Future<void> unsubscribeFromRealtimeUpdates(int pairId) async {
    try {
      _webSocketService.unsubscribeFromPair(pairId);
      _logger.i('Unsubscribed from pair $pairId');
    } catch (e) {
      _logger.e('Error unsubscribing: $e');
      rethrow;
    }
  }

  void dispose() {
    _candleStreamController.close();
    _tickStreamController.close();
  }
}
