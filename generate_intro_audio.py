#!/usr/bin/env python3
"""
Generate intro audio (what_to_expect) for a recipe JSON using Chatterbox TTS.
Saves M4A alongside step audios and creates a notes.wav alias.
"""

import os
import re
import json
import argparse
import numpy as np
import torch
from chatterbox.tts import ChatterboxTTS
from scipy.io import wavfile
import subprocess


def convert_title_to_folder_name(recipe_title: str) -> str:
    folder_name = re.sub(r'[^\w\s]', '', recipe_title)
    folder_name = re.sub(r'\s+', '_', folder_name.strip())
    return folder_name[:50] if len(folder_name) > 50 else folder_name


def clean_text(text: str) -> str:
    text = re.sub(r'[^\w\s.,!?;:\-()]', '', text)
    text = re.sub(r'\s+', ' ', text)
    text = text.replace('.', '. ').replace(',', ', ').replace(':', ': ').replace(';', '; ')
    return text.strip()


def generate_intro_audio(recipes_path: str, base_output_dir: str, device: str = "cpu") -> None:
    with open(recipes_path, 'r') as f:
        recipes = json.load(f)

    if not recipes:
        raise SystemExit("No recipes found in JSON")

    recipe = recipes[0]
    title = recipe.get('title', 'Unknown Recipe')
    what = recipe.get('what_to_expect', {})
    audio_script = what.get('audio_script')
    audio_file_name = what.get('audio_file_name', 'intro.m4a')

    if not audio_script:
        raise SystemExit("what_to_expect.audio_script is missing")

    # Mirror folder structure used by universal generator
    folder = convert_title_to_folder_name(title)
    recipe_output_dir = os.path.join(base_output_dir, folder)
    os.makedirs(recipe_output_dir, exist_ok=True)

    # Ensure .m4a extension
    if '.' in audio_file_name:
        audio_file_name = audio_file_name.rsplit('.', 1)[0] + '.m4a'
    else:
        audio_file_name = audio_file_name + '.m4a'

    m4a_path = os.path.join(recipe_output_dir, audio_file_name)
    notes_wav_path = os.path.join(recipe_output_dir, 'notes.wav')

    print("Loading Chatterbox TTS model...")
    tts = ChatterboxTTS.from_pretrained(device=device)

    text = clean_text(audio_script)
    print(f"Generating intro audio for: {title}")
    wav = tts.generate(text)
    if isinstance(wav, torch.Tensor):
        wav = wav.cpu().numpy()
    if wav.ndim > 1:
        wav = wav.flatten()

    # Write temporary wav
    tmp_wav = os.path.join(recipe_output_dir, '_intro_tmp.wav')
    wavfile.write(tmp_wav, 22050, (wav * 32767).astype(np.int16))

    # Convert to M4A
    cmd_m4a = ['ffmpeg', '-y', '-i', tmp_wav, '-c:a', 'aac', '-b:a', '128k', '-ar', '44100', '-ac', '2', m4a_path]
    res1 = subprocess.run(cmd_m4a, capture_output=True, text=True)
    if res1.returncode != 0:
        raise SystemExit(f"FFmpeg to M4A failed: {res1.stderr}")
    print(f"✅ Saved intro M4A: {m4a_path}")

    # Also create notes.wav alias at 44.1kHz stereo
    cmd_wav = ['ffmpeg', '-y', '-i', tmp_wav, '-ar', '44100', '-ac', '2', notes_wav_path]
    res2 = subprocess.run(cmd_wav, capture_output=True, text=True)
    if res2.returncode != 0:
        raise SystemExit(f"FFmpeg to WAV failed: {res2.stderr}")
    print(f"✅ Saved notes WAV alias: {notes_wav_path}")

    # Cleanup
    try:
        os.remove(tmp_wav)
    except Exception:
        pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate intro audio from recipe JSON')
    parser.add_argument('--recipes', required=True, help='Path to recipe JSON file')
    parser.add_argument('--output', required=True, help='Base output directory for audio')
    parser.add_argument('--device', default='cpu', help='cpu or cuda')
    args = parser.parse_args()

    generate_intro_audio(args.recipes, args.output, device=args.device)


