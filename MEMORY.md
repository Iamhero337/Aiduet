# Memory: Aiduet

## Project Log

### 2026-06-17: Initialization & Troubleshooting
- **Task:** Create a local dashboard and fix Claude token consumption.
- **Status:** Initial research completed.
- **Findings:**
    - `buildit` uses very high turn limits for Claude (up to 400 in `high` tier), which likely causes rapid token depletion.
    - The script uses a 6-phase pipeline with multiple rounds of debate.
- **Plan:**
    1. Reduce default turn limits in `buildit` to more sensible values.
    2. Implement the Dashboard using a modern web stack (React/Vite).
    3. Ensure the Dashboard can stream terminal output.
    4. Fix the Claude token usage by optimizing how it's called.

## Technical Notes
- `.orchestration/` is ignored by git and stores the internal state of a build.
- `buildit` requires `claude` and `gemini` (or `antigravity`) in the PATH.
