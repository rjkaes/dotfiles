#!/bin/bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')

# Detect macOS dark mode
if defaults read -g AppleInterfaceStyle &>/dev/null; then
    # Dark mode: brighter colors for dark backgrounds
    BLUE='\033[38;2;88;166;255m'
    MAGENTA='\033[38;2;163;131;237m'
    ORANGE='\033[38;2;219;135;51m'
    YELLOW='\033[38;2;210;160;50m'
    DIM='\033[38;2;140;140;140m'
else
    # Light mode: deeper colors for light backgrounds
    BLUE='\033[38;2;3;102;214m'
    MAGENTA='\033[38;2;130;80;223m'
    ORANGE='\033[38;2;194;93;0m'
    YELLOW='\033[38;2;165;108;0m'
    DIM='\033[38;2;110;110;110m'
fi
BOLD='\033[1m'
RESET='\033[0m'

# Git info
git_part=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    # Branch name, with detached HEAD annotation
    if branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null); then
        git_part="${BOLD}${MAGENTA} ${branch}${RESET}"
    else
        short_sha=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
        # Try to find a tag pointing at HEAD for a friendlier label
        tag=$(git -C "$cwd" describe --tags --exact-match HEAD 2>/dev/null)
        if [ -n "$tag" ]; then
            git_part="${BOLD}${MAGENTA} detached@${tag}${RESET}"
        else
            git_part="${BOLD}${MAGENTA} detached@${short_sha}${RESET}"
        fi
    fi

    # Detect merge/rebase/cherry-pick/bisect state
    git_dir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null)
    git_state=""
    if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
        git_state="REBASING"
    elif [ -f "$git_dir/MERGE_HEAD" ]; then
        git_state="MERGING"
    elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
        git_state="CHERRY-PICKING"
    elif [ -f "$git_dir/BISECT_LOG" ]; then
        git_state="BISECTING"
    fi
    [ -n "$git_state" ] && git_part="${git_part} ${BOLD}${ORANGE}${git_state}${RESET}"

    # Worktree indicator (linked worktree, not the main one)
    if [ -f "$git_dir" ]; then
        # .git is a file (not a dir) in linked worktrees
        git_part="${git_part} ${DIM}worktree${RESET}"
    fi

    staged=$(git -C "$cwd" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    modified=$(git -C "$cwd" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    # Ahead/behind counts relative to upstream (skip if no upstream configured)
    ahead=0; behind=0
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead=$(git -C "$cwd" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
        behind=$(git -C "$cwd" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
    fi

    parts=""
    [ "$staged" -gt 0 ]    && parts="${parts}✚${staged} "
    [ "$modified" -gt 0 ]  && parts="${parts}~${modified} "
    [ "$untracked" -gt 0 ] && parts="${parts}?${untracked} "
    [ "$ahead" -gt 0 ]     && parts="${parts}↑${ahead} "
    [ "$behind" -gt 0 ]    && parts="${parts}↓${behind} "

    # Stash count
    stash_count=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
    [ "$stash_count" -gt 0 ] && parts="${parts}⚑${stash_count} "

    parts="${parts% }"
    [ -n "$parts" ] && git_part="${git_part} ${BOLD}${ORANGE}[${parts}]${RESET}"
fi

# Context usage
ctx_part=""
if [ -n "$used_pct" ]; then
    used_int=${used_pct%.*}
    ctx_part="${DIM}${used_int}%${RESET}"
    if [ -n "$input_tokens" ]; then
        total=0
        [ -n "$input_tokens" ] && total=$((total + input_tokens))
        [ -n "$cache_create" ] && total=$((total + cache_create))
        [ -n "$cache_read" ] && total=$((total + cache_read))
        # Format as K tokens
        total_k=$((total / 1000))
        ctx_part="${DIM}${used_int}% (${total_k}k)${RESET}"
    fi
fi

# Model
model_part=""
[ -n "$model" ] && model_part="${BOLD}${YELLOW}${model}${RESET}"

SEP="${DIM}│${RESET}"

short_cwd="${cwd##*/}"

# Build output, only adding separators between non-empty sections
output="${BOLD}${BLUE}${short_cwd}${RESET}${git_part}"
[ -n "$model_part" ] && output="${output} ${SEP} ${model_part}"
[ -n "$ctx_part" ]   && output="${output} ${SEP} ${ctx_part}"

echo -e "$output"
