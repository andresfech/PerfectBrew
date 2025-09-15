# 🎵 Sistema de Generación de Audio para PerfectBrew

Este sistema utiliza **Chatterbox TTS** (Resemble AI) para generar audio automáticamente para todas las recetas de la app PerfectBrew.

## 🌟 Características

- ✅ **100% Gratuito** (Open Source, MIT License)
- ✅ **23 idiomas** soportados (incluyendo español)
- ✅ **Calidad SoTA** (State of the Art)
- ✅ **Escalable** - Genera audio para todas las recetas automáticamente
- ✅ **Integración iOS** - Estructura de directorios compatible con la app

## 🚀 Instalación Rápida

```bash
# 1. Instalar Chatterbox TTS
pip3 install chatterbox-tts

# 2. Ejecutar sistema completo
python3 generate_complete_audio_system.py
```

## 📁 Archivos del Sistema

### Scripts Principales
- `generate_complete_audio_system.py` - **Script maestro** (ejecuta todo)
- `generate_spanish_audio.py` - Genera audio en español
- `generate_all_recipe_audio.py` - Genera audio en inglés
- `integrate_audio_to_ios.py` - Integra audio en estructura iOS

### Scripts de Prueba
- `test_chatterbox_simple.py` - Prueba básica
- `test_chatterbox_audio.py` - Prueba multilingüe

## 🎯 Uso

### Opción 1: Sistema Completo (Recomendado)
```bash
python3 generate_complete_audio_system.py
```

### Opción 2: Paso a Paso
```bash
# 1. Prueba inicial
python3 test_chatterbox_simple.py

# 2. Generar audio en español
python3 generate_spanish_audio.py

# 3. Integrar en iOS
python3 integrate_audio_to_ios.py
```

## 📂 Estructura de Salida

```
generated_spanish_audio/
├── James_Hoffmann_V60_Single_Serve/
│   ├── preparation/
│   │   ├── step_01.wav
│   │   ├── step_02.wav
│   │   └── ...
│   ├── brewing/
│   │   ├── step_01.wav
│   │   ├── step_02.wav
│   │   └── ...
│   └── notes.wav
└── ...

PerfectBrew/Resources/Audio/
├── AeroPress/
│   ├── 2024_World_Champion/
│   ├── James_Hoffmann_Ultimate/
│   └── ...
├── V60/
│   ├── James_Hoffmann_Single/
│   ├── James_Hoffmann_Two_People/
│   └── ...
└── FrenchPress/
    ├── James_Hoffmann_Method/
    └── ...
```

## 🌍 Idiomas Soportados

- **es** - Español
- **en** - Inglés  
- **fr** - Francés
- **de** - Alemán
- **it** - Italiano
- **pt** - Portugués
- **ru** - Ruso
- **ja** - Japonés
- **ko** - Coreano
- **zh** - Chino
- Y 13 idiomas más...

## ⚙️ Configuración Avanzada

### Cambiar Idioma
Edita `generate_spanish_audio.py`:
```python
# Cambiar de "es" a "en", "fr", "de", etc.
wav = model.generate(instruction, language_id="en")
```

### Usar Voz Personalizada
```python
# En el script, especifica una voz de referencia
wav = model.generate(text, audio_prompt_path="mi_voz.wav")
```

### Ajustar Calidad
```python
# En el script, ajusta parámetros
wav = model.generate(text, 
                    language_id="es",
                    exaggeration=0.7,  # Más expresivo
                    cfg_weight=0.3)    # Mejor pacing
```

## 🔧 Integración con iOS

### 1. Verificar Archivos
Abre Xcode y verifica que los archivos estén en:
```
PerfectBrew/Resources/Audio/
```

### 2. Actualizar AudioService.swift
Si es necesario, actualiza las rutas de audio:
```swift
// Ejemplo de ruta actualizada
let audioPath = "Audio/\(method)/\(recipeName)/brewing/step_\(stepNumber).wav"
```

### 3. Probar Reproducción
Ejecuta la app y verifica que el audio se reproduzca correctamente.

## 📊 Estadísticas de Generación

Para una receta típica:
- **Preparación**: 3-5 pasos (~30 segundos de audio)
- **Preparación**: 5-7 pasos (~60 segundos de audio)  
- **Notas**: 1 archivo (~15 segundos de audio)
- **Total por receta**: ~105 segundos de audio

Para todas las recetas (~30 recetas):
- **Tiempo de generación**: ~30-60 minutos
- **Archivos generados**: ~900 archivos de audio
- **Tamaño total**: ~500MB de audio

## 🐛 Solución de Problemas

### Error: "CUDA not available"
```bash
# El script ya está configurado para CPU, pero si hay problemas:
export CUDA_VISIBLE_DEVICES=""
```

### Error: "Model not found"
```bash
# Reinstalar Chatterbox
pip3 uninstall chatterbox-tts
pip3 install chatterbox-tts
```

### Error: "Permission denied"
```bash
# Dar permisos de ejecución
chmod +x *.py
```

## 💡 Próximas Mejoras

- [ ] **Clonación de voz** - Usar voz personalizada
- [ ] **Múltiples idiomas** - Generar en varios idiomas simultáneamente
- [ ] **Optimización** - Compresión de audio
- [ ] **Batch processing** - Procesamiento en lotes más eficiente
- [ ] **UI Integration** - Interfaz gráfica para generación

## 📚 Referencias

- [Chatterbox TTS GitHub](https://github.com/resemble-ai/chatterbox)
- [Resemble AI](https://resemble.ai/)
- [Documentación Chatterbox](https://resemble-ai.github.io/chatterbox_demopage/)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

---

**¡Disfruta generando audio para tu app PerfectBrew!** ☕️🎵
