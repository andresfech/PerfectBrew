# Guía: Probar PerfectBrew sin Cable USB

## Opción 1: Wireless Debugging (Recomendada - Más Rápida)

### Requisitos
- iPhone con iOS 17.0 o superior
- macOS Sonoma (14.0) o superior
- Ambos dispositivos en la misma red WiFi
- Xcode 15.0 o superior

### Pasos

1. **Habilitar Wireless Debugging en el iPhone**:
   - Ve a: **Configuración > Privacidad y Seguridad > Modo Desarrollador**
   - Activa **"Modo Desarrollador"** (si no aparece, necesitas conectar el iPhone una vez por cable primero)
   - Luego ve a: **Configuración > Privacidad y Seguridad > Modo Desarrollador > Conexión de red**
   - Activa **"Conexión de red"**

2. **Conectar desde Xcode**:
   - Abre Xcode
   - Ve a: **Window > Devices and Simulators** (⌘ + Shift + 2)
   - En la lista de dispositivos, deberías ver tu iPhone con un icono de WiFi
   - Si no aparece, espera unos segundos o reinicia Xcode

3. **Compilar e instalar**:
   - Selecciona tu iPhone (con icono WiFi) como destino
   - Presiona ⌘ + R para compilar e instalar
   - La primera vez, el iPhone pedirá confirmación - acepta

**Nota**: Si no aparece "Modo Desarrollador" en tu iPhone, significa que nunca lo has conectado por cable. En ese caso, prueba la Opción 2 o 3.

---

## Opción 2: TestFlight (Más Profesional - Requiere Cuenta Pagada)

### Requisitos
- Cuenta de desarrollador de Apple **pagada** ($99/año)
- Acceso a [App Store Connect](https://appstoreconnect.apple.com)

### Pasos

1. **Preparar el proyecto**:
   - En Xcode, selecciona el proyecto
   - Ve a **Signing & Capabilities**
   - Selecciona tu Team (debe ser una cuenta pagada)
   - Cambia el Bundle Identifier si es necesario

2. **Crear un Archive**:
   - En Xcode: **Product > Archive**
   - Espera a que termine la compilación
   - Se abrirá el **Organizer** (Window > Organizer)

3. **Subir a App Store Connect**:
   - En el Organizer, selecciona tu archive
   - Haz clic en **"Distribute App"**
   - Selecciona **"App Store Connect"**
   - Sigue el asistente (puede tardar 10-30 minutos)

4. **Configurar TestFlight**:
   - Ve a [App Store Connect](https://appstoreconnect.apple.com)
   - Selecciona tu app (o créala si es la primera vez)
   - Ve a la pestaña **TestFlight**
   - Agrega testers internos (tu mismo) o externos
   - Descarga la app **TestFlight** en tu iPhone desde el App Store
   - Abre TestFlight y acepta la invitación

**Ventajas**: 
- ✅ Funciona sin conexión física
- ✅ Puedes distribuir a otros dispositivos
- ✅ Las apps duran 90 días sin expirar

**Desventajas**:
- ❌ Requiere cuenta pagada ($99/año)
- ❌ Proceso más largo (primera vez: 1-2 horas)
- ❌ Cada actualización tarda 10-30 minutos en procesarse

---

## Opción 3: Ad Hoc Distribution (Sin Cuenta Pagada)

### Requisitos
- Cuenta de desarrollador (gratuita o pagada)
- Obtener el UDID de tu iPhone

### Paso 1: Obtener el UDID de tu iPhone

**Método A - Desde el iPhone**:
1. Ve a: **Configuración > General > Acerca de**
2. Desplázate hasta encontrar **"Identificador"** (UDID)
3. Mantén presionado para copiarlo

**Método B - Desde iTunes/Finder** (si tienes acceso a otra Mac):
1. Conecta el iPhone a otra Mac
2. Abre Finder (o iTunes en macOS antiguo)
3. Selecciona tu iPhone
4. Haz clic en el número de serie para ver el UDID

**Método C - Desde iCloud**:
1. Ve a [icloud.com/find](https://www.icloud.com/find)
2. Inicia sesión
3. Selecciona tu iPhone
4. El UDID aparece en la información del dispositivo

### Paso 2: Registrar el UDID

1. Ve a [developer.apple.com/account](https://developer.apple.com/account)
2. Inicia sesión con tu cuenta
3. Ve a **Certificates, Identifiers & Profiles**
4. En **Devices**, haz clic en **"+"**
5. Ingresa un nombre (ej: "Mi iPhone") y pega el UDID
6. Guarda

### Paso 3: Crear Perfil de Distribución Ad Hoc

1. En Apple Developer, ve a **Profiles**
2. Haz clic en **"+"**
3. Selecciona **"Ad Hoc"** bajo **Distribution**
4. Selecciona tu App ID (`AE.PerfectBrew`)
5. Selecciona el certificado de distribución (Xcode puede crearlo automáticamente)
6. Selecciona tu iPhone (el que registraste)
7. Dale un nombre y descárgalo

### Paso 4: Configurar Xcode

1. Abre el proyecto en Xcode
2. Selecciona el target **PerfectBrew**
3. Ve a **Signing & Capabilities**
4. Desactiva **"Automatically manage signing"**
5. En **Provisioning Profile**, selecciona **"Import Profile"**
6. Selecciona el perfil que descargaste

### Paso 5: Crear el .ipa

1. En Xcode: **Product > Archive**
2. Cuando termine, en el Organizer:
   - Selecciona tu archive
   - Haz clic en **"Distribute App"**
   - Selecciona **"Ad Hoc"**
   - Sigue el asistente
   - Guarda el archivo `.ipa` en tu Mac

### Paso 6: Instalar en el iPhone

**Método A - AirDrop** (más fácil):
1. Abre Finder en tu Mac
2. Encuentra el archivo `.ipa`
3. Haz clic derecho > **Compartir > AirDrop**
4. Selecciona tu iPhone
5. En el iPhone, acepta la transferencia
6. Toca el archivo para instalar

**Método B - Email/Cloud**:
1. Sube el `.ipa` a iCloud Drive, Google Drive, o envíalo por email
2. Abre el archivo desde tu iPhone
3. Toca para instalar

**Método C - AltStore/Sideloadly** (avanzado):
- Usa herramientas como AltStore o Sideloadly para instalar
- Requiere configuración adicional

### Paso 7: Confiar en el Desarrollador

1. Ve a: **Configuración > General > Gestión de VPN y Dispositivos**
2. Toca tu perfil de desarrollador
3. Toca **"Confiar en [Tu Nombre]"**

---

## Opción 4: Simulador de iOS (Solo para Pruebas Básicas)

Si solo necesitas probar la funcionalidad básica (no características específicas del hardware):

1. En Xcode, selecciona un simulador de iPhone como destino
2. Presiona ⌘ + R
3. La app se abrirá en el simulador

**Limitaciones**:
- ❌ No prueba características del hardware real (cámara, sensores, etc.)
- ❌ El rendimiento puede ser diferente
- ❌ No puedes probar en el dispositivo real

---

## Comparación Rápida

| Método | Requiere Cable | Cuenta Pagada | Tiempo Setup | Duración App |
|--------|---------------|---------------|--------------|--------------|
| Wireless Debugging | No (después de primera vez) | No | 5 min | 7 días (gratis) / 1 año (pagada) |
| TestFlight | No | Sí ($99/año) | 1-2 horas | 90 días |
| Ad Hoc | No | No | 30-60 min | 1 año (pagada) / 7 días (gratis) |
| Simulador | No | No | 0 min | N/A |

---

## Recomendación

1. **Si tienes iOS 17+ y nunca conectaste el iPhone**: Prueba **Opción 3 (Ad Hoc)** - es la más directa sin cable
2. **Si tienes cuenta pagada**: Usa **Opción 2 (TestFlight)** - es la más profesional
3. **Si ya conectaste el iPhone antes**: Usa **Opción 1 (Wireless)** - es la más rápida

---

## Solución de Problemas

### "No devices found" en Wireless Debugging
- Asegúrate de que ambos estén en la misma WiFi
- Reinicia Xcode y el iPhone
- Verifica que "Modo Desarrollador" esté activado

### Error al instalar .ipa: "Unable to install"
- Verifica que el UDID esté correctamente registrado
- Asegúrate de usar el perfil Ad Hoc correcto
- Revisa que el Bundle ID coincida

### TestFlight no muestra la app
- Espera 10-30 minutos después de subir
- Verifica que el build esté procesado en App Store Connect
- Asegúrate de haber aceptado la invitación en TestFlight

