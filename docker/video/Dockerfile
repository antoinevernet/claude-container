ARG BASE_IMAGE=claude-container-base
FROM ${BASE_IMAGE}

USER root

# ── Blender (CLI/scripting, see docker/common/install-blender.sh) ─
COPY docker/common/install-blender.sh /tmp/install-blender.sh
RUN chmod +x /tmp/install-blender.sh && /tmp/install-blender.sh && rm /tmp/install-blender.sh

# ── ffmpeg ─────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

USER coder

# NOTE: DaVinci Resolve is intentionally NOT installed here.
# It's a GUI-only, GPU-accelerated app distributed from a login-gated
# download on Blackmagic's site with no scriptable installer, and the
# free version has no CLI/headless mode — it can't be meaningfully
# containerized this way. Keep Resolve on the host; use this container
# for ffmpeg/Blender scripting and hand finished renders to Resolve
# on the host for editing/color. See README.md for details.
