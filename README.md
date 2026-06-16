# Aiduet: buildit

A tiered two-agent build orchestrator that leverages the combined power of **Claude Code** and **Gemini CLI** to research, debate, and build software autonomously.

## Overview

`buildit` is the core tool of the Aiduet project. It orchestrates a multi-phase pipeline where two independent AI agents (Claude and Gemini) collaborate to deliver high-quality code.

### The Pipeline
1.  **Research**: Systematically map requirements and codebase.
2.  **Cross-Debate**: Agents critique each other's plans to find the best approach.
3.  **Consensus + Task-Split**: Agreement on the architecture and breakdown of work.
4.  **Build**: Concurrent or sequential implementation of tasks.
5.  **Cross-Verify**: Each agent reviews the other's work.
6.  **Integrate + Test**: Final assembly and verification of the solution.
7.  **Finalize**: Cleanup and completion.

## Features

-   **Tiered Intelligence**: Choose between `low`, `med`, or `high` tiers to balance speed, cost, and rigor.
-   **Resumable State**: Progress is tracked in `./.orchestration/`. If a run is interrupted, it resumes exactly where it left off.
-   **Git-Native**: Agents are instructed not to commit; the orchestrator handles clean commits without AI co-author trailers.
-   **Configurable**: Global configuration in `~/.config/ai-duet/config` and per-project overrides via `.aiduetrc`.

## Installation

Run the provided installation script to set up `buildit` as a global command:

```bash
./install.sh
```

This script will:
1.  Install `buildit` to `~/.local/bin/`.
2.  Add `~/.local/bin` to your `PATH` via `~/.bashrc`.
3.  Create a starter config at `~/.config/ai-duet/config`.
4.  Install bash tab-completion for `buildit`.

## Usage

```bash
# Start a new build with medium rigor (default)
buildit "a FastAPI todo API with JWT auth"

# Start a high-rigor build
buildit high "refactor the database layer to use SQLAlchemy 2.0"

# Check status of the current run
buildit status

# Reset the orchestration state for the current directory
buildit reset
```

## Requirements

-   [Claude Code](https://github.com/anthropics/claude-code)
-   [Gemini CLI](https://github.com/google/gemini-cli) (Note: Migration to Antigravity CLI is recommended before 2026-06-18)
-   `git`

## Configuration

The default configuration can be found in `~/.config/ai-duet/config`. You can adjust model selections, tiers, and behavioral settings (like `HUMAN_GATES` and `AUTO_COMMIT`) there.

---
*Note: Aiduet is designed to stay under your control. The `.orchestration/` directory is automatically git-ignored to keep your history clean.*
