import struct, math, wave, os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def make_wav(filename, freq_hz=440, duration_sec=0.4, sample_rate=44100, amplitude=0.5):
    n = int(sample_rate * duration_sec)
    with wave.open(filename, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        for i in range(n):
            t = i / sample_rate
            fade = int(sample_rate * 0.02)
            if i < fade:
                env = i / fade
            elif i > n - fade:
                env = (n - i) / fade
            else:
                env = 1.0
            sample = amplitude * env * math.sin(2 * math.pi * freq_hz * t)
            w.writeframes(struct.pack('<h', int(sample * 32767)))

system_default = os.path.join(SCRIPT_DIR, 'system_default.wav')
make_wav(system_default, freq_hz=440, duration_sec=0.4, amplitude=0.5)
print(f'Created system_default.wav ({os.path.getsize(system_default)} bytes)')

print('Done.')
