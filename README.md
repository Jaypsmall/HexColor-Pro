# 🎨 HexColor PRO v1.0.1  ![Kotlin](https://img.shields.io/badge/Kotlin-181717?style=flat&logo=kotlin&logoColor=C81AEE) ![Flutter](https://img.shields.io/badge/Flutter-181717?style=flat&logo=flutter&logoColor=70B9EC) ![Rust](https://img.shields.io/badge/Rust-181717?style=flat&logo=rust&logoColor=FF6000)

![Kotlin](https://img.shields.io/badge/Kotlin-181717?style=flat&logo=kotlin&logoColor=C81AEE) ![Flutter](https://img.shields.io/badge/Flutter-181717?style=flat&logo=flutter&logoColor=70B9EC) ![Rust](https://img.shields.io/badge/Rust-181717?style=flat&logo=rust&logoColor=FF6000)
![License](https://img.shields.io/badge/License-PRO-gold)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Linux-brightgreen)

**HexColor PRO** es una aplicación avanzada e interactiva de diseño y cálculo de espacios de color impulsada por un motor de alto rendimiento escrito en **Rust** e integrada en **Flutter**. Diseñada para desarrolladores, diseñadores gráficos y profesionales del color.

<p align="center">
  <a href="https://kotlinlang.org" target="_blank"><img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/kotlin/kotlin-original.svg" height="60" alt="Kotlin" /></a> &nbsp;&nbsp;
  <a href="https://flutter.dev" target="_blank"><img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/flutter/flutter-original.svg" height="60" alt="Flutter" /></a> &nbsp;&nbsp;
  <a href="https://www.rust-lang.org" target="_blank"><img src="https://rustacean.net/assets/rustacean-flat-happy.svg" height="60" alt="Rust" /></a>
</p>

---

## ✨ Características Principales

###  <a href="https://www.rust-lang.org" target="_blank"><img src="https://rustacean.net/assets/rustacean-flat-happy.svg" height="30" alt="Rust" /></a> 1. Motor Nativo en Rust (`rust_engine`)  <a href="https://www.rust-lang.org" target="_blank"><img src="https://rustacean.net/assets/rustacean-flat-happy.svg" height="30" alt="Rust" /></a>
- **Aceleración C-ABI (FFI)**: Algoritmos de conversión matemática de color escritos en Rust para máximo rendimiento.
- **Espacios de Color**: Conversiones entre Hexadecimal (`#RRGGBB`), RGB, HSL, HSV y CMYK.
- **Simulación de Daltonismo**: Algoritmos de transformación espectral para Protanopia, Deuteranopia y Tritanopia.
- **Accesibilidad WCAG 2.1**: Cálculo del ratio de contraste en tiempo real con indicador PASS/FAIL para cumplimiento de estándares web y móviles.
- **Fallback Automático**: Fallback transparente en Dart si la librería nativa (`.dll` / `.so` / `.dylib`) no está presente.

---

### 🌙 2. Rueda HSL con Luna Interactiva (Modo Sombra)
- **Rueda de Color Interactiva**: Selección precisa mediante gestos en anillos de saturación y matiz.
- **Centro de Luna Tradicional/Sombra**: Tocar la luna en el centro de la rueda conmuta entre el modo de luz normal (`moon_light.png`) y el **Modo de Sombras** (`moon_shadow.PNG`), generando instantáneamente paletas de sombras y matices.
- **Modos de Armonía**:
  - Complementario
  - Triádico
  - Análogo
  - Tetrádico (Cuadrado / Rectangular)
  - Complementario Dividido
  - Monocromático
  - Sombras y Matices (Shades & Tints)

---

### 🌓 3. Modo Claro y Modo Oscuro (Gold Theme)
- **Diseño Premium**: Paleta visual dorada adaptativa con sombras elegantes y bordes pulidos.
- **Tema Adaptativo**: Alterna en tiempo real entre un modo oscuro profesional y un modo claro radiante con fondos `#F4F5F8` y tarjetas blancas contrastadas.

---

### 👆 4. Navegación por Desplazamiento Táctil (Swipe)
- **Navegación Táctil**: Pasa entre las pestañas principales (**PALETA**, **RUEDA**, **EXTRACTOR**, **FAVORITOS**) deslizando el dedo horizontalmente.
- **Sincronización Total**: Animación fluida entre la barra de pestañas superior y el `PageView`.

---

### 📸 5. Extractor de Imagen y Modo Sniper (Cámara)
- **Camara Sniper en Vivo**: Retícula móvil en tiempo real para capturar cualquier color del mundo real directamente desde la cámara trasera.
- **Extractor de Paletas**: Carga imágenes desde la galería y extrae automáticamente los colores dominantes utilizando cuantización de imágenes.

---

### ⭐ 6. Gestión de Favoritos y Creador de Paletas
- **Sincronización en Tiempo Real**: `FavoritesManager` unificado para guardar y eliminar colores con 1 solo toque (botón de estrella).
- **Crear Paleta de Favoritos**: Agrupa tus colores favoritos guardados para previsualizarlos juntos como una paleta combinada.
- **Normalización Hex**: Almacenamiento unificado en formato mayúsculas `#RRGGBB` previniendo duplicados.

---

### 📤 7. Exportación Multiformato
Exporta tus paletas con un toque a los formatos más utilizados en desarrollo e ilustración:
- **Variables CSS** (`--color-1: #FF5733;`)
- **Arreglo JSON** (`["#FF5733", "#33FF57"]`)
- **Android XML** (`<color name="palette_1">#FF5733</color>`)
- **Tabla CSV** (Para Excel, Figma y hojas de cálculo)

---

## 🛠️ Estructura del Proyecto

```
HexColorPro/
├── android/                   # Configuración y wrappers nativos de Android
├── assets/                    # Recursos gráficos (moon_light.png, moon_shadow.png)
├── lib/
│   ├── main.dart              # Punto de entrada y PageView con deslizamiento
│   ├── color_manager.dart     # Métodos principales y llamadas al motor
│   ├── rust_engine.dart       # Integración FFI con la librería Rust
│   ├── favorites_manager.dart # Gestión reactiva de favoritos
│   ├── theme/
│   │   └── gold_theme.dart    # Temas claro y oscuro (Gold Theme)
│   ├── screens/
│   │   ├── palette_screen.dart   # Vista de paletas y armonías
│   │   ├── wheel_screen.dart     # Rueda HSL con luna interactiva
│   │   ├── picker_screen.dart    # Extractor de colores de imágenes
│   │   ├── favorites_screen.dart # Favoritos y creador de paletas
│   │   └── settings_dialog.dart  # Diálogo de ajustes
│   └── widgets/
│       ├── color_wheel.dart   # Painter interactivo de la rueda HSL
│       ├── camera_sniper.dart  # Captura de color por cámara en vivo
│       ├── info_card.dart      # Tarjeta de datos RGB/HSL/CMYK y WCAG
│       ├── export_dialog.dart  # Diálogo de exportación CSS/JSON/XML/CSV
│       └── spectrum_dialog.dart# Convertidor de espectro visible (nm)
└── native/
    └── rust_engine/           # Proyecto Rust (Cargo C-ABI)
        ├── Cargo.toml
        └── src/
            └── lib.rs         # Implementación de funciones nativas en Rust
```

---

## 🚀 Compilación e Instalación

### Requisitos
- [Flutter SDK 3.x](https://flutter.dev)
- [Rust & Cargo 1.70+](https://www.rust-lang.org/)

### 1. Clonar el repositorio
```bash
git clone https://github.com/Jaypsmall/HexColor-Pro.git
cd HexColor-Pro
```

### 2. Instalar dependencias de Flutter
```bash
flutter pub get
```

### 3. Compilar el Motor de Rust
Navega a la carpeta del motor y compila en modo Release:
```bash
cd native/rust_engine
cargo build --release
cd ../..
```

*(Opcional para Android: usar `cargo ndk` para generar los `.so` en `android/app/src/main/jniLibs/`)*:
```bash
cd native/rust_engine
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -o ../../android/app/src/main/jniLibs build --release
cd ../..
```

### 4. Ejecutar la aplicación
```bash
flutter run
```

---

## 👨‍💻 Autor y Licencia

Desarrollado con ❤️ por **JAYLIZ**.

Licencia PRO - Todos los derechos reservados.
