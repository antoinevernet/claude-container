#!/usr/bin/env bash
# Installs Blender's official Linux x64 tarball build (CLI/scripting use).
# No GPU passthrough or display is assumed, so this only supports headless
# use: `blender -b file.blend -f 1`, Python scripting via `blender -b -P script.py`,
# command-line rendering, etc. The interactive GUI needs an X11/VNC display
# forwarded into the container, which this setup does not provide.
set -euo pipefail

BLENDER_SERIES="${BLENDER_SERIES:-4.2}"
BLENDER_VERSION="${BLENDER_VERSION:-4.2.3}"

curl -fsSL "https://download.blender.org/release/Blender${BLENDER_SERIES}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" -o /tmp/blender.tar.xz
tar -xJf /tmp/blender.tar.xz -C /opt
ln -s "/opt/blender-${BLENDER_VERSION}-linux-x64/blender" /usr/local/bin/blender
rm /tmp/blender.tar.xz
