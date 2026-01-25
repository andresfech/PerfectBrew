# Guía: Probar PerfectBrew en tu iPhone

## Requisitos Previos
- ✅ Cuenta de desarrollador de Apple configurada
- ✅ iPhone conectado a tu Mac por cable USB
- ✅ Xcode abierto con el proyecto PerfectBrew

## Pasos para Instalar

### 1. Preparar tu iPhone

1. **Desbloquea tu iPhone** y manténlo desbloqueado durante el proceso
2. **Confía en la computadora**:
   - Cuando conectes el iPhone, aparecerá un popup: "¿Confiar en esta computadora?"
   - Toca **"Confiar"** e ingresa tu código de iPhone si es necesario

### 2. Configurar Xcode

1. **Abre el proyecto** en Xcode:
   ```bash
   open PerfectBrew.xcodeproj
   ```

2. **Selecciona tu iPhone como destino**:
   - En la barra superior de Xcode, junto al botón ▶️ (Play)
   - Haz clic en el dropdown que dice "Any iOS Device" o el nombre de un simulador
   - Selecciona tu iPhone de la lista (debería aparecer como "iPhone de [Tu Nombre]")

3. **Configura el Signing Team**:
   - En el navegador de archivos (izquierda), selecciona el proyecto **PerfectBrew** (icono azul)
   - Selecciona el target **PerfectBrew** (no los tests)
   - Ve a la pestaña **"Signing & Capabilities"**
   - En **"Team"**, selecciona tu cuenta de desarrollador
   - Si aparece un error sobre el Bundle Identifier `AE.PerfectBrew`, Xcode puede sugerir cambiarlo automáticamente - acepta el cambio sugerido

### 3. Compilar e Instalar

1. **Compila y ejecuta**:
   - Presiona **⌘ + R** (o haz clic en el botón ▶️ Play)
   - Xcode compilará la app y la instalará en tu iPhone

2. **Confía en el desarrollador en el iPhone**:
   - La primera vez que instales, verás un error: "Untrusted Developer"
   - Ve a: **Configuración > General > Gestión de VPN y Dispositivos** (o **Perfiles y Gestión de Dispositivos**)
   - Toca tu perfil de desarrollador
   - Toca **"Confiar en [Tu Nombre]"**
   - Confirma tocando **"Confiar"**

3. **Ejecuta la app**:
   - Vuelve a la pantalla de inicio de tu iPhone
   - Abre la app **PerfectBrew**
   - Debería funcionar normalmente

## Solución de Problemas

### Error: "No signing certificate found"
- **Solución**: Ve a Xcode > Preferences > Accounts
- Agrega tu cuenta de Apple ID si no está
- Selecciona tu cuenta y haz clic en "Download Manual Profiles"

### Error: "Bundle identifier is already in use"
- **Solución**: Xcode sugerirá cambiar el Bundle ID automáticamente
- Acepta el cambio (ej: `AE.PerfectBrew.1` o similar)

### Error: "Untrusted Developer" después de instalar
- **Solución**: Sigue el paso 2.3 arriba para confiar en el desarrollador

### El iPhone no aparece en la lista de dispositivos
- Verifica que el cable USB esté bien conectado
- Desbloquea el iPhone
- Asegúrate de haber tocado "Confiar" cuando apareció el popup
- Cierra y vuelve a abrir Xcode

### La app se cierra inmediatamente al abrirla
- Revisa la consola de Xcode (parte inferior) para ver errores
- Verifica que todos los recursos (audio, JSON) estén incluidos en el bundle
- Asegúrate de que el iPhone tenga iOS 18.5 o superior (según `IPHONEOS_DEPLOYMENT_TARGET`)

## Notas Importantes

- **Cuenta gratuita**: Con una cuenta de desarrollador gratuita, las apps expiran después de 7 días. Necesitarás reinstalarlas.
- **Cuenta pagada ($99/año)**: Las apps duran 1 año sin expirar.
- **Primera instalación**: Puede tardar varios minutos mientras Xcode procesa certificados y perfiles.

## Verificar que Funciona

Una vez instalada, prueba:
- ✅ La app se abre sin errores
- ✅ Navegación entre pantallas funciona
- ✅ Los audios se reproducen correctamente
- ✅ Las recetas se cargan desde los archivos JSON

