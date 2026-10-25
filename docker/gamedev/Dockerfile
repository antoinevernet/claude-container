ARG BASE_IMAGE=claude-container-base
FROM ${BASE_IMAGE}

USER root

# ── Godot (headless-capable engine binary) ────────────────────────
# GUI editor needs a display (X11/VNC), not provided by this setup.
# Headless use works fine: `godot --headless --export-release ...`.
ARG GODOT_VERSION=4.3
RUN apt-get update && apt-get install -y --no-install-recommends unzip \
    && curl -fsSL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -o /tmp/godot.zip \
    && unzip /tmp/godot.zip -d /usr/local/bin \
    && mv "/usr/local/bin/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm /tmp/godot.zip \
    && apt-get purge -y unzip && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# ── Blender (CLI/scripting, see docker/common/install-blender.sh) ─
COPY docker/common/install-blender.sh /tmp/install-blender.sh
RUN chmod +x /tmp/install-blender.sh && /tmp/install-blender.sh && rm /tmp/install-blender.sh

USER coder
