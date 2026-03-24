#!/usr/bin/env bash
# Fuzzy project picker for tmux
# Lists ~/Developer projects, marks active sessions with *, creates/switches sessions
# F2 in fzf launches as a swarm (agents + watcher)

PROJECT_DIR="$HOME/Developer"

# Get list of active tmux sessions
active_sessions=$(tmux list-sessions -F '#S' 2>/dev/null)

# Build project list with active markers
project_list=""
for dir in "$PROJECT_DIR"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    # Skip hidden dirs and non-project dirs
    [[ "$name" == _* ]] && continue

    if echo "$active_sessions" | grep -qx "$name"; then
        project_list+="* $name"$'\n'
    elif echo "$active_sessions" | grep -qx "${name}-swarm"; then
        project_list+="S $name"$'\n'
    else
        project_list+="  $name"$'\n'
    fi
done

# Sort: active sessions first, then alphabetical
sorted=$(echo "$project_list" | sort -t' ' -k1,1r -k2,2)

# Fuzzy pick — Enter = normal session, Ctrl-S = swarm
selected=$(echo "$sorted" | fzf \
    --header="  Projects (* = active, S = swarm) | Enter = open, F2 = swarm" \
    --prompt="Switch to: " \
    --height=100% \
    --reverse \
    --border=rounded \
    --no-info \
    --expect=f2 \
    --color="bg+:#313244,fg+:#cdd6f4,hl:#89b4fa,hl+:#89b4fa,pointer:#89b4fa,prompt:#a6e3a1,header:#6c7086")

[ -z "$selected" ] && exit 0

# Parse fzf output: first line is the key pressed, second is the selection
key=$(echo "$selected" | head -1)
choice=$(echo "$selected" | tail -1)

# Strip the marker prefix
project=$(echo "$choice" | sed 's/^[*S ] //')
project_path="$PROJECT_DIR/$project"

if [ "$key" = "f2" ]; then
    # Launch as swarm
    swarm_session="${project}-swarm"

    if tmux has-session -t="$swarm_session" 2>/dev/null; then
        tmux switch-client -t "$swarm_session"
    else
        # Launch swarm in background, then switch to it
        swarm "$project_path" &
        sleep 7
        tmux switch-client -t "$swarm_session" 2>/dev/null || \
            tmux display-message "Swarm starting... try again in a moment"
    fi
else
    # Normal session
    if ! tmux has-session -t="$project" 2>/dev/null; then
        tmux new-session -d -s "$project" -c "$project_path"
    fi
    tmux switch-client -t "$project"
fi
