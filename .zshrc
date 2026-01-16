typeset -U path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
)

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit
  compinit
fi

export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH="/opt/homebrew/opt/python@3.13/libexec/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Go
export GOPATH=$(go env GOPATH)
export PATH="$GOPATH/bin:$PATH"

eval "$(rbenv init -)"

export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"

export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"

# pnpm
export PNPM_HOME="/Users/cafe/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# alias
alias ls='ls -a'

# Added by Antigravity
export PATH="/Users/cafe/.antigravity/antigravity/bin:$PATH"

# starship
eval "$(starship init zsh)"

# cargo
export PATH="$HOME/.cargo/bin:$PATH"
