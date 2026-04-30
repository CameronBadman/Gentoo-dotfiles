# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !
# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# Prompt
PS1='\[\033[01;36m\]\u\[\033[00m\]@\[\033[01;33m\]\h \[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;32m\]\$\[\033[00m\] '

# Vi-style command line editing
set -o vi
bind 'set show-mode-in-prompt on'
bind 'set keyseq-timeout 10'
bind 'set vi-ins-mode-string \1\e[32m\2 INS\1\e[0m\2 '
bind 'set vi-cmd-mode-string \1\e[33m\2 CMD\1\e[0m\2 '
bind -m vi-command 'v: edit-and-execute-command'
bind -m vi-command 'H: beginning-of-line'
bind -m vi-command 'L: end-of-line'
bind -m vi-command 'K: previous-history'
bind -m vi-command 'J: next-history'
bind -m vi-command '"gg": beginning-of-history'
bind -m vi-command 'G: end-of-history'
bind -m vi-command '"\C-l": clear-screen'
bind -m vi-insert '"\C-l": clear-screen'
bind '"\e[A": previous-history'
bind '"\e[B": next-history'

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Home Manager session variables
if [ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
  . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
fi

export PATH="/home/cameron/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
alias obsidian="obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland"

alias Hyprland='dbus-launch --exit-with-session Hyprland'
export DRI_PRIME=0
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

. "$HOME/.local/bin/env"
