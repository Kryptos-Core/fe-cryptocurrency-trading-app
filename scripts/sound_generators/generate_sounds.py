import struct, math, wave, os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def make_wav(filename, freq_hz=440, duration_sec=0.3, sample_rate=44100, amplitude=0.5):
    n = int(sample_rate * duration_sec)
    with wave.open(filename, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        for i in range(n):
            t = i / sample_rate
            env = min(1.0, t / 0.03, (duration_sec - t) / 0.03)
            sample = amplitude * env * math.sin(2 * math.pi * freq_hz * t)
            w.writeframes(struct.pack('<h', int(sample * 32767)))

sounds = {
    'withdrawal_request':  (880, 0.4),
    'withdrawal_approved': (1320, 0.5),
    'withdrawal_rejected': (220, 0.5),
    'alert':              (1100, 0.3),
    'promo':              (660, 0.6),
}
for name, (freq, dur) in sounds.items():
    out = os.path.join(SCRIPT_DIR, f'{name}.wav')
    make_wav(out, freq, dur)
    size = os.path.getsize(out)
    print(f'Created {out} ({size} bytes)')

print('Done.')
