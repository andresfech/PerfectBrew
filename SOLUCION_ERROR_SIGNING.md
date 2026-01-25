# Solución: Error de Provisioning Profile para TestFlight

## El Problema
Xcode está intentando crear un perfil de **desarrollo** (iOS App Development) que requiere dispositivos registrados. Para TestFlight necesitas un perfil de **distribución** (App Store Distribution) que NO requiere dispositivos.

## Solución Rápida

### Opción 1: Verificar que el Bundle ID esté en App Store Connect (Recomendada)

1. **Ve a App Store Connect**:
   - [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Ya creaste la app, así que el Bundle ID debería estar registrado

2. **En Xcode, verifica la configuración**:
   - Selecciona el proyecto **PerfectBrew** (icono azul)
   - Selecciona el target **PerfectBrew**
   - Ve a **Signing & Capabilities**
   - Asegúrate de que:
     - ✅ **Team**: Tu cuenta está seleccionada (76D4MX3XGC)
     - ✅ **Bundle Identifier**: `AE.PerfectBrew`
     - ✅ **Automatically manage signing**: Activado

3. **Intenta crear el Archive de nuevo**:
   - Selecciona **"Any iOS Device"** (no simulador)
   - **Product > Archive**
   - Esta vez debería usar distribución automáticamente

### Opción 2: Forzar Distribución Manualmente

Si la Opción 1 no funciona:

1. **En Xcode**:
   - Selecciona el proyecto
   - Target PerfectBrew > **Signing & Capabilities**
   - **Desactiva** "Automatically manage signing" temporalmente
   - Luego **actívalo de nuevo**
   - Esto fuerza a Xcode a refrescar los perfiles

2. **Verifica en Apple Developer**:
   - Ve a [developer.apple.com/account](https://developer.apple.com/account)
   - **Certificates, Identifiers & Profiles**
   - **Identifiers**: Verifica que `AE.PerfectBrew` existe
   - **Profiles**: Verifica que hay un perfil de "App Store" (no "Development")

### Opción 3: Crear Perfil de Distribución Manualmente

Si aún falla:

1. **En Apple Developer Portal**:
   - Ve a [developer.apple.com/account](https://developer.apple.com/account)
   - **Certificates, Identifiers & Profiles** > **Profiles**
   - Clic en **"+"**
   - Selecciona **"App Store"** bajo **Distribution**
   - Selecciona tu App ID (`AE.PerfectBrew`)
   - Selecciona tu certificado de distribución (si no existe, Xcode lo creará)
   - **NO necesitas seleccionar dispositivos** para App Store
   - Dale un nombre y descárgalo

2. **En Xcode**:
   - Target PerfectBrew > **Signing & Capabilities**
   - **Desactiva** "Automatically manage signing"
   - En **Provisioning Profile**, selecciona **"Import Profile"**
   - Selecciona el perfil que descargaste

3. **Crea el Archive**:
   - Product > Archive

## Verificación

Para verificar que está usando distribución correctamente:

1. Cuando crees el Archive, en el Organizer debería decir:
   - **"App Store"** o **"Distribution"** (no "Development")

2. Si ves errores sobre dispositivos, significa que aún está usando desarrollo en lugar de distribución.

## Nota Importante

Para **TestFlight/App Store Distribution**:
- ✅ NO necesitas dispositivos registrados
- ✅ NO necesitas conectar tu iPhone
- ✅ Solo necesitas el Bundle ID registrado en App Store Connect
- ✅ Xcode debería crear automáticamente el perfil de distribución

El error que ves es porque Xcode está confundido y está intentando crear un perfil de desarrollo en lugar de distribución.

