# Guía Completa: TestFlight para PerfectBrew

## Resumen
TestFlight te permite instalar y probar PerfectBrew en tu iPhone sin cable USB. Las apps duran 90 días sin expirar.

**Tiempo estimado**: 30-60 minutos (primera vez) | 10-30 minutos (actualizaciones)

---

## Paso 1: Verificar Configuración en Xcode

### 1.1 Abrir el Proyecto
```bash
open PerfectBrew.xcodeproj
```

### 1.2 Configurar Signing
1. En Xcode, selecciona el proyecto **PerfectBrew** (icono azul) en el navegador izquierdo
2. Selecciona el target **PerfectBrew** (no los tests)
3. Ve a la pestaña **"Signing & Capabilities"**
4. Verifica:
   - ✅ **Team**: Tu cuenta de desarrollador pagada debe estar seleccionada
   - ✅ **Bundle Identifier**: `AE.PerfectBrew` (o el que Xcode sugiera si hay conflicto)
   - ✅ **Automatically manage signing**: Debe estar activado

### 1.3 Verificar Deployment Target
⚠️ **IMPORTANTE**: El proyecto está configurado para iOS 18.5, que es muy alto.

**Verifica la versión de iOS de tu iPhone**:
- Configuración > General > Acerca de > Versión de software

**Si tu iPhone tiene iOS 17.x o menor**:
- Necesitarás bajar el deployment target (te ayudo después si es necesario)

---

## Paso 2: Crear la App en App Store Connect

### 2.1 Acceder a App Store Connect
1. Ve a [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Inicia sesión con tu cuenta de desarrollador pagada
3. Acepta los términos si es la primera vez

### 2.2 Crear Nueva App
1. Haz clic en **"Mis Apps"** (o **"My Apps"**)
2. Haz clic en el botón **"+"** (arriba a la izquierda)
3. Selecciona **"Nueva App"** (o **"New App"**)

### 2.3 Información de la App
Completa el formulario:

- **Plataforma**: iOS
- **Nombre**: PerfectBrew (o el que prefieras)
- **Idioma principal**: Español (o el que prefieras)
- **Bundle ID**: Selecciona `AE.PerfectBrew` de la lista
  - Si no aparece, ve a [developer.apple.com/account](https://developer.apple.com/account) > **Certificates, Identifiers & Profiles** > **Identifiers** y créalo primero
- **SKU**: `perfectbrew-001` (cualquier identificador único)
- **Acceso de usuario**: **Completo** (para TestFlight)

4. Haz clic en **"Crear"** (o **"Create"**)

---

## Paso 3: Crear Archive en Xcode

### 3.1 Seleccionar Dispositivo Genérico
1. En Xcode, en la barra superior, junto al botón Play
2. Selecciona **"Any iOS Device"** (no un simulador)

### 3.2 Crear Archive
1. Menú: **Product > Archive**
2. Espera a que compile (puede tardar 2-5 minutos)
3. Cuando termine, se abrirá automáticamente el **Organizer** (Window > Organizer)

**Si aparece un error**:
- Verifica que "Any iOS Device" esté seleccionado (no simulador)
- Revisa errores de compilación en la pestaña "Issues" (⌘ + 5)

---

## Paso 4: Subir a App Store Connect

### 4.1 Distribuir el Archive
1. En el **Organizer**, selecciona tu archive más reciente
2. Haz clic en **"Distribute App"**
3. Selecciona **"App Store Connect"**
4. Haz clic en **"Next"**

### 4.2 Opciones de Distribución
1. Selecciona **"Upload"** (no "Export")
2. Haz clic en **"Next"**

### 4.3 Opciones de Distribución (Avanzado)
- Deja todo por defecto (App Thinning: All compatible device variants)
- Haz clic en **"Next"**

### 4.4 Revisar y Subir
1. Revisa el resumen
2. Haz clic en **"Upload"**
3. Espera a que termine (puede tardar 5-15 minutos dependiendo del tamaño)

**Progreso**:
- Verás el progreso en la ventana de Xcode
- No cierres Xcode hasta que termine

---

## Paso 5: Procesar Build en App Store Connect

### 5.1 Esperar Procesamiento
1. Ve a [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Selecciona tu app **PerfectBrew**
3. Ve a la pestaña **"TestFlight"**
4. En **"iOS Builds"**, verás tu build con estado **"Processing"**

**Tiempo de procesamiento**: 10-30 minutos (primera vez puede tardar más)

### 5.2 Verificar que Está Listo
- El estado cambiará a **"Ready to Submit"** o **"Ready to Test"**
- Si hay errores, aparecerán en rojo (ej: "Missing Compliance")

---

## Paso 6: Configurar TestFlight

### 6.1 Información de Exportación (Primera Vez)
Si es la primera vez, App Store Connect pedirá información de exportación:

1. Haz clic en **"Provide Export Compliance Information"**
2. Responde las preguntas:
   - **¿Usa encriptación?**: Generalmente **"No"** (a menos que uses HTTPS, que es estándar)
   - Si usas Supabase (que veo en el proyecto), técnicamente usa HTTPS, pero Apple considera esto "exención automática"
   - Selecciona: **"My app uses encryption but is exempt"** o **"No"** según corresponda
3. Guarda

### 6.2 Agregar Testers Internos
1. En la pestaña **TestFlight**, ve a **"Internal Testing"**
2. Haz clic en **"+"** para agregar grupo (o usa el grupo por defecto)
3. Agrega tu email como tester interno:
   - Ve a **"Internal Testers"** en el menú lateral
   - Haz clic en **"+"**
   - Agrega tu email de Apple ID

### 6.3 Seleccionar Build para Testing
1. En **"Internal Testing"**, haz clic en tu grupo (ej: "Internal Testers")
2. Haz clic en **"+"** junto a **"Builds"**
3. Selecciona tu build procesado
4. Haz clic en **"Done"**
5. Haz clic en **"Start Testing"** (si aparece)

---

## Paso 7: Instalar en tu iPhone

### 7.1 Instalar TestFlight
1. En tu iPhone, ve al **App Store**
2. Busca **"TestFlight"**
3. Instala la app (es gratuita y oficial de Apple)

### 7.2 Aceptar Invitación
1. Abre **TestFlight** en tu iPhone
2. Si recibiste un email de invitación, tócalo desde el iPhone
3. O simplemente abre TestFlight - debería aparecer **PerfectBrew** automáticamente si eres tester interno

### 7.3 Instalar la App
1. En TestFlight, verás **PerfectBrew** en la lista
2. Toca **"Accept"** si aparece
3. Toca **"Install"**
4. Espera a que se descargue e instale

### 7.4 Abrir la App
1. La app aparecerá en tu pantalla de inicio con un punto naranja (indicador de TestFlight)
2. Toca para abrir
3. La primera vez, puede pedirte permisos - acepta según corresponda

---

## Paso 8: Actualizar la App (Para Futuras Versiones)

Cuando hagas cambios y quieras probar una nueva versión:

1. **En Xcode**:
   - Incrementa el **Build Number** (CURRENT_PROJECT_VERSION):
     - Selecciona el proyecto
     - Target PerfectBrew > General
     - Incrementa "Build" (ej: de 1 a 2)
   - O cambia el **Version** (MARKETING_VERSION) si es una nueva versión mayor

2. **Crea nuevo Archive**: Product > Archive

3. **Sube el nuevo build**: Sigue los pasos 4-5

4. **En App Store Connect**:
   - Ve a TestFlight
   - El nuevo build aparecerá automáticamente
   - Selecciónalo en tu grupo de testing

5. **En tu iPhone**:
   - Abre TestFlight
   - Verás una notificación de actualización disponible
   - Toca **"Update"**

---

## Solución de Problemas

### Error: "No accounts with App Store Connect access"
- **Solución**: Verifica que tu cuenta tenga rol de **Admin** o **App Manager** en App Store Connect
- Ve a: App Store Connect > Users and Access > Verifica tu rol

### Error: "Bundle ID not found" al crear la app
- **Solución**: Crea el Bundle ID primero:
  1. Ve a [developer.apple.com/account](https://developer.apple.com/account)
  2. Certificates, Identifiers & Profiles > Identifiers
  3. Clic en **"+"**
  4. Selecciona **"App IDs"** > **"App"**
  5. Description: PerfectBrew
  6. Bundle ID: `AE.PerfectBrew` (o el que prefieras)
  7. Capabilities: Deja por defecto
  8. Register

### Error: "Missing Compliance" en App Store Connect
- **Solución**: Completa la información de exportación (Paso 6.1)

### Build aparece como "Processing" por mucho tiempo
- **Normal**: Puede tardar hasta 1 hora la primera vez
- Si pasa de 2 horas, verifica que no haya errores en la pestaña "Activity"

### TestFlight no muestra la app
- Verifica que hayas agregado tu email como tester interno
- Asegúrate de usar el mismo Apple ID que en App Store Connect
- Revisa que el build esté en estado "Ready to Test"

### La app se cierra al abrirla
- Revisa los logs en Xcode: Window > Devices and Simulators > Selecciona tu iPhone > View Device Logs
- Verifica que todos los recursos (audio, JSON) estén incluidos en el bundle

### Error de versión de iOS
- Si tu iPhone tiene iOS 17.x y el deployment target es 18.5, necesitas:
  - Opción A: Actualizar tu iPhone a iOS 18.5 (si está disponible)
  - Opción B: Bajar el deployment target a 17.0 (te ayudo si necesitas esto)

---

## Checklist Rápido

- [ ] Xcode configurado con tu Team
- [ ] App creada en App Store Connect
- [ ] Archive creado y subido
- [ ] Build procesado (estado "Ready to Test")
- [ ] Información de exportación completada
- [ ] Agregado como tester interno
- [ ] Build seleccionado en grupo de testing
- [ ] TestFlight instalado en iPhone
- [ ] App instalada desde TestFlight
- [ ] App funciona correctamente

---

## Notas Importantes

1. **Duración**: Las apps en TestFlight duran **90 días** sin expirar (vs 7 días con desarrollo directo)

2. **Límites**:
   - **Testers internos**: Hasta 100 (miembros de tu equipo)
   - **Testers externos**: Hasta 10,000 (cualquier persona con email)

3. **Versiones**: Puedes tener múltiples builds activos para diferentes grupos de testing

4. **Notificaciones**: Los testers reciben notificaciones cuando hay nuevas versiones disponibles

5. **Feedback**: Los testers pueden enviar feedback directamente desde TestFlight (capturas de pantalla, comentarios)

---

## Próximos Pasos

Una vez que funcione:
- Agrega más testers si quieres feedback
- Configura grupos de testing para diferentes versiones
- Usa TestFlight para distribuir a beta testers antes del lanzamiento

