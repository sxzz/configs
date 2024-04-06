# Fisher plugins:
# jorgebucaran/fisher
# franciscolourenco/done
# jethrokuan/z
# jorgebucaran/replay.fish
# edc/bass
# nickeb96/puffer-fish
# gazorby/fish-abbreviation-tips

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Aliases
alias l='ls -lah'
alias ll='ls -l'
alias la='ls -a'
alias cat='bat -p --paging=never'

alias -s gz='tar -xzvf' >/dev/null
alias -s tgz='tar -xzvf' >/dev/null
alias -s zip='unzip' >/dev/null
alias -s bz2='tar -xjvf' >/dev/null
alias -s jar='java -jar' >/dev/null
alias -s md='open -a /Applications/Typora.app' >/dev/null

alias os='cd ~/Developer/open-source'
alias cppwd='pwd | tr -d \n | pbcopy'

# Git Aliases

# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'

alias gs="git status"
alias gp="git push"
alias gpoh="git push -u origin HEAD"
alias gpf="git push --force-with-lease"
alias gpft="git push --follow-tags"
alias gpdo="git push --delete origin"
alias gpsync="gco (get_main_branch) && gpl && git push origin (get_main_branch)"
alias gpl="git pull --rebase"
alias gcl="git clone"
alias gst="git stash"
alias gstp="git stash pop"

alias main='git checkout (get_main_branch)'
alias gcd="git checkout dev"

alias gb="git branch"
alias gbd="git branch -d"
alias gbD="git branch -D"

alias gfo='git fetch origin'
alias gfu='git fetch (get_upstream)'
alias gfa='git fetch --all'

alias grb="git rebase"
alias grbom="git rebase origin/(get_main_branch)"
alias grbod="git rebase origin/dev"
alias grbum="grt && git rebase (get_upstream)/(get_main_branch)"
alias grbc="git rebase --continue"
alias grba="git rebase --abort"

alias gm="git merge"
alias gmm="git merge (get_upstream)/(get_main_branch)"

alias gl="git log"
alias glo="git log --oneline --graph"

alias grsH="git reset HEAD"
alias grsH1="git reset HEAD~1"
alias grsh="git reset --hard"
alias grsod="git reset --hard origin/dev"
alias grsum="git reset --hard (get_upstream)/(get_main_branch)"

alias ga="git add"
alias gA="git add -A"

alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit -a"
alias gcae="git commit --amend"
alias gcaen="git commit --amend --no-edit -n"
alias gcn="git commit -n"
alias gcnn="git commit --no-edit -n"
alias regcp="gcaen -a && gpf"
alias gcam="git add -A && git commit -m"
alias gfrb="git fetch (get_upstream) && grbom"
alias gsha="git rev-parse HEAD | tr -d \n | pbcopy"

alias gxn='git clean -dn'
alias gx='git clean -df'

alias gcp='git cherry-pick'
alias ggc='git reflog expire --expire-unreachable=now --all && git gc --prune=now'

alias gop='git open'

# GitHub Aliases
alias ghci='gh run list -L 1'
alias fork="gh repo fork --default-branch-only --remote"

function ghdep --argument owner
    test -n "$owner"; or set owner sxzz
    gh search prs --owner $owner is:open author:app/renovate archived:false --json url --jq ".[].url" | gxargs -I URL bash -c 'echo "Approving & merging: URL" && gh pr review --approve URL && gh pr merge --squash --auto URL'
end

function ghfl
    gh api /user --jq '"🎉 @" + .login + " has " + (.followers|tostring) + " followers!"'
end

function ipr
    cd $HOME/Developer/open-source
    and git clone $argv
    and set REPO (string split / $argv)
    and cd (string replace '.git' '' $REPO[-1])
    and fork
    and code .
end

function d
    set SCRIPTS (npm_scripts)
    and if contains start $SCRIPTS
        nr start $argv
    else if contains serve $SCRIPTS
        nr serve $argv
    else
        nr dev $argv
    end
end

# NPM Aliases
alias s="nr start"
alias b="nr build"
alias t="nr test"
alias tu="nr test -u"
alias tw="nr test --watch"
alias lint="nr lint"
alias lintf="nr lint --fix"
alias re="nr release"
alias nio="ni --prefer-offline"
alias u="nu"
alias ui="nu -i"
alias uli="nu --latest -i"
alias reni="rm -fr node_modules && ni"
alias nif="ni -f"
alias tc="nr typecheck"

alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias coder="code -r ."

# Colors
set RED '\e[1;31m'
set GREEN '\e[1;32m'
set YELLOW '\e[1;33m'
set BLUE '\e[1;34m'
set PINK '\e[1;35m'
set SKYBLUE '\e[1;96m'
set RES '\e[0m'

function console.red
    echo -en "$RED$argv$RES"
end

function console.green
    echo -en "$GREEN$argv$RES"
end

function console.yellow
    echo -en "$YELLOW$argv$RES"
end

function console.blue
    echo -en "$BLUE$argv$RES"
end

function console.skyblue
    echo -en "$SKYBLUE$argv$RES"
end
function console.pink
    echo -en "$PINK$argv$RES"
end

function get_main_branch
    set BRANCHES (git branch | sed -e "s/^[* ]*//g")
    if contains dev $BRANCHES
        echo dev
    else if contains main $BRANCHES
        echo main
    else if contains master $BRANCHES
        echo master
    else
        console.red "No main or master branch found\n"
        return 1
    end
end

function get_current_branch
    git rev-parse --abbrev-ref HEAD
end

function get_upstream
    if test -d .git/refs/remotes/upstream
        echo upstream
    else if test -d .git/refs/remotes/origin
        echo origin
    else
        console.red "No main or master branch found\n"
    end
end

# Switch node version (fnm)
function sn
    set versions (fnm ls | awk '{print $2}')
    and set selected (fnm ls | awk '{print $2}' | tail -r | gum filter)
    and fnm use $selected
end

# git new branch & git reset
function gbc
    git branch $argv
    and git reset --hard (get_upstream)/(get_current_branch)
    and git checkout $argv
end

# git branch prune
function gbp
    main

    gum spin --spinner globe --title "Fetching..." -- git remote prune origin
    set _status $status
    if not test $_status -eq 0
        return $_status
    end

    set GONE_BRANCHES (git branch -v | grep -v "^*" | grep "\[gone\]" | awk '{print $1}')
    if not test "$GONE_BRANCHES"
        console.yellow "No gone branches\n"
        return 1
    end

    set DELETE_BRANCHES (gum choose --no-limit --selected=(echo $GONE_BRANCHES | sed -e "s/ /,/g") $GONE_BRANCHES)
    and echo "Delete branches: "
    and console.blue "$DELETE_BRANCHES\n"
    and echo $GONE_BRANCHES | xargs git branch -D
end

function select_branch
    git branch | sed -e "s/^[* ]*//g" | gum filter $argv
end

function select_commit
    set LOG (git log --oneline)
    and printf "%s\n" $LOG | sed -e "s/^ //g" | gum filter $argv | awk '{print $1}'
end

function grst
    set COMMIT_ID (select_commit)
    if not test $COMMIT_ID
        return 1
    end
    set COMMAND "git reset $argv $COMMIT_ID"

    and echo -n "Execute: "
    and console.green "$COMMAND\n"
    and eval $COMMAND
end

function grvt
    set COMMIT_ID (select_commit)
    if not test $COMMIT_ID
        return 1
    end
    set COMMAND "git revert $argv $COMMIT_ID"

    and echo -n "Execute: "
    and console.green "$COMMAND\n"
    and eval $COMMAND
end

function gco
    if test $argv
        git checkout (string split : -m1 $argv)[-1]
    else
        set SELECTED_BRANCH (select_branch)
        if not test $SELECTED_BRANCH
            return 1
        end
        git checkout $SELECTED_BRANCH
    end
    return $status
end


function pr
    gh pr checkout -b "pr/$argv" $argv
    # and set PR_DATA (gh api /repos/{owner}/{repo}/pulls/$argv)
    # and set PR_URL (echo $PR_DATA | jq -r ".head.repo.clone_url")
    # and set PR_BRANCH (echo $PR_DATA | jq -r ".head.ref")
    # and git config "branch.$BRANCH.merge" "refs/heads/$PR_BRANCH"
    # and git config "branch.$BRANCH.remote" $PR_URL
    # and git push -u (gh api /repos/{owner}/{repo}/pulls/$argv --jq ".head.repo.clone_url") "pr/$argv:$PR_BRANCH"
end

function prp
    set BRANCH (get_current_branch)
    and set REMOTE (git config --get "branch.$BRANCH.remote")
    and set REMOTE_BRANCH (git config --get "branch.$BRANCH.merge" | string replace refs/heads/ "")
    and git push -u $REMOTE "$BRANCH:$REMOTE_BRANCH" $argv
end

function npm_scripts
    jq -r '.scripts | keys[]' <package.json
end

# proxy
function proxy
    set -gx https_proxy http://127.0.0.1:6152
    set -gx http_proxy http://127.0.0.1:6152
    set -gx all_proxy socks5://127.0.0.1:6153
end
function unproxy
    set -gu http_proxy
    set -gu https_proxy
    set -gu all_proxy
end
function ssh_proxy
    ssh -o ProxyCommand="nc -X 5 -x 127.0.0.1:6152 %h %p" $argv
end

# Environment Variables
# fish_add_path /usr/local/sbin

# Homebrew
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path /usr/local/bin

# 1Passsword SSH
set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock

# Golang
set -gx GOPATH $HOME/go
fish_add_path $GOPATH/bin

# Flutter
fish_add_path $HOME/Developer/flutter/bin
set -gx FLUTTER_STORAGE_BASE_URL https://mirrors.tuna.tsinghua.edu.cn/flutter
set -gx PUB_HOSTED_URL https://mirrors.tuna.tsinghua.edu.cn/dart-pub

# Android
set -gx ANDROID_HOME $HOME/Android
set -gx NDK_HOME ~/Android/ndk/25.1.8937393

# Composer
fish_add_path $HOME/.composer/vendor/bin

# Cargo, Rust
fish_add_path $HOME/.cargo/bin

# jenv
set PATH $HOME/.jenv/bin $PATH
status --is-interactive; and source (jenv init -|psub)

# iTerm2
source $HOME/.iterm2_shell_integration.fish

# Python pdm
if test -n "$PYTHONPATH"
    set -x PYTHONPATH '/opt/homebrew/opt/pdm/libexec/lib/python3.10/site-packages/pdm/pep582' $PYTHONPATH
else
    set -x PYTHONPATH '/opt/homebrew/opt/pdm/libexec/lib/python3.10/site-packages/pdm/pep582'
end

# pnpm
set -gx PNPM_HOME $HOME/Library/pnpm
set -gx PATH "$PNPM_HOME" $PATH

# Corepack
set -gx COREPACK_ENABLE_DOWNLOAD_PROMPT 0

# Bun
set -Ux BUN_INSTALL "$HOME/.bun"
set -px --path PATH "$HOME/.bun/bin"

# starship
starship init fish | source

# pnpm
set -gx PNPM_HOME /Users/kevin/Library/pnpm
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end

set -a fish_user_paths ./node_modules/.bin

# Ruby
fish_add_path /opt/homebrew/opt/ruby/bin
fish_add_path $HOME/.foundry/bin

# eval "$(sheldon source)"
