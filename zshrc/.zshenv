# Loaded by every zsh, including non-interactive ones (scripts, editors, tools).
# Volta first so node/npm/npx resolve through its shims and repo pins apply.
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
