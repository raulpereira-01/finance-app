# Finance App

Aplicación móvil en Flutter para registrar ingresos, gastos y categorías de forma local utilizando Hive. Incluye un flujo de onboarding guiado y un panel personalizable con widgets reordenables.

## Características
- **Onboarding paso a paso**: pantalla de bienvenida seguida de formularios para ingresar ingresos, gastos fijos y un resumen previo a usar la app.
- **Gestión de categorías**: creación y edición con selector de color y persistencia local con Hive.
- **Persistencia local**: modelos de ingresos, gastos y categorías registrados como adaptadores de Hive y almacenados en cajas dedicadas.
- **Dashboard configurable**: widgets para balance y desglose de gastos por categoría con opción de habilitar/deshabilitar y reordenar desde la vista de ajustes.
- **Interfaz Material 3**: tema con `colorSchemeSeed` en verde y banners de depuración desactivados.

## Estructura del proyecto
- `lib/main.dart`: inicializa Hive, registra adaptadores y arranca la aplicación con `OnboardingWelcomeScreen`.
- `lib/data/models/`: modelos `CategoryModel`, `IncomeModel` y `ExpenseModel` con los adaptadores generados.
- `lib/domain/entities/`: entidades de dominio para ingresos, gastos, categorías, balance mensual y tipos de widgets del panel.
- `lib/presentation/screens/`: pantallas de onboarding, categorías y dashboard junto con sus widgets auxiliares.
- `lib/core/constants/`: constantes de nombres de cajas Hive.

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

## Notas
- El almacenamiento es completamente local gracias a Hive; no se requiere backend externo.
- `fl_chart` se utiliza para gráficos de gastos por categoría en el dashboard.
