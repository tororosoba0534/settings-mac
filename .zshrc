# Disable CTRL-S lock
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

#
# Autostart tmux
tmux_count=$(ps aux | grep tmux | grep -v grep | wc -l)
tmux_window_name_settings="settings"
if test $tmux_count -eq 0; then
	tmux new -s init-session -n $tmux_window_name_settings
# else
#	# # If you attach existing tmux session here, dangerous infinite loop occures.
#	# # DO NOT tmux attach automatically.
#	# tmux attach
# 	tmux ls
fi
if [ -n "$TMUX" ]; then
	tmux_current_window_name=$(tmux display-message -p '#{window_name}')
	echo "HELLO WORLD! The name of this window is ${tmux_current_window_name}" 
	if [ $tmux_current_window_name = $tmux_window_name_settings ]; then
		echo "Settings!!!"
		if [ $(tmux display-message -p '#{pane_id}') = "%0" ]; then
			echo "Init pane"
		fi
	fi
else 
	echo "Here is OUTSIDE of tmux session."
	tmux ls
	echo "Please run 'tmux attach' command."
fi

#
# fzf setting
export FZF_DEFAULT_COMMAND='rg --hidden -l "" -g "!.git/"'

# 
# Custom man command
function man() {
	if [ -z "$TMUX" ]; then
		command man $@
		# echo "OUTSIDE"
	else 
		tmux split-window -h "command man $@"
		tmux select-layout even-horizontal
		# command man $@
		# echo "$@ is ${@}"
		# echo "INSIDE"
	fi
}

#
# Custom commands
alias ides='cd ~/settings-mac; nvim .config/nvim/init.lua'
alias sz='source ~/.zshrc'
alias k='kubectl'
alias kg='kubectl get'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph'

export PS1="%D %* %~ %# "

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
eval export PATH="${HOME}/.jenv/shims:${PATH}"
export JENV_SHELL=zsh
export JENV_LOADED=1
unset JAVA_HOME
unset JDK_HOME
source '/opt/homebrew/Cellar/jenv/0.5.6/libexec/libexec/../completions/jenv.zsh'
jenv rehash 2>/dev/null
jenv refresh-plugins
jenv() {
  type typeset &> /dev/null && typeset command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  enable-plugin|rehash|shell|shell-options)
    eval `jenv "sh-$command" "$@"`;;
  *)
    command jenv "$command" "$@";;
  esac
}

source "$HOME/.cargo/env"

# completion
fpath=(~/settings-mac/.zsh/completion $fpath)
autoload -Uz compinit
compinit -u
source <(kubectl completion zsh)

SECRET_SETTING_FILE=~/settings-mac-secret/secret.zsh
if [[ -f $SECRET_SETTING_FILE ]] then
		source $SECRET_SETTING_FILE
fi

# Prevent `no matches found` error on curl 
setopt nonomatch
