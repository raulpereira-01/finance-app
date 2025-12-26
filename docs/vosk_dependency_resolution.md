# Resolución del error de dependencias con `vosk_flutter`

El mensaje "Because finance_app depends on vosk_flutter ^0.2.0 which doesn't match any versions" indica que la versión 0.2.0 todavía no está publicada en pub.dev. Para instalar el paquete sin tocar el resto del código:

1. **Verifica la versión disponible**
   - En una terminal con conexión a internet, ejecuta `flutter pub outdated vosk_flutter` o revisa manualmente en https://pub.dev/packages/vosk_flutter las versiones liberadas. Anota la versión más reciente publicada (por ejemplo, `0.1.x`).

2. **Actualiza solo la entrada en `pubspec.yaml`**
   - Sustituye `vosk_flutter: ^0.3.0` por la última versión disponible (p. ej. `vosk_flutter: ^0.1.x`).
   - Guarda el archivo sin cambiar ningún otro bloque de código.

3. **Regenera las dependencias**
   - Ejecuta `flutter pub get` para descargar la versión compatible y actualizar `pubspec.lock`.

4. **Alternativa temporal si necesitas exactamente el API de 0.2.0**
   - Si el API que usas aún no está en pub.dev pero existe en el repositorio del plugin, puedes añadirlo como dependencia git:
     ```yaml
     vosk_flutter:
       git:
         url: https://github.com/alphacep/vosk-flutter.git
         ref: main  # o el tag/commit que contenga el API esperado
     ```
   - Luego ejecuta nuevamente `flutter pub get`.

5. **Comprueba el build**
   - Ejecuta `flutter analyze` y una compilación (por ejemplo, `flutter build apk --debug`) para confirmar que las APIs del plugin siguen siendo compatibles.

Con estos pasos eliminas el error de resolución de dependencias sin modificar la lógica de la app.
