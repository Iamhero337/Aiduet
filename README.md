# Aiduet: buildit

A tiered two-agent build orchestrator where **Gemini** thinks and builds, and **Claude** critiques and approves.

## How it works

Gemini does the heavy lifting — research, planning, and all code. Claude acts as a sparse senior reviewer: it critiques, and Gemini fixes. Claude never writes files.

### Pipeline

1. **Research** — Gemini proposes the architecture
2. **Debate** — Claude critiques → Gemini revises (N rounds, exits early if Claude approves)
3. **Spec** — Gemini writes the spec → Claude reviews once → Gemini applies feedback
4. **Build** — Gemini builds the bulk; Claude gets only small critical tasks
5. **Review loop** — Claude audits the codebase → Gemini fixes → repeat until Claude says `APPROVED` (or max loops hit)
6. **Integrate** — Gemini wires everything together, adds README, runs tests
7. **Finalize** — clean git history, summary

## Usage

```bash
buildit "what to build"              # med tier (default)
buildit low "what to build"          # fast/cheap — 1 debate round, 1 review loop
buildit high "what to build"         # max rigor — 3 rounds, 3 review loops
buildit status                       # progress for the current directory
buildit reset                        # wipe state and start fresh
```

Run from inside the project directory. State lives in `.orchestration/` — re-running resumes automatically.

## Tiers

| Tier | Claude model | Gemini model | Debate rounds | Review loops |
|------|-------------|--------------|---------------|--------------|
| low  | haiku | gemini-2.5-flash | 1 | 1 |
| med  | sonnet | gemini-2.5-pro | 2 | 2 |
| high | opus | gemini-2.5-pro | 3 | 3 |

## Installation

```bash
./install.sh
```

Installs `buildit` to `~/.local/bin/`, adds it to `PATH`, creates a starter config, and sets up tab-completion.

## Requirements

- [Claude Code](https://github.com/anthropics/claude-code)
- [Gemini CLI](https://github.com/google/gemini-cli) (v0.47+, Vertex AI supported)
- `git`

## Configuration

`~/.config/ai-duet/config` — override anything, e.g.:

```sh
# Vertex AI
GEMINI_VERTEX_FLAGS="--project my-gcp-project --location us-central1"

# Models
T_high_claude="claude-fable-5"
T_high_gemini="gemini-2.5-pro"

# Behaviour
PACE_SECONDS=6       # slow down if hitting rate limits
AUTO_COMMIT=true
```

Per-project overrides go in `.aiduetrc` at the project root. CLI flags win over everything.

---
*`.orchestration/` is git-ignored — journals and state never clutter your history.*
