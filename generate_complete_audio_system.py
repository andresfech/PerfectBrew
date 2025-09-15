#!/usr/bin/env python3
"""
Script maestro para generar sistema completo de audio con Chatterbox TTS
"""

import os
import subprocess
import sys

def run_script(script_name, description):
    """Ejecutar un script y mostrar el resultado"""
    print(f"\n{'='*60}")
    print(f"🚀 {description}")
    print(f"📄 Script: {script_name}")
    print('='*60)
    
    try:
        result = subprocess.run([sys.executable, script_name], 
                              capture_output=True, text=True, timeout=3600)
        
        if result.returncode == 0:
            print("✅ Script ejecutado exitosamente")
            if result.stdout:
                print("\n📤 Salida:")
                print(result.stdout)
        else:
            print("❌ Error en script")
            if result.stderr:
                print("\n📤 Error:")
                print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print("⏰ Timeout - Script tardó demasiado")
        return False
    except Exception as e:
        print(f"❌ Error ejecutando script: {e}")
        return False
    
    return True

def main():
    print("🎯 GENERADOR COMPLETO DE SISTEMA DE AUDIO")
    print("💰 Usando Chatterbox TTS (GRATIS)")
    print("🌍 Soporte para 23 idiomas")
    print("=" * 70)
    
    # Verificar que estamos en el directorio correcto
    if not os.path.exists("PerfectBrew/Resources/recipes_aeropress.json"):
        print("❌ No se encontró el directorio de la app iOS")
        print("💡 Asegúrate de estar en el directorio raíz del proyecto")
        return
    
    # Lista de scripts a ejecutar
    scripts = [
        ("test_chatterbox_simple.py", "Prueba inicial de Chatterbox TTS"),
        ("generate_spanish_audio.py", "Generar audio en español para todas las recetas"),
        ("integrate_audio_to_ios.py", "Integrar audio en estructura iOS")
    ]
    
    successful_scripts = 0
    
    for script, description in scripts:
        if os.path.exists(script):
            success = run_script(script, description)
            if success:
                successful_scripts += 1
            else:
                print(f"⚠️  Script {script} falló, continuando...")
        else:
            print(f"⚠️  Script {script} no encontrado, saltando...")
    
    # Resumen final
    print(f"\n{'='*70}")
    print("🎉 PROCESO COMPLETADO")
    print(f"✅ Scripts exitosos: {successful_scripts}/{len(scripts)}")
    
    if successful_scripts == len(scripts):
        print("\n🎊 ¡SISTEMA DE AUDIO COMPLETO!")
        print("📁 Archivos generados en:")
        print("   - generated_spanish_audio/ (audio generado)")
        print("   - PerfectBrew/Resources/Audio/ (estructura iOS)")
        print("\n💡 Próximos pasos:")
        print("1. Abrir proyecto en Xcode")
        print("2. Verificar archivos de audio en Resources/Audio/")
        print("3. Actualizar AudioService.swift si es necesario")
        print("4. Probar reproducción en la app")
    else:
        print("\n⚠️  Algunos scripts fallaron")
        print("💡 Revisa los errores arriba y ejecuta manualmente los scripts que fallaron")

if __name__ == "__main__":
    main()
