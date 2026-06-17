#!/usr/bin/env bash
# =============================================================================
#  run-dashboard  —  Start Aiduet Backend & Frontend
# =============================================================================

# Get the absolute path to the Aiduet directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\e[1;34m🚀 Starting Aiduet Dashboard...\e[0m"

# Start Backend in the background
cd "$DIR/dashboard/backend" && npm run dev > "$DIR/.dashboard-backend.log" 2>&1 &
BACKEND_PID=$!

# Start Frontend in the background
cd "$DIR/dashboard/frontend" && npm run dev > "$DIR/.dashboard-frontend.log" 2>&1 &
FRONTEND_PID=$!

echo -e "\e[1;32m✔ Backend started (PID: $BACKEND_PID)\e[0m"
echo -e "\e[1;32m✔ Frontend started (PID: $FRONTEND_PID)\e[0m"
echo -e "\e[1;36m🔗 Open: http://localhost:5173\e[0m"
echo -e "\e[2m(Logs are hidden. Press Ctrl+C to stop both services)\e[0m"

# Handle shutdown
cleanup() {
  echo -e "\n\e[1;33mStopping services...\e[0m"
  kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
  exit
}

trap cleanup SIGINT SIGTERM

# Keep the script alive
wait
