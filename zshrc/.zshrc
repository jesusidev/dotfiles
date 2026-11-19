typeset -U path PATH   # drop duplicate PATH entries

# Homebrew (Apple Silicon) — must come first so everything below is on PATH
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"

# Volta must stay ahead of Homebrew so its node/npm shims win and repo pins apply.
# (.zshenv sets this too, but brew shellenv above moves /opt/homebrew/bin first.)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Zap plugin manager https://www.zapzsh.org/
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/exa"

export EDITOR=nvim
export VISUAL="$EDITOR"

## utils aliases
alias home='~/'
alias update='source ~/.zshrc';
alias update-nvim='source ~/.config/nvim';
alias update-tmux='tmux source ~/.config/tmux/tmux.conf';
alias l='eza --icons --group-directories-first -a'
alias ll='eza -l --icons --no-user --group-directories-first  --time-style long-iso'
alias la='eza -la --icons --no-user --group-directories-first  --time-style long-iso'
alias tree='eza --tree -a --level=5'
alias lg='lazygit';
alias cls='clear';
alias repos='~/repos';
alias rootdir='~/';
alias delDir='rm -rf';
alias history="history 1 | cut -c 8- | sed -e 's/^ [0-9]\{1,5\}  /    /gi' | fzf | pbcopy";

## PSQL — usage: psql-local <user> <password> <db>
function psql-local() { psql "postgres://$1:$2@localhost:5432/$3"; }

## git
function gh-create() { gh repo create "$1" --source=. --remote=upstream; }

# add, commit and push in one go — usage: gpush "message" (defaults to "update")
function gpush() {
    git add .
    git commit -m "${1:-update}"
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
alias gd="git diff";
alias ga="git add .";
alias gdel-local="git branch -D";
alias gdel-remote="git push origin --delete";
alias glog='git log --oneline';
alias gfindbycommit='git log --all --grep';
alias gfindbydeveloper='git log --author';
function gdiff() { git diff --color --no-index "$1" "$2"; };
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

## Kube aliases (only useful once kubectl is installed)
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
if command -v kubectl >/dev/null; then
  source <(kubectl completion zsh)
  if command -v kubecolor >/dev/null; then
    alias kubectl=kubecolor
    compdef kubecolor=kubectl
  fi
fi

## Docker aliases (only useful once docker is installed)
alias d="docker";
alias dls='d ps --filter "status=running" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"';
alias dstart="docker ps -a --filter 'status=exited' --format '{{.Names}}' | fzf --multi | xargs -r -I {} sh -c 'docker start {}; echo Started container: {}'"
alias dls-stopped='d ps --filter "status=exited" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"';
alias dstop-all='d stop $(docker ps -q)';
alias dstop="docker ps --format '{{.Names}}' | fzf --multi | xargs -r -I {} sh -c 'docker stop {}; echo Stopped container: {}'"
alias drmvol="docker ps -a --format '{{.Names}}' | fzf --multi | xargs -r -I {} sh -c 'docker rm -v {}; echo Removed container: {}'"

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

## Starship prompt https://starship.rs/
command -v starship >/dev/null && eval "$(starship init zsh)"

# tmux session picker (t-smart-tmux-session-manager, installed by TPM)
export PATH="$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin:$PATH"

# Rancher Desktop CLIs (docker, kubectl, nerdctl). Rancher's own "Automatic" PATH
# setting would write into this file, so set it to Manual in Rancher > Preferences.
[ -d "$HOME/.rd/bin" ] && export PATH="$HOME/.rd/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# yazi file manager (only if installed) https://yazi-rs.github.io/
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Extra function files from this repo (zshrc/.config/zsh/*.zsh), e.g. aws.zsh
for f in "$HOME"/.config/zsh/*.zsh(N); do source "$f"; done; unset f

# Machine-specific or secret settings (not in git): ~/.zshrc.local
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
