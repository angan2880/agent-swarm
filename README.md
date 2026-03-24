# Agent Swarm

A 3-pane tmux-based agent orchestration system for Claude Code. Inspired by [Andrej Karpathy's watcher pattern](https://x.com/karpathy/status/2015883857489522876).

## Architecture

```
┌──────────────────────┬──────────────────────┐
│    Team Leader       │      Verifier        │
│  (implements)        │  (blind QA)          │
├──────────────────────┴──────────────────────┤
│        Orchestrator (you talk here)         │
└─────────────────────────────────────────────┘
```

| Pane | Role | Does | Doesn't |
|------|------|------|---------|
| Bottom | **Orchestrator** | Intake, questions, dispatch, monitor, relay results | Read code, edit files, verify |
| Top-left | **Team Leader** | Read codebase, spawn Agent Teams workers, implement | Verify, talk to user |
| Top-right | **Verifier** | Blind QA — build, simulator, screenshots, PASS/FAIL | Read git diffs, suggest fixes |

## How It Works

1. You tell the orchestrator what you want in plain language
2. It walks through each task asking clarifying questions and verification approach
3. You approve — it dispatches to the Team Leader
4. Team Leader reads the codebase, spawns worker agents, implements
5. Team Leader reports done — orchestrator sends acceptance criteria to Verifier
6. Verifier does blind QA (visual-first, simulator screenshots for iOS)
7. PASS → done. FAIL → fix loop back to Team Leader

## Requirements

- [Claude Code](https://claude.ai/claude-code) with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- tmux
- macOS (bash 3.2 compatible)

## Install

```bash
# Copy role definitions
mkdir -p ~/.local/share/swarm
cp roles/*.md ~/.local/share/swarm/

# Copy launcher
cp bin/swarm ~/.local/bin/swarm
chmod +x ~/.local/bin/swarm

# (Optional) Copy tmux project picker with swarm integration
cp tmux/project-picker.sh ~/.tmux/scripts/project-picker.sh

# Enable Agent Teams in Claude Code settings
# Add to ~/.claude/settings.json:
# "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }
```

## Usage

```bash
# Launch swarm in current project
swarm

# Launch for a specific project
swarm ~/Developer/my-project

# From tmux project picker (if installed)
# Ctrl-A f → select project → F2 = swarm
```

Then just talk to the orchestrator (bottom pane).

## Files

```
roles/
  orchestrator.md   — Translator + coordinator instructions
  team-leader.md    — Implementer instructions (Agent Teams)
  verifier.md       — Blind QA auditor instructions
bin/
  swarm             — Launcher script (3-pane tmux setup)
tmux/
  project-picker.sh — Fuzzy project picker with swarm integration
```
