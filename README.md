# Custom Draw Roulette (Flutter)

Ruleta de sorteos interactiva para **web** y otras plataformas soportadas por Flutter. Permite añadir participantes, ajustar **pesos relativos** (mayor peso = más probabilidad de salir) y girar la ruleta con animación. Incluye modo **equipos** (2–4 equipos) con reparto equilibrado por número de miembros.

## Características

- Sorteo **ponderado**: los pesos se normalizan y el ganador se elige de forma proporcional.
- Hasta **50 participantes**; descartar o restaurar sin borrar la lista.
- Modo **solo** o **equipos** con colores predefinidos.
- Interfaz oscura, tipografía Inter (Google Fonts) y animación de giro.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK compatible con `pubspec.yaml`, actualmente ^3.11.3).
- Para web: navegador moderno.

## Cómo ejecutarlo

```bash
flutter pub get
flutter run -d chrome
```

Compilar solo para web:

```bash
flutter build web
```

La salida queda en `build/web/` (carpeta **generada**; no debe subirse al repositorio).

## Estructura del proyecto

| Ruta | Descripción |
|------|-------------|
| `lib/main.dart` | Punto de entrada y tema global. |
| `lib/pages/roulette_page.dart` | Pantalla principal, lógica de giro y diálogo de ayuda. |
| `lib/models/participant.dart` | Participantes, equipos y selección aleatoria ponderada. |
| `lib/widgets/` | Ruleta, paneles de control y overlay del ganador. |
| `web/` | Plantilla HTML y manifest para la compilación web. |

## Licencia y autor

Proyecto de demostración. En la app hay un enlace público al sitio del autor (`soyjere.com`) con fines de atribución; no se usan claves API ni backends en este repositorio.

## Nota para quien clone el repo

No incluyas la carpeta `build/` en Git: son artefactos de compilación (incluidos archivos `.dill` muy grandes) y GitHub avisa si superan ~50 MB. Este proyecto incluye `.gitignore` para ignorarlos.
