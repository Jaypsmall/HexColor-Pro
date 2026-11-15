<div align="center">
 
  <h1>🎨 HEXCOLOR PRO v1.0.2</h1>
  <p><b>Motor de Espacios de Color de Alto Rendimiento | Flutter + Rust + Kotlin</b></p>
  
  <p>
    <img src="https://img.shields.io/badge/Kotlin-181717?style=flat&logo=kotlin&logoColor=C81AEE" alt="Kotlin">
    <img src="https://img.shields.io/badge/Flutter-181717?style=flat&logo=flutter&logoColor=70B9EC" alt="Flutter">
    <img src="https://img.shields.io/badge/Rust-181717?style=flat&logo=rust&logoColor=FF6000" alt="Rust">
    <img src="https://img.shields.io/badge/License-PRO-gold" alt="Licencia">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Linux-brightgreen" alt="Platform">
  </p>
  
  <br>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/kotlin/kotlin-original.svg" height="50" alt="Kotlin" /> &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/flutter/flutter-original.svg" height="50" alt="Flutter" /> &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://rustacean.net/assets/rustacean-flat-happy.svg" height="50" alt="Rust" />
  <br><br>
  
  <a href="https://github.com/Jaypsmall/HexColor-Pro/releases/download/HexColorPro/HexColor_Pro_v1.0.2.apk">
    <img src="https://img.shields.io/badge/📥_DESCARGAR_APK_v1.0.2-181717?style=for-the-badge&logo=android&logoColor=00FF66" alt="Descargar APK">
  </a>

</div>

---

# ✨ Características Principales

##  <a href="https://www.rust-lang.org" target="_blank"><img src="https://rustacean.net/assets/rustacean-flat-happy.svg" height="30" alt="Rust" /></a> 1. Motor Nativo en Rust (`rust_engine`)  <a href="https://www.rust-lang.org" target="_blank"><img src="https://rustacean.net/assets/rustacean-flat-happy.svg" height="30" alt="Rust" /></a>

- **Aceleración C-ABI (FFI)**: Algoritmos de conversión matemática de color escritos en Rust para máximo rendimiento.

- **Espacios de Color**: Conversiones entre Hexadecimal (`#RRGGBB`), RGB, HSL, HSV y CMYK.

- **Simulación de Daltonismo**: Algoritmos de transformación espectral para Protanopia, Deuteranopia y Tritanopia.

- **Accesibilidad WCAG 2.1**: Cálculo del ratio de contraste en tiempo real con indicador PASS/FAIL para cumplimiento de estándares web y móviles.

- **Fallback Automático**: Fallback transparente en Dart si la librería nativa (`.dll` / `.so` / `.dylib`) no está presente.

---

# 🌙 2. Rueda HSL con Luna Interactiva (Modo Sombra)

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
 
<p align="center"> 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/1db2cf75a08088d1d9cbd070cbb85d0afff6f4e1/docs/assets/3n.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/1db2cf75a08088d1d9cbd070cbb85d0afff6f4e1/docs/assets/4n.png" width="20%" />&nbsp;
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/1db2cf75a08088d1d9cbd070cbb85d0afff6f4e1/docs/assets/5n.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/1db2cf75a08088d1d9cbd070cbb85d0afff6f4e1/docs/assets/6n.png" width="20%" />&nbsp;   
</p>

---

# 🌓 3. Modo Claro y Modo Oscuro (Gold Theme)

- **Diseño Premium**: Paleta visual dorada adaptativa con sombras elegantes y bordes pulidos.

- **Tema Adaptativo**: Alterna en tiempo real entre un modo oscuro profesional y un modo claro radiante con fondos `#F4F5F8` y tarjetas blancas contrastadas.

<p align="center"> 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/9011ca547e8e125ec5a0a6dfe3257c8ed093670b/docs/assets/1n.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/9011ca547e8e125ec5a0a6dfe3257c8ed093670b/docs/assets/2n.png" width="20%" />&nbsp;&nbsp;&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/9011ca547e8e125ec5a0a6dfe3257c8ed093670b/docs/assets/b1.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/9011ca547e8e125ec5a0a6dfe3257c8ed093670b/docs/assets/b02.png" width="20%" />&nbsp;   
</p>

---

# 👆 4. Navegación por Desplazamiento Táctil (Swipe)

- **Navegación Táctil**: Pasa entre las pestañas principales (**PALETA**, **RUEDA**, **EXTRACTOR**, **FAVORITOS**) deslizando el dedo horizontalmente.

- **Sincronización Total**: Animación fluida entre la barra de pestañas superior y el `PageView`.

---

# 📸 5. Extractor de Imagen y Modo Sniper (Cámara)

- **Camara Sniper en Vivo**: Retícula móvil en tiempo real para capturar cualquier color del mundo real directamente desde la cámara trasera.

- **Extractor de Paletas**: Carga imágenes desde la galería y extrae automáticamente los colores dominantes utilizando cuantización de imágenes.

<p align="center"> 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/9011ca547e8e125ec5a0a6dfe3257c8ed093670b/docs/assets/7n.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/59be108255a3438a3ebe022599fd39156631a605/docs/assets/15n.png" width="20%" />&nbsp;&nbsp;&nbsp;
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/59be108255a3438a3ebe022599fd39156631a605/docs/assets/b8.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/59be108255a3438a3ebe022599fd39156631a605/docs/assets/b9.png" width="20%" />&nbsp;   
</p>

---

# ⭐ 6. Gestión de Favoritos y Creador de Paletas

- **Sincronización en Tiempo Real**: `FavoritesManager` unificado para guardar y eliminar colores con 1 solo toque (botón de estrella).

- **Crear Paleta de Favoritos**: Agrupa tus colores favoritos guardados para previsualizarlos juntos como una paleta combinada.

- **Normalización Hex**: Almacenamiento unificado en formato mayúsculas `#RRGGBB` previniendo duplicados.

<p align="center"> 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/ed1b4af3d14ccff04d277cd16e5fff4f82e3995b/docs/assets/10n.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/ed1b4af3d14ccff04d277cd16e5fff4f82e3995b/docs/assets/11n.png" width="20%" />&nbsp;&nbsp;&nbsp;
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/49426d6eea4f404de1de596704265d2168b3bfe0/docs/assets/b10b.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/49426d6eea4f404de1de596704265d2168b3bfe0/docs/assets/b11b.png" width="20%" />&nbsp;   
</p>

---

# 📤 7. Exportación Multiformato
Exporta tus paletas con un toque a los formatos más utilizados en desarrollo e ilustración:

- **Variables CSS** (`--color-1: #FF5733;`)

- **Arreglo JSON** (`["#FF5733", "#33FF57"]`)

- **Android XML** (`<color name="palette_1">#FF5733</color>`)

- **Tabla CSV** (Para Excel, Figma y hojas de cálculo)

<p align="center"> 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/45bfdebe2095afb04a97ba865e2fced11f4ea562/docs/assets/16n.png" width="20%" />&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/45bfdebe2095afb04a97ba865e2fced11f4ea562/docs/assets/14n.png" width="20%" />&nbsp;
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/45bfdebe2095afb04a97ba865e2fced11f4ea562/docs/assets/13n.png" width="20%" />&nbsp;&nbsp;&nbsp; 
<img src="https://github.com/Jaypsmall/HexColor-Pro/blob/45bfdebe2095afb04a97ba865e2fced11f4ea562/docs/assets/b12b.png" width="20%" />&nbsp;   
</p>

---

# 👨‍💻 Autor y Licencia

Desarrollado con ❤️ por **Jaypsmall**.

Licencia PRO - Todos los derechos reservados.
