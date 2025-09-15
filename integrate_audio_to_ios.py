#!/usr/bin/env python3
"""
Script para integrar audio generado en la estructura de la app iOS
"""

import json
import os
import shutil
from pathlib import Path

def create_ios_audio_structure():
    """Crear la estructura de directorios para audio en iOS"""
    
    # Directorio base de audio en iOS
    ios_audio_dir = "PerfectBrew/Resources/Audio"
    
    # Crear estructura de directorios
    structure = {
        "AeroPress": [
            "2024_World_Champion",
            "2023_World_Champion", 
            "2022_World_Champion",
            "2021_World_Champion",
            "James_Hoffmann_Ultimate",
            "Tim_W_Classic",
            "Championship_Concentrate"
        ],
        "V60": [
            "James_Hoffmann_Single",
            "James_Hoffmann_Two_People",
            "James_Hoffmann_Three_People", 
            "James_Hoffmann_Four_People",
            "Scott_Rao_Two_People",
            "Scott_Rao_Three_People",
            "Scott_Rao_Four_People",
            "Kaldi_Coffee_Three_People",
            "Kaldi_Coffee_Four_People",
            "Quick_Morning_V60"
        ],
        "FrenchPress": [
            "James_Hoffmann_Method",
            "Tim_Wendelboe_Method",
            "Scott_Rao_Method",
            "Blue_Bottle_Method",
            "Intelligentsia_Method",
            "Stumptown_Method",
            "Counter_Culture_Method",
            "Verve_Method",
            "Four_Barrel_Method"
        ]
    }
    
    print("🏗️  Creando estructura de directorios para iOS...")
    
    for method, recipes in structure.items():
        method_dir = os.path.join(ios_audio_dir, method)
        os.makedirs(method_dir, exist_ok=True)
        
        for recipe in recipes:
            recipe_dir = os.path.join(method_dir, recipe)
            os.makedirs(recipe_dir, exist_ok=True)
            
            # Crear subdirectorios para preparation y brewing
            os.makedirs(os.path.join(recipe_dir, "preparation"), exist_ok=True)
            os.makedirs(os.path.join(recipe_dir, "brewing"), exist_ok=True)
            
            print(f"   ✅ {method}/{recipe}")
    
    print(f"✅ Estructura creada en: {ios_audio_dir}")

def map_recipe_to_ios_structure(recipe_title, brewing_method):
    """Mapear nombre de receta a estructura de directorios iOS"""
    
    # Mapeo de títulos a nombres de directorio
    title_mapping = {
        # AeroPress
        "2024 World Champion AeroPress": "2024_World_Champion",
        "2023 World Champion AeroPress": "2023_World_Champion", 
        "2022 World Champion AeroPress": "2022_World_Champion",
        "2021 World Champion AeroPress": "2021_World_Champion",
        "James Hoffmann's Ultimate AeroPress": "James_Hoffmann_Ultimate",
        "Tim Wendelboe Classic AeroPress": "Tim_W_Classic",
        "Championship Concentrate AeroPress": "Championship_Concentrate",
        
        # V60
        "James Hoffmann V60 - Single Serve": "James_Hoffmann_Single",
        "James Hoffmann V60 - Two People": "James_Hoffmann_Two_People",
        "James Hoffmann V60 - Three People": "James_Hoffmann_Three_People",
        "James Hoffmann V60 - Four People": "James_Hoffmann_Four_People",
        "Scott Rao V60 - Two People": "Scott_Rao_Two_People",
        "Scott Rao V60 - Three People": "Scott_Rao_Three_People", 
        "Scott Rao V60 - Four People": "Scott_Rao_Four_People",
        "Kaldi's Coffee V60 - Three People": "Kaldi_Coffee_Three_People",
        "Kaldi's Coffee V60 - Four People": "Kaldi_Coffee_Four_People",
        "Quick Morning V60": "Quick_Morning_V60",
        
        # French Press
        "James Hoffmann's French Press Method": "James_Hoffmann_Method",
        "Tim Wendelboe French Press Method": "Tim_Wendelboe_Method",
        "Scott Rao French Press Method": "Scott_Rao_Method",
        "Blue Bottle French Press Method": "Blue_Bottle_Method",
        "Intelligentsia French Press Method": "Intelligentsia_Method",
        "Stumptown French Press Method": "Stumptown_Method",
        "Counter Culture French Press Method": "Counter_Culture_Method",
        "Verve French Press Method": "Verve_Method",
        "Four Barrel French Press Method": "Four_Barrel_Method"
    }
    
    # Mapeo de métodos de preparación
    method_mapping = {
        "AeroPress": "AeroPress",
        "V60": "V60", 
        "French Press": "FrenchPress"
    }
    
    recipe_dir = title_mapping.get(recipe_title, recipe_title.replace(' ', '_'))
    method_dir = method_mapping.get(brewing_method, brewing_method.replace(' ', ''))
    
    return method_dir, recipe_dir

def copy_audio_files_to_ios(generated_audio_dir, ios_audio_dir):
    """Copiar archivos de audio generados a la estructura iOS"""
    
    print(f"\n📁 Copiando archivos de audio a estructura iOS...")
    
    # Cargar todas las recetas para mapear nombres
    recipes = []
    recipe_files = [
        "PerfectBrew/Resources/recipes_aeropress.json",
        "PerfectBrew/Resources/recipes_v60.json", 
        "PerfectBrew/Resources/recipes_frenchpress.json"
    ]
    
    for file_path in recipe_files:
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                file_recipes = json.load(f)
                recipes.extend(file_recipes)
    
    # Crear mapeo de títulos a archivos generados
    title_to_files = {}
    for recipe in recipes:
        title = recipe['title']
        method = recipe['brewing_method']
        method_dir, recipe_dir = map_recipe_to_ios_structure(title, method)
        
        # Buscar archivos generados para esta receta
        recipe_name = title.replace(' ', '_').replace('/', '_')
        generated_recipe_dir = os.path.join(generated_audio_dir, recipe_name)
        
        if os.path.exists(generated_recipe_dir):
            title_to_files[title] = {
                'method_dir': method_dir,
                'recipe_dir': recipe_dir,
                'generated_dir': generated_recipe_dir
            }
    
    # Copiar archivos
    copied_files = 0
    for title, info in title_to_files.items():
        print(f"\n🎯 Procesando: {title}")
        
        ios_recipe_dir = os.path.join(ios_audio_dir, info['method_dir'], info['recipe_dir'])
        generated_dir = info['generated_dir']
        
        # Copiar archivos de preparación
        prep_source = os.path.join(generated_dir, "preparation")
        prep_dest = os.path.join(ios_recipe_dir, "preparation")
        
        if os.path.exists(prep_source):
            for file in os.listdir(prep_source):
                if file.endswith('.wav'):
                    src = os.path.join(prep_source, file)
                    dst = os.path.join(prep_dest, file)
                    shutil.copy2(src, dst)
                    copied_files += 1
                    print(f"   ✅ Preparación: {file}")
        
        # Copiar archivos de preparación
        brew_source = os.path.join(generated_dir, "brewing")
        brew_dest = os.path.join(ios_recipe_dir, "brewing")
        
        if os.path.exists(brew_source):
            for file in os.listdir(brew_source):
                if file.endswith('.wav'):
                    src = os.path.join(brew_source, file)
                    dst = os.path.join(brew_dest, file)
                    shutil.copy2(src, dst)
                    copied_files += 1
                    print(f"   ✅ Preparación: {file}")
        
        # Copiar archivo de notas
        notes_file = os.path.join(generated_dir, "notes.wav")
        if os.path.exists(notes_file):
            dst = os.path.join(ios_recipe_dir, "notes.wav")
            shutil.copy2(notes_file, dst)
            copied_files += 1
            print(f"   ✅ Notas: notes.wav")
    
    print(f"\n✅ Archivos copiados: {copied_files}")
    return copied_files

def main():
    print("🎯 Integrador de Audio para iOS")
    print("=" * 50)
    
    # Crear estructura de directorios
    create_ios_audio_structure()
    
    # Directorios
    generated_audio_dir = "generated_spanish_audio"  # Cambiar según el directorio generado
    ios_audio_dir = "PerfectBrew/Resources/Audio"
    
    # Verificar que existe el directorio generado
    if not os.path.exists(generated_audio_dir):
        print(f"❌ Directorio de audio generado no encontrado: {generated_audio_dir}")
        print("💡 Ejecuta primero: python3 generate_spanish_audio.py")
        return
    
    # Copiar archivos
    copied_files = copy_audio_files_to_ios(generated_audio_dir, ios_audio_dir)
    
    print(f"\n🎉 INTEGRACIÓN COMPLETADA")
    print(f"📁 Archivos integrados: {copied_files}")
    print(f"📂 Estructura iOS: {ios_audio_dir}")
    print("\n💡 Próximos pasos:")
    print("1. Verificar archivos en Xcode")
    print("2. Actualizar AudioService.swift para usar nuevos archivos")
    print("3. Probar reproducción en la app")

if __name__ == "__main__":
    main()
