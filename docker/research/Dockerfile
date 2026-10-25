ARG BASE_IMAGE=claude-container-base
FROM ${BASE_IMAGE}

# ── OpenAI Codex CLI ──────────────────────────────────────────────
RUN npm install -g @openai/codex

# ── corpex ────────────────────────────────────────────────────────
# Private repo — cloned over SSH, so the build needs agent forwarding:
#   docker build --ssh default -t claude-container-research -f docker/research/Dockerfile .
# (the Justfile's `build-flavor` recipe already passes --ssh default)
RUN --mount=type=ssh,uid=1000 \
    mkdir -p -m 0700 ~/.ssh \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null \
    && uv tool install "git+ssh://git@github.com/antoinevernet/explorer.git"
