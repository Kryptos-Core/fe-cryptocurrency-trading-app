import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

final class WavToneGenerator {
  static const int sampleRate = 44100;

  /// Generates a WAV file with a sine-wave tone.
  ///
  /// [frequency]  — pitch in Hz (e.g. 440 = A4, 880 = A5).
  /// [durationMs] — length in milliseconds.
  /// [volume]     — 0.0–1.0, linear amplitude.
  /// [fadeMs]     — fade-in / fade-out overlap at each end (prevents clicks).
  static Uint8List buildWav({
    required double frequency,
    required int durationMs,
    double volume = 0.6,
    int fadeMs = 15,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final fadeSamples = (sampleRate * fadeMs / 1000).round();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      double env = 1.0;
      if (i < fadeSamples) {
        env = i / fadeSamples;
      } else if (i > numSamples - fadeSamples) {
        env = (numSamples - i) / fadeSamples;
      }
      final sample = sin(2 * pi * frequency * i / sampleRate) * volume * env;
      samples[i] = (sample * 32767).round().clamp(-32768, 32767);
    }

    return _encodeWav(samples);
  }

  /// Encodes PCM Int16 samples into a standard RIFF-WAV byte array.
  static Uint8List _encodeWav(Int16List samples) {
    final dataSize = samples.length * 2;
    final fileSize = 36 + dataSize;

    final buf = ByteData(44 + dataSize);
    int o = 0;

    // RIFF header
    buf.setUint8(o++, 0x52); // R
    buf.setUint8(o++, 0x49); // I
    buf.setUint8(o++, 0x46); // F
    buf.setUint8(o++, 0x46); // F
    buf.setUint32(o, fileSize, Endian.little);
    o += 4;
    buf.setUint8(o++, 0x57); // W
    buf.setUint8(o++, 0x41); // A
    buf.setUint8(o++, 0x56); // V
    buf.setUint8(o++, 0x45); // E

    // fmt subchunk
    buf.setUint8(o++, 0x66); // f
    buf.setUint8(o++, 0x6D); // m
    buf.setUint8(o++, 0x74); // t
    buf.setUint8(o++, 0x20); // space
    buf.setUint32(o, 16, Endian.little);
    o += 4; // subchunk1 size = 16 (PCM)
    buf.setUint16(o, 1, Endian.little);
    o += 2; // audio format = 1 (PCM)
    buf.setUint16(o, 1, Endian.little);
    o += 2; // num channels = 1 (mono)
    buf.setUint32(o, sampleRate, Endian.little);
    o += 4; // sample rate
    buf.setUint32(o, sampleRate * 2, Endian.little);
    o += 4; // byte rate = sampleRate * numChannels * bitsPerSample/8
    buf.setUint16(o, 2, Endian.little);
    o += 2; // block align = numChannels * bitsPerSample/8
    buf.setUint16(o, 16, Endian.little);
    o += 2; // bits per sample

    // data subchunk
    buf.setUint8(o++, 0x64); // d
    buf.setUint8(o++, 0x61); // a
    buf.setUint8(o++, 0x74); // t
    buf.setUint8(o++, 0x61); // a
    buf.setUint32(o, dataSize, Endian.little);
    o += 4;

    // PCM samples — little-endian Int16
    for (int i = 0; i < samples.length; i++) {
      buf.setInt16(o, samples[i], Endian.little);
      o += 2;
    }

    return Uint8List.view(buf.buffer, buf.offsetInBytes, buf.lengthInBytes);
  }

  /// Writes a tone WAV to a temp file and returns the path.
  static Future<String> writeTempWav({
    required double frequency,
    required int durationMs,
    double volume = 0.6,
    String? filename,
  }) async {
    final tempDir = Directory.systemTemp;
    final name = filename ?? 'ntf_${DateTime.now().millisecondsSinceEpoch}.wav';
    final file = File('${tempDir.path}\\$name');
    await file.writeAsBytes(buildWav(
      frequency: frequency,
      durationMs: durationMs,
      volume: volume,
    ));
    return file.path;
  }
}
