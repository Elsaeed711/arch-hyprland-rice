
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/bin:$PATH"
#java setup
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH

eval "$(starship init zsh)"

# ZSH_THEME="refined"
# ZSH_THEME="robbyrussell"

plugins=( 
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Check archlinux plugin commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/archlinux


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos



### From this line is for pywal-colors
# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
# Not supported in the "fish" shell.
#(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
#cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
#source ~/.cache/wal/colors-tty.sh


# My alias 

#alias cty='tty-clock -S -c -C 6 -t -n -D'
alias fucking='sudo'
alias n='nvim'
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux ls'
alias cd..='cd ..'
alias gc='git clone '
alias ga='git add .'
alias gcm='git commit -m '
alias gp='git push -u origin main'
alias gs='git status'
alias ll='ls -Alh'
alias ls='lsd --group-dirs first'
alias cat='bat'
alias py='python3'
alias inv='code $(fzf -m --preview="bat --color=always {}")'
alias sr='fzf -m --preview="bat --color=always {}"'
alias memc='ps -C code -o rss=,%mem= | awk "{rss+=\$1; mem+=\$2} END {printf \"Memory: %.2f MB, %.2f%%\n\", rss/1024, mem}"'
alias memf='ps -C firefox -o rss=,%mem= | awk "{rss+=\$1; mem+=\$2} END {printf \"Memory: %.2f MB, %.2f%%\n\", rss/1024, mem}"'
alias memb='ps -C brave -o rss=,%mem= | awk "{rss+=\$1; mem+=\$2} END {printf \"Memory: %.2f MB, %.2f%%\n\", rss/1024, mem}"'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'


# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
alias brave='/opt/brave-bin/brave --password-store=basic'
alias brave='/opt/brave-bin/brave --password-store=basic'

# Show fastfetch when a terminal window opens
[[ $- == *i* ]] && command -v fastfetch &>/dev/null && fastfetch
