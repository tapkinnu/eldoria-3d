#!/usr/bin/env python3
"""Procedural SFX generator for Eldoria-3D using Python/wave."""
import wave
import struct
import math
import os

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "sfx")
os.makedirs(OUT_DIR, exist_ok=True)
RATE = 44100

def save_wave(samples: list[float], path: str):
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        for s in samples:
            w.writeframesraw(struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)))

def white_noise(duration: float, amp: float = 0.3) -> list[float]:
    import random
    n = int(RATE * duration)
    return [(random.random() * 2 - 1) * amp for _ in range(n)]

def sine(freq: float, duration: float, amp: float = 0.5) -> list[float]:
    n = int(RATE * duration)
    return [amp * math.sin(2 * math.pi * freq * t / RATE) for t in range(n)]

def square(freq: float, duration: float, amp: float = 0.4) -> list[float]:
    n = int(RATE * duration)
    return [amp * (-1.0 if math.sin(2 * math.pi * freq * t / RATE) >= 0 else 1.0) for t in range(n)]

def envelope(samples: list[float], attack: float = 0.01, decay: float = 0.3) -> list[float]:
    out = []
    n = len(samples)
    a_samples = int(RATE * attack)
    d_samples = int(RATE * decay)
    for i, s in enumerate(samples):
        if i < a_samples:
            env = i / max(a_samples, 1)
        elif i < a_samples + d_samples:
            env = 1.0 - (i - a_samples) / max(d_samples, 1)
        else:
            env = 0
        out.append(s * max(0, env))
    return out

# Sword swing (short descending sawish noise)
def gen_sword_swing():
    base = [math.sin(2 * math.pi * (800 - (t / RATE) * 600) * t / RATE) * 0.5 for t in range(int(RATE * 0.15))]
    noise = white_noise(0.15, 0.15)
    mixed = [(b + n) * 0.5 for b, n in zip(base, noise)]
    save_wave(envelope(mixed, 0.01, 0.12), os.path.join(OUT_DIR, "sword_swing.wav"))

# Pickup/coin (rising sine arpeggio)
def gen_pickup():
    notes = [880, 1100, 1320]
    dur = 0.06
    samples = []
    for freq in notes:
        samples.extend(sine(freq, dur, 0.4))
    save_wave(samples, os.path.join(OUT_DIR, "pickup.wav"))

# Player hurt (filtered noise burst)
def gen_hurt():
    n = white_noise(0.25, 0.4)
    # simple low-pass-ish via averaging
    out = []
    prev = 0.0
    for s in n:
        val = (s + prev) * 0.5
        out.append(val)
        prev = val
    save_wave(envelope(out, 0.01, 0.18), os.path.join(OUT_DIR, "hurt.wav"))

# UI click (short blip)
def gen_ui_click():
    save_wave(envelope(sine(1500, 0.05, 0.3), 0.005, 0.04), os.path.join(OUT_DIR, "ui_click.wav"))

if __name__ == "__main__":
    gen_sword_swing()
    gen_pickup()
    gen_hurt()
    gen_ui_click()
    print("SFX generated in", OUT_DIR)
