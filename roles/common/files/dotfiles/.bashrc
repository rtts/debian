# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return ;;
esac

# Enable Bash completion
. /usr/share/bash-completion/bash_completion

# Infinite, global shell history, inspired by
# https://unix.stackexchange.com/q/1288
shopt -s histappend
HISTSIZE=-1
HISTFILESIZE=-1
HISTCONTROL=ignorespace:erasedups
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Some handy aliases
alias cd..='cd ..'
alias ls='ls -F --group-directories-first --color=auto'
alias ll='ls -lh'
alias la='l -a'
alias l='ll'
alias e=jmacs
alias get='sudo apt install'
alias s='apt search'
ssh () { command ssh "$@" && /etc/update-motd.d/20-stats; }

# Show current Git branch, if available
git_prompt() {
  if git rev-parse --is-inside-work-tree &> /dev/null
  then
    echo -n '['$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    git diff --quiet && echo '] ' || echo '*] '
  fi
}
PS1="\$(git_prompt)\u@\h:\w\$ "

# Source more stuff, if available.
[[ -f ~/.aliases ]] && . ~/.aliases
[[ -f ~/.Xaliases ]] &&. ~/.Xaliases
