# 🎵 Audio Debug Instructions - 2021 World Champion Recipe

## 🔍 **PROBLEMA ACTUAL**
El audio no se reproduce a pesar de que:
- ✅ Los 8 archivos de audio están en la ubicación correcta
- ✅ El AudioService tiene la lógica correcta
- ✅ El proyecto Xcode está funcionando
- ✅ `isAudioEnabled` está configurado como `true` por defecto

## 🎯 **PASOS DE DEBUGGING**

### 1. **Abrir Xcode y Ejecutar la App**
```bash
# Abre el proyecto
open PerfectBrew.xcodeproj

# Ejecuta en simulador o dispositivo
# Cmd+R para compilar y ejecutar
```

### 2. **Navegar a la Receta del 2021 World Champion**
- Selecciona "AeroPress" como método
- Busca "2021 World AeroPress Champion - Tuomas Merikanto (Finland) - Inverted"
- Inicia el proceso de preparación

### 3. **Verificar Mensajes de Debug en Xcode Console**
Busca estos mensajes específicos:

#### **Al iniciar el timer:**
```
DEBUG: Started timer - First step: [instruction], Duration: [duration]s
DEBUG: startTimer - isPreparationPhase: false
```

#### **Al verificar audio:**
```
DEBUG: hasAudioForCurrentStep - currentStepIndex: [index]
DEBUG: hasAudioForCurrentStep - currentBrewingStep.audioFileName: [filename]
DEBUG: hasAudioForCurrentStep - final result: true
```

#### **Al reproducir audio:**
```
DEBUG: playCurrentStepAudio called
DEBUG: playCurrentStepAudio - currentStepIndex: [index]
DEBUG: playAudio called for recipe: '2021 World AeroPress Champion - Tuomas Merikanto (Finland) - Inverted'
DEBUG: Found audio file in subdirectory: [path]
DEBUG: Playing audio: [filename]
```

#### **Condiciones de auto-play:**
```
DEBUG: Auto-play conditions met, playing audio
```

**O si no funciona:**
```
DEBUG: Auto-play conditions NOT met:
DEBUG: - !isPreparationPhase: [true/false]
DEBUG: - currentStep != previousStep: [true/false]
DEBUG: - hasAudioForCurrentStep(): [true/false]
DEBUG: - !audioService.isPlaying: [true/false]
DEBUG: - isAudioEnabled: [true/false]
```

### 4. **Verificaciones Específicas**

#### **A. Verificar isAudioEnabled**
- En la pantalla de brewing, debería haber un botón de speaker
- El botón debería estar azul (activado), no gris (desactivado)
- Si está gris, tócalo para activar el audio

#### **B. Verificar hasAudioForCurrentStep()**
- Debería retornar `true` para todos los pasos
- Si retorna `false`, hay un problema con la detección de archivos

#### **C. Verificar playCurrentStepAudio()**
- Debería ser llamado automáticamente cuando cambia el paso
- También se puede llamar manualmente con el botón de play

### 5. **Problemas Comunes y Soluciones**

#### **Problema: isAudioEnabled es false**
**Solución:** Toca el botón de speaker para activar el audio

#### **Problema: hasAudioForCurrentStep() retorna false**
**Solución:** Los archivos no están en el bundle de la app
- Verifica que los archivos estén en el proyecto Xcode
- Asegúrate de que estén marcados para incluir en el target

#### **Problema: playCurrentStepAudio() no se llama**
**Solución:** Las condiciones de auto-play no se cumplen
- Verifica los mensajes de debug para ver qué condición falla

#### **Problema: Audio files not found**
**Solución:** Problema con la búsqueda de archivos
- Verifica que el AudioService esté buscando en la ruta correcta
- Confirma que los archivos estén en el bundle

### 6. **Prueba Manual**
Si el auto-play no funciona, prueba manualmente:
1. Inicia el timer de la receta
2. Toca el botón de play (▶️) en la interfaz
3. Debería reproducir el audio del paso actual

### 7. **Verificar Bundle de la App**
Para confirmar que los archivos están en el bundle:
```swift
// Agregar este código temporalmente en AudioService
let bundlePath = Bundle.main.bundlePath
print("DEBUG: Bundle path: \(bundlePath)")

if let audioURL = Bundle.main.url(forResource: "Audio", withExtension: nil) {
    print("DEBUG: Audio folder found in bundle: \(audioURL)")
} else {
    print("DEBUG: Audio folder NOT found in bundle")
}
```

## 🎯 **DIAGNÓSTICO ESPERADO**

### **Si todo funciona correctamente:**
- Deberías ver todos los mensajes de debug
- El audio debería reproducirse automáticamente
- Los controles de audio deberían estar visibles

### **Si hay problemas:**
- Los mensajes de debug te dirán exactamente qué está fallando
- Sigue las soluciones específicas para cada problema

## 📋 **PRÓXIMOS PASOS**

1. **Ejecuta la app** y navega a la receta del 2021 World Champion
2. **Revisa la consola de Xcode** para mensajes de debug
3. **Identifica** qué condición específica está fallando
4. **Aplica** la solución correspondiente

**¡El audio debería funcionar!** Si sigues viendo problemas, comparte los mensajes de debug específicos que aparecen en la consola de Xcode.
