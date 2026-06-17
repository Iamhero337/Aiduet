# Architecture: Aiduet

## Overview
Aiduet is a tiered two-agent build orchestrator that leverages Claude Code and Gemini CLI to autonomously build software projects from high-level descriptions.

## Components

### 1. Orchestrator (`buildit`)
- A Bash script that manages the 6-phase development pipeline:
  1. Research
  2. Cross-Debate
  3. Consensus Spec + Task Division
  4. Build
  5. Cross-Verification
  6. Integration + Test
- Supports tiers: `low`, `med`, `high` which scale model selection and effort.
- Maintains state in a local `.orchestration/` directory.

### 2. Agents
- **Claude Code:** Used for planning, building, and verification.
- **Gemini CLI (Antigravity):** Used for planning, building, and verification.

### 3. Dashboard (Planned)
- A local web interface to control the orchestrator.
- **Features:**
  - Task input field.
  - Tier selection (low/med/high).
  - Project directory selection.
  - Split-pane view:
    - Left: Real-time terminal output of the orchestrator.
    - Right: Gemini agent output/status.

## Data Flow
1. User provides a prompt via Dashboard.
2. Dashboard invokes `buildit` with selected tier and directory.
3. `buildit` executes phases, calling Claude and Gemini.
4. Terminal output is streamed back to the Dashboard.
