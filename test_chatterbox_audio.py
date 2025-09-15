#!/usr/bin/env python3
"""
Script para generar audio de recetas usando Chatterbox TTS (Resemble AI)
Completamente gratuito y open source
"""

import json
import os
import torchaudio as ta
from chatterbox.tts import ChatterboxTTS
from chatterbox.mtl_tts import ChatterboxMultilingualTTS

def load_recipe(recipe_file, recipe_title):
    """Cargar una receta específica del JSON"""
    with open(recipe_file, 'r', encoding='utf-8') as f:
        recipes = json.load(f)
    
    for recipe in recipes:
        if recipe['title'] == recipe_title:
            return recipe
    return None

def generate_audio_chatterbox(text, language="es", voice_path=None, output_path="test_audio.wav"):
    """Generar audio usando Chatterbox TTS"""
    try:
        print(f"🎤 Generando audio para: '{text[:50]}...'")
        print(f"🌍 Idioma: {language}")
        
        # Cargar modelo multilingüe
        model = ChatterboxMultilingualTTS.from_pretrained(device="cpu", torch_dtype="float32")  # Usar CPU para compatibilidad
        
        # Generar audio
        if voice_path and os.path.exists(voice_path):
            print(f"🎭 Usando voz personalizada: {voice_path}")
            wav = model.generate(text, language_id=language, audio_prompt_path=voice_path)
        else:
            print("🎭 Usando voz por defecto")
            wav = model.generate(text, language_id=language)
        
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
    recipe_title = "James Hoffmann V60 - Single Serve"  # Receta de prueba
    language = "es"  # Español
    
    print(f"🎯 Probando Chatterbox TTS para: {recipe_title}")
    print(f"🌍 Idioma: {language}")
    print(f"💰 Costo: GRATIS (Open Source)")
    print("-" * 60)
    
    # Cargar receta
    recipe = load_recipe(recipe_file, recipe_title)
    if not recipe:
        print(f"❌ No se encontró la receta: {recipe_title}")
        return
    
    print(f"📖 Receta encontrada: {recipe['title']}")
    print(f"⏱️  Tiempo total: {recipe['parameters']['total_brew_time_seconds']} segundos")
    print(f"📝 Pasos de preparación: {len(recipe['preparation_steps'])}")
    print(f"☕ Pasos de preparación: {len(recipe['brewing_steps'])}")
    print("-" * 60)
    
    # Crear directorio para audios de prueba
    test_dir = "test_chatterbox_audio"
    os.makedirs(test_dir, exist_ok=True)
    
    # Generar audio para el primer paso de preparación
    if recipe['preparation_steps']:
        prep_text = recipe['preparation_steps'][0]
        prep_audio_path = os.path.join(test_dir, "preparation_step1.wav")
        generate_audio_chatterbox(prep_text, language, output_path=prep_audio_path)
    
    # Generar audio para el primer paso de preparación
    if recipe['brewing_steps']:
        brew_text = recipe['brewing_steps'][0]['instruction']
        brew_audio_path = os.path.join(test_dir, "brewing_step1.wav")
        generate_audio_chatterbox(brew_text, language, output_path=brew_audio_path)
    
    # Generar audio para el segundo paso
    if len(recipe['brewing_steps']) > 1:
        brew_text2 = recipe['brewing_steps'][1]['instruction']
        brew_audio_path2 = os.path.join(test_dir, "brewing_step2.wav")
        generate_audio_chatterbox(brew_text2, language, output_path=brew_audio_path2)
    
    print("-" * 60)
    print("🎉 Prueba completada!")
    print(f"📁 Archivos guardados en: {test_dir}/")
    print("\nPara usar en la app, necesitarías:")
    print("1. Instalar chatterbox: pip install chatterbox-tts")
    print("2. Ejecutar: python3 test_chatterbox_audio.py")
    print("\n🌍 Idiomas soportados:")
    print("es (Español), en (Inglés), fr (Francés), de (Alemán), it (Italiano)")
    print("pt (Portugués), ru (Ruso), ja (Japonés), ko (Coreano), zh (Chino)")

if __name__ == "__main__":
    main()
