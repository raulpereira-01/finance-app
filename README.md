# Finance App

Aplicación móvil en Flutter para registrar ingresos, gastos y categorías de forma local utilizando Hive. Incluye un flujo de onboarding guiado y un panel personalizable con widgets reordenables.

## Características
- **Onboarding paso a paso**: pantalla de bienvenida seguida de formularios para ingresar ingresos, gastos fijos y un resumen previo a usar la app.
- **Gestión de categorías**: creación y edición con selector de color y persistencia local con Hive.
- **Persistencia local**: modelos de ingresos, gastos y categorías registrados como adaptadores de Hive y almacenados en cajas dedicadas.
- **Dashboard configurable**: widgets para balance y desglose de gastos por categoría con opción de habilitar/deshabilitar y reordenar desde la vista de ajustes.
- **Interfaz Material 3**: tema con `colorSchemeSeed` en verde y banners de depuración desactivados.
- **Autenticación con Firebase**: sesión basada en `FirebaseAuth` (email/contraseña o anónimo) antes de desbloquear la app; la biometría local se mantiene con `AuthenticationGate`.

## Flujo principal
- **Autenticación**: `FirebaseAuthGate` comprueba la sesión; si no hay usuario muestra un formulario simple de email/contraseña y opción anónima. Tras autenticarse, `AuthenticationGate` solicita biometría/PIN antes de cargar la app.
- **Navegación**: la `MainScreen` expone tres pestañas (Inicio, Movimientos y Ajustes) manteniendo el estado de cada una con un `IndexedStack`.
- **Panel**: el `DashboardScreen` muestra tarjetas reordenables (balance, gastos por categoría e ingresos vs gastos) basadas en la configuración almacenada en Hive.
- **Movimientos**: la vista de movimientos permite capturar ingresos, gastos y nuevas categorías con formularios rápidos.

## Estructura del proyecto
- `lib/main.dart`: inicializa Hive, registra adaptadores y arranca la aplicación con `OnboardingWelcomeScreen`.
- `lib/data/models/`: modelos `CategoryModel`, `IncomeModel` y `ExpenseModel` con los adaptadores generados.
- `lib/domain/entities/`: entidades de dominio para ingresos, gastos, categorías, balance mensual y tipos de widgets del panel.
- `lib/presentation/screens/`: pantallas de onboarding, categorías y dashboard junto con sus widgets auxiliares.
- `lib/core/constants/`: constantes de nombres de cajas Hive.

### Persistencia e internacionalización
- Los servicios en `lib/domain/services/` encapsulan la lectura/escritura en Hive para periodos seleccionados, resúmenes mensuales y configuración del dashboard.
- La clase `AppLocalizations` ofrece un diccionario sencillo de cadenas en inglés y español utilizado en toda la UI.
- Los adaptadores generados (.g.dart) se crean con `build_runner` y deben mantenerse sincronizados con los modelos anotados con `@HiveType`.

## Requisitos previos
- Flutter 3.10+ y SDK de Dart alineado (ver `environment` en `pubspec.yaml`).
- Herramientas de plataforma (Android SDK, Xcode, etc.) configuradas para compilar apps móviles o escritorio.

## Configuración y ejecución
1. Instala dependencias de Dart y Flutter:
   ```bash
   flutter pub get
   ```
2. Ejecuta la app en un emulador o dispositivo conectado:
   ```bash
   flutter run
   ```
3. (Opcional) Genera los adaptadores de Hive al modificar modelos:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Pruebas
Ejecuta la suite de tests de Flutter:
```bash
flutter test
```

## Configuración de Firebase
- **Android**: coloca `google-services.json` en `android/app/` (ya incluido para el id `com.example.finance_app`). El plugin de Google Services está aplicado en `android/app/build.gradle.kts`.
- **iOS**: coloca `GoogleService-Info.plist` en `ios/Runner/` y ejecuta `pod install` dentro de `ios/` después de integrarlo. Se incluye `ios/Runner/GoogleService-Info.plist.example` como referencia de estructura.
- **Inicialización**: `Firebase.initializeApp()` se ejecuta en `main.dart` antes de abrir las cajas de Hive.
- **Sesión/UI**: la app usa `FirebaseAuth.instance.authStateChanges()` para mostrar la pantalla de login/registro o el contenido principal protegido con biometría.

## Notas
- El almacenamiento es completamente local gracias a Hive; no se requiere backend externo.
- `fl_chart` se utiliza para gráficos de gastos por categoría en el dashboard.
