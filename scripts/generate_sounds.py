#!/usr/bin/env python3
"""Generate simple notification sound WAV files for testing."""

import struct
import math
import wave
import os

SAMPLE_RATE = 44100
DURATION = 0.4  # seconds

def generate_tone(filename, frequency, duration=DURATION, volume=0.5):
    """Generate a simple sine wave tone."""
    num_samples = int(SAMPLE_RATE * duration)

    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)   # 2 bytes per sample
        wav_file.setframerate(SAMPLE_RATE)

        for i in range(num_samples):
            t = i / SAMPLE_RATE
            # Apply fade in/out envelope
            envelope = 1.0
            fade_samples = int(SAMPLE_RATE * 0.05)  # 50ms fade
            if i < fade_samples:
                envelope = i / fade_samples
            elif i > num_samples - fade_samples:
                envelope = (num_samples - i) / fade_samples

            # Generate sine wave with envelope
            value = int(volume * envelope * 32767 * math.sin(2 * math.pi * frequency * t))
            data = struct.pack('<h', value)
            wav_file.writeframes(data)

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    sounds_dir = os.path.join(os.path.dirname(base_dir), 'assets', 'sounds')

    os.makedirs(sounds_dir, exist_ok=True)

    # Generate different sounds for different notification types
    sounds = [
        ('system_default.wav', 440),           # A4 - standard notification
        ('withdrawal_request.wav', 330),       # E4 - request tone
        ('withdrawal_approved.wav', 523),      # C5 - success tone
        ('withdrawal_rejected.wav', 220),      # A3 - lower rejection tone
        ('alert.wav', 880),                    # A5 - attention alert
        ('promo.wav', 659),                    # E5 - promotional tone
    ]

    for filename, frequency in sounds:
        filepath = os.path.join(sounds_dir, filename)
        generate_tone(filepath, frequency)
        size = os.path.getsize(filepath)
        print(f"Created {filename}: {size} bytes ({frequency}Hz)")

if __name__ == '__main__':
    main()
