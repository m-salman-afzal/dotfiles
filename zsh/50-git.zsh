alias g="git"

alias gb="git branch"

gdrb() {
	g remote prune origin
	g branch -vv | grep ': gone]' | awk '{print $1}' > /tmp/merged-branches
	cat /tmp/merged-branches | xargs g branch -D
}

alias gfo="g fetch origin"

alias gp="g pull"

alias gc="g commit"

alias gco="g checkout"

alias gph="g push"

alias gceph="gc --allow-empty -m 'temp' && gph"

alias gs="g stash"

alias gsl="gs list"

# push to stash
gsp() {
  git stash push -u -m $1
}

# apply stash
gsa() {
	gsl

	echo -n "Enter the stash number to apply: "
	read stash_no

 	git stash apply "stash@{$stash_no}"
}

# drop stash
gsd() {
	gsl

  echo -n "Enter the stash number to drop: "
	read stash_no

  git stash drop "stash@{$stash_no}"
}

# git add, commit, and push
gacph() {
  g add .
	gc -m $1
	gph
}

alias gw="g worktree"

alias gwl="gw list"

# Create worktree (creates branch if it doesn't exist)
gwa() {
    local branch="$1"
    if [ -z "$branch" ]; then
        echo "Usage: gwa <branch-name>" >&2
        return 1
    fi

    # Flatten branch name for directory (fix/ui-issues -> fix-ui-issues)
    local safe_name="${branch//\//-}"
    local wt_dir="./.worktrees/$safe_name"

    if [ -d "$wt_dir" ]; then
        echo "Worktree already exists at $wt_dir"
        code -n "$wt_dir"
        return 0
    fi

    # Resolve repo root so .env discovery works from any subdirectory
    local repo_root
    repo_root="$(git rev-parse --show-toplevel)" || return 1

    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$wt_dir" "$branch" || return 1
    else
        git worktree add -b "$branch" "$wt_dir" || return 1
    fi

    # Absolute path to the new worktree
    local wt_abs
    wt_abs="$(cd "$wt_dir" && pwd)"

    # Copy every .env* file from the source repo to the same relative path
    # in the worktree. Skips .git internals and the .worktrees dir itself.
    echo "Copying .env files..."
    local count=0
    while IFS= read -r -d '' envfile; do
        local rel="${envfile#$repo_root/}"
        local dest="$wt_abs/$rel"
        mkdir -p "$(dirname "$dest")"
        cp "$envfile" "$dest"
        echo "  $rel"
        count=$((count + 1))
    done < <(
        find "$repo_root" \
            \( -path "$repo_root/.git" -o -path "$repo_root/.worktrees" -o -name node_modules \) -prune \
            -o -type f \( -name ".env" -o -name ".env.*" \) -print0
    )
    echo "Copied $count .env file(s)."

    # Install dependencies
    (
        cd "$wt_abs" || exit 1
        if [ -f "pnpm-lock.yaml" ] || [ -f "package.json" ]; then
            echo "Running pnpm install..."
            pnpm install
        else
            echo "No package.json found, skipping pnpm install."
        fi
    )

    code -n "$wt_abs"
}

# Remove worktree (pass extra args like --force if needed)
gwr() {
    local branch="$1"
    if [ -z "$branch" ]; then
        echo "Usage: wtr <branch-name> [--force]" >&2
        return 1
    fi
    shift

    git worktree remove "./.worktrees/$branch" "$@"
}
