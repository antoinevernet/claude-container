ARG BASE_IMAGE=claude-container-base
FROM ${BASE_IMAGE}

USER root

# ── ssh client (needed to clone corpex over git+ssh below) ────────
RUN apt-get update && apt-get install -y --no-install-recommends openssh-client \
    && rm -rf /var/lib/apt/lists/*

# ── OpenAI Codex CLI ──────────────────────────────────────────────
RUN npm install -g @openai/codex && npm cache clean --force

USER coder

# ── corpex ────────────────────────────────────────────────────────
# Private repo — cloned over SSH, so the build needs agent forwarding:
#   docker build --ssh default -t claude-container-research -f docker/research/Dockerfile .
# (the Justfile's `build-flavor` recipe already passes --ssh default)
# CPU-only PyTorch: there's no NVIDIA GPU under Colima, and the CUDA
# wheels add several GB of unusable libraries.
RUN --mount=type=ssh,uid=1000 \
    mkdir -p -m 0700 ~/.ssh \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null \
    && uv tool install --no-cache --torch-backend cpu "git+ssh://git@github.com/antoinevernet/explorer.git"
