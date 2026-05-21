#!/usr/bin/env python3
"""Plays a WAV file using Windows built-in waveOut API via Python's wave module."""
import sys
import wave
import struct
import ctypes
from ctypes import wintypes

# Load winmm
windll = ctypes.WinDLL('winmm.dll')

# Constants
WAVE_MAPPER = -1
WAVE_FORMAT_PCM = 1
CALLBACK_NULL = 0
WHDR_DONE = 0x00000001
# MMRESULT is a UINT (0 = MMSYSERR_NOERROR)
MMRESULT = wintypes.UINT

# DWORD_PTR is a pointer-sized unsigned int (UIntPtr on 64-bit)
DWORD_PTR = ctypes.c_uint64 if ctypes.sizeof(ctypes.c_void_p) == 8 else ctypes.c_uint32

# Types
class WAVEFORMATEX(ctypes.Structure):
    _fields_ = [
        ('wFormatTag', wintypes.WORD),
        ('nChannels', wintypes.WORD),
        ('nSamplesPerSec', wintypes.DWORD),
        ('nAvgBytesPerSec', wintypes.DWORD),
        ('nBlockAlign', wintypes.WORD),
        ('wBitsPerSample', wintypes.WORD),
        ('cbSize', wintypes.WORD),
    ]

class WAVEHDR(ctypes.Structure):
    _fields_ = [
        ('lpData', ctypes.POINTER(ctypes.c_ubyte)),
        ('dwBufferLength', wintypes.DWORD),
        ('dwBytesRecorded', wintypes.DWORD),
        ('dwUser', DWORD_PTR),
        ('dwFlags', wintypes.DWORD),
        ('dwLoops', wintypes.DWORD),
        ('lpNext', DWORD_PTR),
        ('reserved', DWORD_PTR),
    ]

# Function prototypes
waveOutOpen = windll.waveOutOpen
waveOutOpen.argtypes = [
    ctypes.POINTER(wintypes.HANDLE),
    wintypes.UINT,
    ctypes.POINTER(WAVEFORMATEX),
    DWORD_PTR,
    DWORD_PTR,
    wintypes.DWORD,
]
waveOutOpen.restype = MMRESULT

waveOutPrepareHeader = windll.waveOutPrepareHeader
waveOutPrepareHeader.argtypes = [wintypes.HANDLE, ctypes.POINTER(WAVEHDR), wintypes.UINT]
waveOutPrepareHeader.restype = MMRESULT

waveOutWrite = windll.waveOutWrite
waveOutWrite.argtypes = [wintypes.HANDLE, ctypes.POINTER(WAVEHDR), wintypes.UINT]
waveOutWrite.restype = MMRESULT

waveOutClose = windll.waveOutClose
waveOutClose.argtypes = [wintypes.HANDLE]
waveOutClose.restype = MMRESULT

waveOutUnprepareHeader = windll.waveOutUnprepareHeader
waveOutUnprepareHeader.argtypes = [wintypes.HANDLE, ctypes.POINTER(WAVEHDR), wintypes.UINT]
waveOutUnprepareHeader.restype = MMRESULT

waveOutGetNumDevs = windll.waveOutGetNumDevs
waveOutGetNumDevs.restype = wintypes.UINT

waveOutGetErrorTextW = windll.waveOutGetErrorTextW
waveOutGetErrorTextW.argtypes = [MMRESULT, ctypes.c_wchar_p, wintypes.UINT]
waveOutGetErrorTextW.restype = MMRESULT


def get_error_text(err):
    buf = ctypes.create_unicode_buffer(256)
    waveOutGetErrorTextW(err, buf, 256)
    return buf.value


def play_wav(file_path):
    # Check devices
    if waveOutGetNumDevs() == 0:
        print('NO_DEVICE', flush=True)
        return

    # Read WAV
    try:
        with wave.open(file_path, 'rb') as wf:
            nchannels = wf.getnchannels()
            sampwidth = wf.getsampwidth()
            framerate = wf.getframerate()
            nframes = wf.getnframes()
            raw_data = wf.readframes(nframes)
    except Exception as e:
        print(f'WAV_OPEN_ERR:{e}', flush=True)
        return

    # Setup WAVEFORMATEX
    wfex = WAVEFORMATEX()
    wfex.wFormatTag = WAVE_FORMAT_PCM
    wfex.nChannels = nchannels
    wfex.nSamplesPerSec = framerate
    wfex.wBitsPerSample = sampwidth * 8
    wfex.nBlockAlign = nchannels * sampwidth
    wfex.nAvgBytesPerSec = framerate * wfex.nBlockAlign
    wfex.cbSize = 0

    # Open device
    hwo = wintypes.HANDLE()
    result = waveOutOpen(
        ctypes.byref(hwo),
        WAVE_MAPPER,
        ctypes.byref(wfex),
        0, 0, CALLBACK_NULL
    )
    if result != 0:
        print(f'OPEN_ERR:{result}:{get_error_text(result)}', flush=True)
        return

    # Prepare header
    audio_buf = (ctypes.c_ubyte * len(raw_data)).from_buffer_copy(raw_data)
    hdr = WAVEHDR()
    hdr.lpData = ctypes.cast(audio_buf, ctypes.POINTER(ctypes.c_ubyte))
    hdr.dwBufferLength = len(raw_data)
    hdr.dwFlags = 0
    hdr.dwLoops = 0

    result = waveOutPrepareHeader(hwo, ctypes.byref(hdr), ctypes.sizeof(WAVEHDR))
    if result != 0:
        print(f'PREP_ERR:{result}:{get_error_text(result)}', flush=True)
        waveOutClose(hwo)
        return

    # Write
    result = waveOutWrite(hwo, ctypes.byref(hdr), ctypes.sizeof(WAVEHDR))
    if result != 0:
        print(f'WRITE_ERR:{result}:{get_error_text(result)}', flush=True)
        waveOutUnprepareHeader(hwo, ctypes.byref(hdr), ctypes.sizeof(WAVEHDR))
        waveOutClose(hwo)
        return

    # Wait for done
    max_wait = (len(raw_data) // (framerate * wfex.nBlockAlign)) * 1000 + 2000
    waited = 0
    while waited < max_wait:
        if hdr.dwFlags & WHDR_DONE:
            break
        ctypes.windll.kernel32.Sleep(10)
        waited += 10

    waveOutUnprepareHeader(hwo, ctypes.byref(hdr), ctypes.sizeof(WAVEHDR))
    waveOutClose(hwo)
    print('OK', flush=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('USAGE: python winmm_player.py <wav_file>', flush=True)
        sys.exit(1)
    play_wav(sys.argv[1])
