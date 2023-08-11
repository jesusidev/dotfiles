# Created by Zap installer
# https://www.zapzsh.org/
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/exa"

export EDITOR=lvim
export VISUAL="$EDITOR"

source ~/private.zsh


## utils aliases
alias home='~/'
alias update='source ~/.zshrc';
alias update-tmux='tmux source ~/.config/tmux/tmux.conf';
alias update-lvim='source ~/.config/lvim';
alias l='exa --icons --group-directories-first -a'
alias ll='exa -l --icons --no-user --group-directories-first  --time-style long-iso'
alias la='exa -la --icons --no-user --group-directories-first  --time-style long-iso'
alias tree='exa --tree -a --level=5'
alias lg='lazygit';
alias lnpm='lazynpm';
alias localserver='lite-server';
alias cls='clear';
alias repos='~/repos';
alias rootdir='~/';
alias delDir='rm -rf';

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

## LunarVIM
alias lvim="~/.local/bin/lvim"

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

## Tasks Shortcut
## https://github.com/kakengloh/tsk
alias tsk="tsk new";
alias thp="tsk new -s doing -p high -d 1h"
alias trm="tsk rm";
alias tls="tsk ls";
alias tboard="tsk board";
alias tdo="tsk todo";
alias twip="tsk doing";
alias tdone="tsk done";


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

# pnpm
export PNPM_HOME="~/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
