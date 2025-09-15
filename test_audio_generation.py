#!/usr/bin/env python3
"""
Script para generar audio de recetas usando OpenAI TTS
"""

import json
import os
from openai import OpenAI
import time

def load_recipe(recipe_file, recipe_title):
    """Cargar una receta específica del JSON"""
    with open(recipe_file, 'r', encoding='utf-8') as f:
        recipes = json.load(f)
    
    for recipe in recipes:
        if recipe['title'] == recipe_title:
            return recipe
    return None

def generate_audio_openai(text, voice="alloy", output_path="test_audio.mp3"):
    """Generar audio usando OpenAI TTS"""
    try:
        client = OpenAI()
        
        print(f"Generando audio para: '{text[:50]}...'")
        
        response = client.audio.speech.create(
            model="tts-1",
            voice=voice,
            input=text
        )
        
        # Guardar el audio
        with open(output_path, 'wb') as f:
            f.write(response.content)
        
        print(f"✅ Audio guardado en: {output_path}")
        return True
        
    except Exception as e:
        print(f"❌ Error generando audio: {e}")
        return False

def main():
    # Configuración
    recipe_file = "PerfectBrew/Resources/recipes_v60.json"
    recipe_title = "James Hoffmann V60 - Single Serve"  # Receta de prueba
    voice = "alloy"  # Voz de OpenAI TTS
    
    print(f"🎯 Probando generación de audio para: {recipe_title}")
    print(f"🎤 Usando voz: {voice}")
    print("-" * 50)
    
    # Cargar receta
    recipe = load_recipe(recipe_file, recipe_title)
    if not recipe:
        print(f"❌ No se encontró la receta: {recipe_title}")
        return
    
    print(f"📖 Receta encontrada: {recipe['title']}")
    print(f"⏱️  Tiempo total: {recipe['parameters']['total_brew_time_seconds']} segundos")
    print(f"📝 Pasos de preparación: {len(recipe['preparation_steps'])}")
    print(f"☕ Pasos de preparación: {len(recipe['brewing_steps'])}")
    print("-" * 50)
    
    # Crear directorio para audios de prueba
    test_dir = "test_audio_output"
    os.makedirs(test_dir, exist_ok=True)
    
    # Generar audio para el primer paso de preparación
    if recipe['preparation_steps']:
        prep_text = recipe['preparation_steps'][0]
        prep_audio_path = os.path.join(test_dir, "preparation_step1.mp3")
        generate_audio_openai(prep_text, voice, prep_audio_path)
        time.sleep(1)  # Pausa entre requests
    
    # Generar audio para el primer paso de preparación
    if recipe['brewing_steps']:
        brew_text = recipe['brewing_steps'][0]['instruction']
        brew_audio_path = os.path.join(test_dir, "brewing_step1.mp3")
        generate_audio_openai(brew_text, voice, brew_audio_path)
        time.sleep(1)  # Pausa entre requests
    
    print("-" * 50)
    print("🎉 Prueba completada!")
    print(f"📁 Archivos guardados en: {test_dir}/")
    print("\nPara usar en la app, necesitarías:")
    print("1. Instalar openai: pip install openai")
    print("2. Configurar API key: export OPENAI_API_KEY='tu-key'")
    print("3. Ejecutar: python test_audio_generation.py")

if __name__ == "__main__":
    main()
