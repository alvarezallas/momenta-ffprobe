# momenta-ffprobe

`ffprobe.exe` mínimo para Windows x64 que usa [Momenta](https://github.com/alvarezallas/Fotografias-app)
para leer los datos de los vídeos (duración, tamaño, giro, fecha, modelo del móvil y GPS).
Se compila aquí, de forma automática y reproducible, a partir del código oficial de
[FFmpeg](https://ffmpeg.org/).

*A minimal Windows x64 `ffprobe.exe` used by Momenta to read video metadata, built here from
the official FFmpeg source.*

## Licencia / License

FFmpeg es software libre. Esta compilación **no** usa `--enable-gpl` ni bibliotecas externas,
así que `ffprobe.exe` se distribuye con la licencia
[GNU LGPL 2.1 o posterior](LICENSE) (*GNU Lesser General Public License v2.1 or later*).
FFmpeg es una marca de Fabrice Bellard, creador del proyecto FFmpeg.

Momenta usa `ffprobe.exe` como programa aparte (lo ejecuta y lee su salida); no enlaza su código.

## Código fuente / Source code

Cada [versión publicada](../../releases) incluye, junto a `ffprobe.exe`:

- `ffmpeg-<versión>.tar.xz` y su firma `.asc`: el código fuente exacto que se compiló, tal como lo
  publica ffmpeg.org;
- `build.sh`: la receta de compilación, sin cambios en el código de FFmpeg;
- `BUILD-INFO.txt`: versión, opciones de `configure`, compilador y huellas SHA-256.

Con eso cualquiera puede volver a compilarlo y comprobar el resultado.

## Qué incluye

- Protocolo: `file`.
- Lectores de formato: `mov` (MP4, M4V, MOV, 3GP), `matroska` (MKV, WebM), `avi`, `asf` (WMV) y
  `mpegts` (MTS, M2TS).
- Analizadores de flujo para conocer el tamaño de la imagen: H.264, HEVC, MPEG-4, MPEG-1/2, VP8,
  VP9, AV1, VC-1 y los de audio habituales.
- Sin decodificadores, codificadores, filtros ni acceso a la red.

## Compilar

En Linux con `mingw-w64`:

```bash
./build.sh
```

El resultado queda en `out/`. La versión de FFmpeg está en [`FFMPEG_VERSION`](FFMPEG_VERSION).

## Publicar una versión

1. Cambiar `FFMPEG_VERSION` si hace falta y subir el cambio.
2. Crear una etiqueta `v<versión de FFmpeg>-<n>` (por ejemplo `v8.1.3-1`) y subirla. La acción
   [Compilar ffprobe](.github/workflows/build.yml) compila, prueba que arranca en Windows y que
   es LGPL, y publica la versión con todos los archivos.
