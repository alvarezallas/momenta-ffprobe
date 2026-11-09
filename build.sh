#!/usr/bin/env bash
# Compila un ffprobe.exe mínimo para Windows x64 a partir del código oficial de FFmpeg.
#
# - Sin bibliotecas externas y sin --enable-gpl: el resultado es LGPL 2.1 o posterior.
# - Solo lo que Momenta necesita para leer los datos de los vídeos (duración, tamaño, giro,
#   fecha, modelo y GPS): el protocolo de archivos, los lectores de formato de MP4/MOV/3GP,
#   MKV/WebM, AVI, WMV y MTS/M2TS, y los analizadores de flujo para sacar el tamaño de la imagen.
#   No lleva decodificadores ni codificadores.
#
# Uso (Linux con mingw-w64): ./build.sh            → out/ffprobe.exe y out/BUILD-INFO.txt
# La versión de FFmpeg está en FFMPEG_VERSION (archivo junto a este script).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(tr -d '[:space:]' < "$HERE/FFMPEG_VERSION")"
WORK="$HERE/work"
OUT="$HERE/out"
TARBALL="ffmpeg-$VERSION.tar.xz"
JOBS="$(nproc 2>/dev/null || echo 4)"

mkdir -p "$WORK" "$OUT"
cd "$WORK"

# 1. Código fuente oficial (y su firma), tal cual lo publica ffmpeg.org.
if [ ! -f "$TARBALL" ]; then
  curl -fsSL -o "$TARBALL" "https://ffmpeg.org/releases/$TARBALL"
  curl -fsSL -o "$TARBALL.asc" "https://ffmpeg.org/releases/$TARBALL.asc"
fi
rm -rf "ffmpeg-$VERSION"
tar -xf "$TARBALL"
cd "ffmpeg-$VERSION"

# 2. Configuración mínima.
CONFIGURE=(
  --enable-cross-compile
  --target-os=mingw32
  --arch=x86_64
  --cross-prefix=x86_64-w64-mingw32-
  --pkg-config=false
  --disable-everything
  --disable-autodetect
  --disable-programs
  --enable-ffprobe
  --disable-doc
  --disable-network
  --disable-debug
  --disable-asm
  --disable-avdevice
  --disable-avfilter
  --disable-swscale
  --disable-swresample
  --enable-small
  --enable-static
  --disable-shared
  --enable-protocol=file
  --enable-demuxer=mov,matroska,avi,asf,mpegts
  --enable-parser=h264,hevc,mpeg4video,mpegvideo,vp8,vp9,av1,vc1,aac,ac3,mpegaudio,opus,vorbis,flac
  --extra-cflags=-O2
  --extra-ldflags=-static
)
./configure "${CONFIGURE[@]}"
make -j"$JOBS" ffprobe.exe

# 3. Resultado y datos para reproducirlo.
x86_64-w64-mingw32-strip -o "$OUT/ffprobe.exe" ffprobe.exe
cp "$WORK/$TARBALL" "$WORK/$TARBALL.asc" "$OUT/"
{
  echo "ffprobe.exe para Momenta (Windows x64)"
  echo
  echo "FFmpeg $VERSION — https://ffmpeg.org/releases/$TARBALL"
  echo "Licencia: GNU LGPL 2.1 o posterior (sin --enable-gpl ni bibliotecas externas)"
  echo
  echo "SHA-256:"
  (cd "$OUT" && sha256sum ffprobe.exe "$TARBALL")
  echo
  echo "Compilador: $(x86_64-w64-mingw32-gcc --version | head -1)"
  echo
  echo "./configure ${CONFIGURE[*]}"
} > "$OUT/BUILD-INFO.txt"
cat "$OUT/BUILD-INFO.txt"
