#!/usr/bin/env python3
"""
Script simple para probar Chatterbox TTS (versión en inglés)
"""

import json
import os
import torch
import torchaudio as ta
from chatterbox.tts import ChatterboxTTS

def load_recipe(recipe_file, recipe_title):
    """Cargar una receta específica del JSON"""
    with open(recipe_file, 'r', encoding='utf-8') as f:
        recipes = json.load(f)
    
    for recipe in recipes:
        if recipe['title'] == recipe_title:
            return recipe
    return None

def generate_audio_simple(text, output_path="test_audio.wav"):
    """Generar audio usando Chatterbox TTS (inglés)"""
    try:
        print(f"🎤 Generando audio para: '{text[:50]}...'")
        
        # Forzar CPU
        torch.set_default_device('cpu')
        
        # Cargar modelo en inglés (más simple)
        model = ChatterboxTTS.from_pretrained(device="cpu")
        
        # Generar audio
        wav = model.generate(text)
        
        # Guardar audio
        ta.save(output_path, wav, model.sr)
        
        print(f"✅ Audio guardado en: {output_path}")
        print(f"📊 Duración: {len(wav[0]) / model.sr:.2f} segundos")
        return True
        
    except Exception as e:
        print(f"❌ Error generando audio: {e}")
        return False

def main():
    # Configuración
    recipe_file = "PerfectBrew/Resources/recipes_v60.json"
    recipe_title = "James Hoffmann V60 - Single Serve"
    
    print(f"🎯 Probando Chatterbox TTS (inglés) para: {recipe_title}")
    print(f"💰 Costo: GRATIS (Open Source)")
    print("-" * 60)
    
    # Cargar receta
    recipe = load_recipe(recipe_file, recipe_title)
    if not recipe:
        print(f"❌ No se encontró la receta: {recipe_title}")
        return
    
    print(f"📖 Receta encontrada: {recipe['title']}")
    print(f"⏱️  Tiempo total: {recipe['parameters']['total_brew_time_seconds']} segundos")
    print("-" * 60)
    
    # Crear directorio para audios de prueba
    test_dir = "test_chatterbox_simple"
    os.makedirs(test_dir, exist_ok=True)
    
    # Generar audio para el primer paso de preparación
    if recipe['preparation_steps']:
        prep_text = recipe['preparation_steps'][0]
        prep_audio_path = os.path.join(test_dir, "preparation_step1.wav")
        generate_audio_simple(prep_text, prep_audio_path)
    
    # Generar audio para el primer paso de preparación
    if recipe['brewing_steps']:
        brew_text = recipe['brewing_steps'][0]['instruction']
        brew_audio_path = os.path.join(test_dir, "brewing_step1.wav")
        generate_audio_simple(brew_text, brew_audio_path)
    
    print("-" * 60)
    print("🎉 Prueba completada!")
    print(f"📁 Archivos guardados en: {test_dir}/")

if __name__ == "__main__":
    main()
