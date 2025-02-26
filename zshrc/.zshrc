# Created by Zap installer
# https://www.zapzsh.org/
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/exa"
plug "wintermi/zsh-mise"

export EDITOR=nvim
export VISUAL="$EDITOR"

source ~/private.zsh

## PSQL
alias psql-local="psql postgres://$1:$2@localhost:5432/$3"

## utils aliases
alias home='~/'
alias update='source ~/.zshrc';
alias update-tmux='tmux source ~/.config/tmux/tmux.conf';
alias update-nvim='source ~/.config/nvim';
alias l='eza --icons --group-directories-first -a'
alias ll='eza -l --icons --no-user --group-directories-first  --time-style long-iso'
alias la='eza -la --icons --no-user --group-directories-first  --time-style long-iso'
alias tree='eza --tree -a --level=5'
alias lg='lazygit';
alias dlz='lazydocker';
alias lnpm='lazynpm';
alias localserver='lite-server';
alias cls='clear';
alias repos='~/repos';
alias rootdir='~/';
alias delDir='rm -rf';
alias history="history 1 | cut -c 8- | sed -e 's/^ [0-9]\{1,5\}  /    /gi' | fzf | pbcopy";


## git aliases
alias gh-create="gh repo create $1 --source=. --remote=upstream";

## git add/commit/push
function gpush() {
    git add .
    if [ "$1" != "" ]
    then
        git commit -m "$1"
    else
        git commit -m update # default commit message is `update`
    fi # closing statement of if-else block
    git push origin HEAD
}
alias greset="git restore .";
alias gc="git commit -m";
alias gnb="git checkout -b"
alias gcb-local="git checkout";
function gcb-remote() { git switch -c "$1" origin/"$1"; }
alias gs="git status";
alias gp="git pull";
alias gf="git fetch";
alias gpush="git push";
alias gd="git diff";
alias ga="git add .";
alias gac="git add . && oc";
alias gdel-local="git branch -D";
alias gdel-remote="git push orgin --delete";
alias glog='git log --oneline';
alias gfindbycommit='git log --all --grep';
alias gfindbydeveloper='git log --author';
function gdiff() { git diff --color --no-index "$1" "$2" | diff-so-fancy; };
function cdiff() { code --diff "$1" "$2"; };

## npm aliases
alias ni="npm install";
alias nrs="npm run start -s --";
alias nrb="npm run build -s --";
alias nrd="npm run dev -s --";
alias nrt="npm run test -s --";
alias nrtw="npm run test:watch -s --";
alias nrv="npm run validate -s --";
alias rmn="rm -rf node_modules";
alias npm-clean="rm -rf node_modules package-lock.json && npm cache clean --force && npm i --force && say NPM is done";
alias nicache="npm install --prefer-offline";
alias nioff="npm install --offline";
alias db-push="npm run db-push";

## Kub aliases
alias k="kubectl";
alias kx="kubectx";
alias kn="kubens";
alias klogs="kubectl logs -f";
alias kpods="kubectl get pods";
alias kcontext="kubectl config view";
alias kcurrentcontext="kubectl config current-context";
alias kusecontext="kubectl config use-context";
alias kresource="k describe pod";
alias kportforward-staging="k port-forward -n staging";
alias kportforward-prod="k port-forward -n production";
alias kportforward-sandbox="k port-forward -n sandbox";

## Docker aliases
alias d="docker";
alias dls='d ps --filter "status=running" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"';
alias dstart="docker ps -a --filter 'status=exited' --format '{{.Names}}' | fzf --multi | xargs -r -I {} sh -c 'docker start {}; echo Started container: {}'"
alias dls-stopped='d ps --filter "status=exited" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"';
alias dstop-all='d stop $(docker ps -q)';
alias dstop="docker ps --format '{{.Names}}' | fzf --multi | xargs -r -I {} sh -c 'docker stop {}; echo Stopped container: {}'"
alias drmvol="docker ps -a --format '{{.Names}}' | fzf --multi | xargs -r -I {} sh -c 'docker rm -v {}; echo Removed container: {}'"

## Tasks Shortcut
## https://github.com/kakengloh/tsk
alias tsk-new="tsk new";
alias thp="tsk new -s todo -p high -d 1h"
alias trm="tsk rm";
alias tls="tsk ls";
alias tboard="tsk board";
alias tdo="tsk todo";
alias twip="tsk doing";
alias tdone="tsk done";


# get nx auto complete
source ~/.dotfiles/zshrc/plugins/nx-completion/nx-completion.plugin.zsh


# get zsh complete kubectl
source <(kubectl completion zsh)
alias kubectl=kubecolor
# make completion work with kubecolor
compdef kubecolor=kubectl

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# ~/.config/tmux/plugins
export PATH=$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin:$PATH

## Fire UP Starship https://starship.rs/
eval "$(starship init zsh)"

## Fire UP FNM
eval "$(fnm env --use-on-cd)"

# Add pyenv to PATH
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


# pnpm
export PNPM_HOME="~/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# yazi https://yazi-rs.github.io/docs/quick-start/
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/jesusguzman/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
eval "$(gh copilot alias -- zsh)"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
