#!/usr/bin/env python3
"""Generate procedural game SFX using only Python standard library (wave, struct, math, random)."""
import wave, struct, math, random, os

OUT_DIR = "assets/audio/sfx"
SAMPLERATE = 44100

def write_wav(path: str, samples: list[int]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLERATE)
        wf.writeframes(struct.pack("<" + "h" * len(samples), *samples))

def envelope(length: int, attack: int, decay: int) -> list[float]:
    out = []
    for i in range(length):
        if i < attack:
            out.append(i / max(1, attack))
        elif i < attack + decay:
            out.append(1.0 - (i - attack) / max(1, decay))
        else:
            out.append(0.0)
    return out

def noise(length: int, amp: float = 1.0) -> list[int]:
    return [int(amp * (random.random() * 2.0 - 1.0) * 32767) for _ in range(length)]

def sine(freq: float, length: int, amp: float = 1.0) -> list[int]:
    return [int(amp * 32767 * math.sin(2.0 * math.pi * freq * i / SAMPLERATE)) for i in range(length)]

def square(freq: float, length: int, amp: float = 1.0) -> list[int]:
    return [int(amp * 32767 * (1.0 if math.sin(2.0 * math.pi * freq * i / SAMPLERATE) >= 0 else -1.0)) for i in range(length)]

def saw(freq: float, length: int, amp: float = 1.0) -> list[int]:
    return [int(amp * 32767 * (2.0 * ((freq * i / SAMPLERATE) % 1.0) - 1.0)) for i in range(length)]

def mix(*tracks):
    length = max(len(t) for t in tracks)
    out = [0] * length
    for t in tracks:
        for i in range(len(t)):
            out[i] += t[i]
    for i in range(length):
        out[i] = max(-32767, min(32767, out[i]))
    return out

def bandpass(samples: list[int], freq: float, bw: float) -> list[int]:
    """Simple IIR bandpass approximation."""
    f1 = freq - bw / 2
    f2 = freq + bw / 2
    r = 0.98
    a = []
    for s in samples:
        a.append(s)
    # just use a simple resonator; not perfect but ok for SFX
    y = [0] * len(samples)
    for i in range(2, len(samples)):
        y[i] = int(r * (2 * a[i-1] - a[i-2]) + s)
    return y

def gen_purchase():
    length = int(SAMPLERATE * 0.35)
    env = envelope(length, int(SAMPLERATE * 0.02), int(SAMPLERATE * 0.25))
    t1 = [int(e * 0.4 * 32767 * math.sin(2.0 * math.pi * 660.0 * i / SAMPLERATE)) for i, e in enumerate(env)]
    t2 = [int(e * 0.3 * 32767 * math.sin(2.0 * math.pi * 880.0 * i / SAMPLERATE)) for i, e in enumerate(env)]
    t3 = [int(e * 0.2 * 32767 * math.sin(2.0 * math.pi * 1320.0 * i / SAMPLERATE)) for i, e in enumerate(env)]
    out = [t1[i] + t2[i] + t3[i] for i in range(length)]
    out = [max(-32767, min(32767, int(x * 0.9))) for x in out]
    write_wav(os.path.join(OUT_DIR, "purchase.wav"), out)
    print("Generated purchase.wav")

def gen_levelup():
    length = int(SAMPLERATE * 0.6)
    env = envelope(length, int(SAMPLERATE * 0.05), int(SAMPLERATE * 0.5))
    base = 523.25
    t1 = [int(e * 0.4 * 32767 * math.sin(2.0 * math.pi * base * i / SAMPLERATE)) for i, e in enumerate(env)]
    t2 = [int(e * 0.3 * 32767 * math.sin(2.0 * math.pi * base * 1.25 * i / SAMPLERATE)) for i, e in enumerate(env)]
    t3 = [int(e * 0.25 * 32767 * math.sin(2.0 * math.pi * base * 1.5 * i / SAMPLERATE)) for i, e in enumerate(env)]
    shimmer = []
    for i in range(length):
        shimmer.append(int(0.08 * 32767 * math.sin(2.0 * math.pi * 2000.0 * i / SAMPLERATE) * math.exp(-3.0 * i / length)))
    out = [t1[i] + t2[i] + t3[i] + shimmer[i] for i in range(length)]
    out = [max(-32767, min(32767, int(x * 0.9))) for x in out]
    write_wav(os.path.join(OUT_DIR, "level_up.wav"), out)
    print("Generated level_up.wav")

def gen_upgrade_apply():
    length = int(SAMPLERATE * 0.25)
    env = envelope(length, int(SAMPLERATE * 0.01), int(SAMPLERATE * 0.2))
    out = [int(e * 0.5 * 32767 * math.sin(2.0 * math.pi * 1046.5 * i / SAMPLERATE)) for i, e in enumerate(env)]
    write_wav(os.path.join(OUT_DIR, "upgrade_apply.wav"), out)
    print("Generated upgrade_apply.wav")

if __name__ == "__main__":
    gen_purchase()
    gen_levelup()
    gen_upgrade_apply()
