#!/bin/bash

# Script para crear Archive directamente sin validar desarrollo
# Esto evita el error de provisioning profiles para desarrollo

echo "📦 Creando Archive para TestFlight..."
echo ""

# Cambiar al directorio del proyecto
cd "$(dirname "$0")"

# Limpiar build anterior
echo "🧹 Limpiando builds anteriores..."
xcodebuild clean -project PerfectBrew.xcodeproj -scheme PerfectBrew -configuration Release

# Crear Archive directamente con Release (usa distribución)
echo ""
echo "🔨 Creando Archive (esto puede tardar 2-5 minutos)..."
xcodebuild archive \
  -project PerfectBrew.xcodeproj \
  -scheme PerfectBrew \
  -configuration Release \
  -archivePath "./build/PerfectBrew.xcarchive" \
  CODE_SIGN_IDENTITY="Apple Distribution" \
  CODE_SIGN_STYLE="Automatic" \
  DEVELOPMENT_TEAM="76D4MX3XGC" \
  PRODUCT_BUNDLE_IDENTIFIER="AE.PerfectBrew" \
  SKIP_INSTALL=NO

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Archive creado exitosamente!"
  echo "📍 Ubicación: ./build/PerfectBrew.xcarchive"
  echo ""
  echo "📤 Para subir a App Store Connect:"
  echo "   1. Abre Xcode"
  echo "   2. Window > Organizer"
  echo "   3. Selecciona el archive"
  echo "   4. Distribute App > App Store Connect > Upload"
else
  echo ""
  echo "❌ Error al crear el Archive"
  echo "Revisa los errores arriba"
  exit 1
fi

