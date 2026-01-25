# Configuración de Iconos de la App

## Problema
Apple requiere iconos en tamaños específicos para validar la app. Actualmente faltan los archivos de iconos.

## Solución Rápida

### Opción 1: Usar Xcode Asset Catalog (Recomendado)

1. **Abre Xcode** y selecciona el proyecto PerfectBrew
2. Ve a `Assets.xcassets` > `AppIcon`
3. **Arrastra un icono de 1024x1024 px** al slot "App Store iOS 1024pt"
4. Xcode generará automáticamente todos los tamaños necesarios

### Opción 2: Generar iconos desde una imagen

Si tienes una imagen de 1024x1024 px:

1. Puedes usar herramientas online como:
   - https://www.appicon.co/
   - https://www.appicon.build/
   - https://icon.kitchen/

2. Sube tu imagen 1024x1024
3. Descarga el set de iconos iOS
4. Descomprime y copia todos los archivos PNG a:
   ```
   PerfectBrew/Assets.xcassets/AppIcon.appiconset/
   ```

### Opción 3: Crear icono simple temporalmente

Para probar rápidamente, puedes crear un icono simple:

1. Crea una imagen de 1024x1024 px con cualquier editor
2. Puede ser un cuadrado de color sólido con el nombre "PerfectBrew"
3. Guárdalo como `AppIcon.png` en:
   ```
   PerfectBrew/Assets.xcassets/AppIcon.appiconset/AppIcon.png
   ```

4. Xcode generará automáticamente los tamaños necesarios desde el 1024x1024

## Verificación

Después de agregar el icono:

1. Limpia el build: **Product > Clean Build Folder** (Shift + Cmd + K)
2. Crea un nuevo Archive: **Product > Archive**
3. Distribuye: **Distribute App** > **TestFlight**
4. La validación debería pasar

## Nota

El archivo `Contents.json` ya está configurado correctamente para aceptar todos los tamaños necesarios. Solo falta agregar el archivo de icono.

