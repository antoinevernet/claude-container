# Prime Agent Integration Design

## Goal

Add Prime Agent as a first-class agent CLI in `claude-container`, alongside Claude Code and Pi, using a minimal change set suitable for an upstream pull request.

## Scope

Included:

- Install the stable Prime Agent release during Docker image build.
- Add a `just prime <name> [prompt]` recipe.
- Forward common Prime Agent provider environment variables from the host when set.
- Document Prime Agent in the README, beginner guide, `.env.example`, and container tool notes.
- Keep Prime Agent auth and session state isolated per container under `/home/coder/.prime`.

Excluded:

- Installing Prime Agent from a source checkout.
- Sharing Prime Agent credentials or sessions across containers.
- Adding personal Prime Agent config, packages, skills, harness state, or model defaults.
- Forwarding broad AWS or GCP ambient credentials by default.

## Architecture

Prime Agent will be installed into the base Docker image, not installed when each container is created.

Build-time flow:

```text
Dockerfile
  -> install system dependencies
  -> install Node.js
  -> install Pi Coding Agent
  -> install Prime Agent stable release
  -> create coder user
  -> install Claude Code
  -> copy agent configs
```

Runtime flow:

```text
host .env
  -> just create forwards selected environment variables
  -> Docker container receives only variables set on the host
  -> just prime executes prime-agent in /workspace
  -> Prime Agent stores auth/session state in /home/coder/.prime
```

This matches the current container model: project files persist through `/workspace`, while tool auth and home-directory state are container-local and disposable.

## Components

### Dockerfile

Add a Prime Agent stable install step using the official installer:

```Dockerfile
RUN curl -fsSL https://app.primeintellect.ai/prime-agent/install.sh -o /tmp/prime-agent-install.sh \
    && PRIME_AGENT_INSTALLER_PLAIN=1 sh /tmp/prime-agent-install.sh \
    && rm /tmp/prime-agent-install.sh
```

This ensures `PRIME_AGENT_INSTALLER_PLAIN=1` applies to the installer process during Docker builds.

### Justfile

Add a `prime` recipe that mirrors the existing `claude` and `pi` recipes:

- auto-start the named container if needed
- run `prime-agent` interactively when no prompt is supplied
- run `prime-agent -p "<prompt>"` when a prompt is supplied

Expand `create` to forward common provider variables only when they are set on the host.

Recommended variables:

- `ANTHROPIC_API_KEY`
- `ANTHROPIC_OAUTH_TOKEN`
- `GOOGLE_API_KEY` for current Pi compatibility
- `OPENAI_API_KEY`
- `PRIME_API_KEY`
- `GEMINI_API_KEY`
- `OPENROUTER_API_KEY`
- `GROQ_API_KEY`
- `CEREBRAS_API_KEY`
- `XAI_API_KEY`
- `DEEPSEEK_API_KEY`
- `MISTRAL_API_KEY`
- `ZAI_API_KEY`
- `AI_GATEWAY_API_KEY`
- `HF_TOKEN`
- `FIREWORKS_API_KEY`
- `KIMI_API_KEY`
- `MOONSHOT_API_KEY`
- `OPENCODE_API_KEY`
- `CLOUDFLARE_API_KEY`
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_GATEWAY_ID`
- `PRIME_TEAM_ID`

Do not add AWS or Google Cloud ambient credential forwarding in the minimal PR. Users can pass those explicitly with extra Docker arguments if needed.

### Documentation

Update:

- `README.md`
  - mention Prime Agent in the project description and quick start
  - include Prime Agent in the tools list
  - add `just prime` to the recipe table
  - add neutral auth notes for `/login` and API-key providers

- `docs/getting-started.md`
  - add a beginner-facing Prime Agent explanation
  - include Prime Agent in build contents and recipe reference
  - explain that Prime Agent auth is container-local

- `.env.example`
  - add commented examples for common Prime Agent provider keys

- `config/CLAUDE.md`
  - include `prime-agent` in the available tools list

## Error Handling and Edge Cases

- Prime Agent must launch even when no API key is forwarded, because users can authenticate interactively with `/login`.
- Environment variables should be forwarded only when set, using the existing `${VAR:+-e VAR}` pattern.
- The Prime Agent installer should run in plain/non-interactive mode during Docker builds to avoid TTY-specific output.
- Prompt handling should match existing recipes and use Prime Agent print mode for one-shot prompts.
- No host mount should be added for `/home/coder/.prime`; destroying the container destroys Prime Agent auth and sessions.

## Testing

Verification should include:

```bash
just build
just create prime-smoke
just shell prime-smoke
prime-agent --help
```

Recipe verification should include:

```bash
just prime prime-smoke
just prime prime-smoke "Summarize this workspace"
```

If no provider credentials are configured, the interactive command should still start and allow `/login`.

## Recommendation

Implement this as a small branch in a fork of `paulgp/claude-container`. Keep the branch general-purpose and upstreamable. If later workflow-specific Prime Agent configuration is desired, add it in a separate branch or local fork-only layer.
