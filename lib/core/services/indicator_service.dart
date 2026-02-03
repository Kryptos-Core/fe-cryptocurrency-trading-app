/// Technical Indicators Service
/// Implements: Strategy Pattern, Single Responsibility Principle
/// Calculates MA, RSI, MACD, Volume indicators with optimized performance
library;

import 'dart:math' as math;

class IndicatorValue {
  final double value;
  final DateTime timestamp;
  final int index;

  IndicatorValue({
    required this.value,
    required this.timestamp,
    required this.index,
  });
}

class MACDValue {
  final double macd;
  final double signal;
  final double histogram;
  final DateTime timestamp;
  final int index;

  MACDValue({
    required this.macd,
    required this.signal,
    required this.histogram,
    required this.timestamp,
    required this.index,
  });
}

/// Base Indicator interface - Strategy Pattern
abstract class IIndicator<T> {
  List<T> calculate(List<double> values);
}

/// Moving Average (MA) Indicator
/// Support: SMA, EMA
class MovingAverageIndicator implements IIndicator<IndicatorValue> {
  final int period;
  final bool useEMA; // if false, use SMA

  MovingAverageIndicator({
    required this.period,
    this.useEMA = false,
  });

  /// Calculate single MA value
  @override
  List<IndicatorValue> calculate(List<double> values) {
    if (values.length < period) return [];

    final result = <IndicatorValue>[];

    for (int i = period - 1; i < values.length; i++) {
      double ma;
      if (useEMA) {
        ma = _calculateEMA(values, i);
      } else {
        ma = _calculateSMA(values.sublist(i - period + 1, i + 1));
      }

      result.add(IndicatorValue(
        value: ma,
        timestamp: DateTime.now(),
        index: i,
      ));
    }

    return result;
  }

  /// Calculate series of MA values
  List<IndicatorValue> calculateSeries(List<double> values) {
    return calculate(values);
  }

  double _calculateSMA(List<double> values) {
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateEMA(List<double> values, int index) {
    final k = 2.0 / (period + 1);
    double ema = values[0];

    for (int i = 1; i <= index; i++) {
      ema = values[i] * k + ema * (1 - k);
    }

    return ema;
  }
}

/// RSI (Relative Strength Index) Indicator
class RSIIndicator implements IIndicator<IndicatorValue> {
  final int period;

  RSIIndicator({this.period = 14});

  @override
  List<IndicatorValue> calculate(List<double> values) {
    if (values.length < period + 1) return [];

    final result = <IndicatorValue>[];

    // Calculate price changes
    final gains = <double>[];
    final losses = <double>[];

    for (int i = 1; i < values.length; i++) {
      final change = values[i] - values[i - 1];
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    // Calculate RSI for each period
    for (int i = period; i < gains.length; i++) {
      final avgGain =
          gains.sublist(i - period, i).reduce((a, b) => a + b) / period;
      final avgLoss =
          losses.sublist(i - period, i).reduce((a, b) => a + b) / period;

      double rsi = 100.0;
      if (avgLoss != 0) {
        final rs = avgGain / avgLoss;
        rsi = 100 - (100 / (1 + rs));
      }

      result.add(IndicatorValue(
        value: rsi,
        timestamp: DateTime.now(),
        index: i,
      ));
    }

    return result;
  }
}

/// MACD (Moving Average Convergence Divergence) Indicator
class MACDIndicator implements IIndicator<MACDValue> {
  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;

  MACDIndicator({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
  });

  @override
  List<MACDValue> calculate(List<double> values) {
    if (values.length < slowPeriod) return [];

    // Calculate fast and slow EMA
    final fastEMA = _calculateEMA(values, fastPeriod);
    final slowEMA = _calculateEMA(values, slowPeriod);

    if (fastEMA.isEmpty || slowEMA.isEmpty) return [];

    // Calculate MACD line (fast EMA - slow EMA)
    final macdLine = <double>[];
    final minLength = math.min(fastEMA.length, slowEMA.length);
    final fastOffset = fastEMA.length - minLength;
    final slowOffset = slowEMA.length - minLength;

    for (int i = 0; i < minLength; i++) {
      macdLine.add(fastEMA[i + fastOffset] - slowEMA[i + slowOffset]);
    }

    // Calculate Signal line (EMA of MACD)
    final signalLine = _calculateEMA(macdLine, signalPeriod);

    if (signalLine.isEmpty) return [];

    // Calculate Histogram
    final result = <MACDValue>[];
    final startIndex = slowPeriod - 1;

    for (int i = 0; i < signalLine.length; i++) {
      final macdIndex = startIndex + i;
      if (macdIndex < macdLine.length) {
        result.add(MACDValue(
          macd: macdLine[macdIndex],
          signal: signalLine[i],
          histogram: macdLine[macdIndex] - signalLine[i],
          timestamp: DateTime.now(),
          index: macdIndex,
        ));
      }
    }

    return result;
  }

  List<double> _calculateEMA(List<double> values, int period) {
    if (values.length < period || period <= 0) return [];

    final result = <double>[];
    final k = 2.0 / (period + 1);
    double ema = values.take(period).reduce((a, b) => a + b) / period;
    result.add(ema);

    for (int i = period; i < values.length; i++) {
      ema = values[i] * k + ema * (1 - k);
      result.add(ema);
    }

    return result;
  }
}

/// Volume Indicator
class VolumeIndicator implements IIndicator<IndicatorValue> {
  final int period;

  VolumeIndicator({this.period = 20});

  @override
  List<IndicatorValue> calculate(List<double> volumes) {
    if (volumes.length < period) return [];

    final result = <IndicatorValue>[];

    for (int i = period - 1; i < volumes.length; i++) {
      final avgVolume =
          volumes.sublist(i - period + 1, i + 1).reduce((a, b) => a + b) /
              period;

      result.add(IndicatorValue(
        value: avgVolume,
        timestamp: DateTime.now(),
        index: i,
      ));
    }

    return result;
  }
}

/// Bollinger Bands Indicator (Bonus)
class BollingerBandsValue {
  final double upper;
  final double middle;
  final double lower;
  final DateTime timestamp;
  final int index;

  BollingerBandsValue({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.timestamp,
    required this.index,
  });
}

class BollingerBandsIndicator implements IIndicator<BollingerBandsValue> {
  final int period;
  final double standardDeviations;

  BollingerBandsIndicator({
    this.period = 20,
    this.standardDeviations = 2.0,
  });

  @override
  List<BollingerBandsValue> calculate(List<double> values) {
    if (values.length < period) return [];

    final result = <BollingerBandsValue>[];

    for (int i = period - 1; i < values.length; i++) {
      final subset = values.sublist(i - period + 1, i + 1);
      final sma = subset.reduce((a, b) => a + b) / period;
      final variance =
          subset.map((v) => (v - sma) * (v - sma)).reduce((a, b) => a + b) /
              period;
      final stdDev = math.sqrt(variance);

      result.add(BollingerBandsValue(
        upper: sma + (stdDev * standardDeviations),
        middle: sma,
        lower: sma - (stdDev * standardDeviations),
        timestamp: DateTime.now(),
        index: i,
      ));
    }

    return result;
  }
}

/// Indicator Service - Facade Pattern
/// Provides unified interface for all indicators
class IndicatorService {
  final MovingAverageIndicator smaIndicator;
  final MovingAverageIndicator emaIndicator;
  final RSIIndicator rsiIndicator;
  final MACDIndicator macdIndicator;
  final VolumeIndicator volumeIndicator;
  final BollingerBandsIndicator bollingerIndicator;

  IndicatorService({
    MovingAverageIndicator? smaIndicator,
    MovingAverageIndicator? emaIndicator,
    RSIIndicator? rsiIndicator,
    MACDIndicator? macdIndicator,
    VolumeIndicator? volumeIndicator,
    BollingerBandsIndicator? bollingerIndicator,
  })  : smaIndicator =
            smaIndicator ?? MovingAverageIndicator(period: 20, useEMA: false),
        emaIndicator =
            emaIndicator ?? MovingAverageIndicator(period: 12, useEMA: true),
        rsiIndicator = rsiIndicator ?? RSIIndicator(),
        macdIndicator = macdIndicator ?? MACDIndicator(),
        volumeIndicator = volumeIndicator ?? VolumeIndicator(),
        bollingerIndicator = bollingerIndicator ?? BollingerBandsIndicator();

  /// Calculate all indicators from close prices
  Map<String, dynamic> calculateAllIndicators(
      List<double> closePrices, List<double> volumes) {
    return {
      'sma': smaIndicator.calculate(closePrices),
      'ema': emaIndicator.calculate(closePrices),
      'rsi': rsiIndicator.calculate(closePrices),
      'macd': macdIndicator.calculate(closePrices),
      'volume': volumeIndicator.calculate(volumes),
      'bollingerBands': bollingerIndicator.calculate(closePrices),
    };
  }
}
