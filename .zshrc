##################################################
##################################################
#
# BASIC SETTINGS
#
##################################################
##################################################
# Disable CTRL-S lock
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

# Autostart tmux
tmux_count=$(ps aux | grep tmux | grep -v grep | wc -l)
tmux_initial_window_name="initial-window"
if test $tmux_count -eq 0; then
	tmux new -s init-session -n $tmux_initial_window_name
# else
#	# # If you attach existing tmux session here, dangerous infinite loop occures.
#	# # DO NOT tmux attach automatically.
#	# tmux attach
# 	tmux ls
fi
if [ -n "$TMUX" ]; then
	tmux_current_window_name=$(tmux display-message -p '#{window_name}')
	echo "HELLO WORLD! The name of this window is ${tmux_current_window_name}" 
else 
	echo "Here is outside of tmux session."
	echo ""
	tmux ls
	echo ""
	echo "Please attach tmux session using one of the following commands: "
	echo "  ・tmux new -s <new-session-name>"
	echo "  ・tmux a [ -t <session-name> ]"
fi

# fzf
export FZF_DEFAULT_COMMAND='rg --hidden -l "" -g "!.git/"'

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

# Prevent `no matches found` error on curl 
setopt nonomatch

SECRET_SETTING_FILE=~/settings-mac-secret/secret.zsh
if [[ -f $SECRET_SETTING_FILE ]] then
		source $SECRET_SETTING_FILE
fi

##################################################
##################################################
#
# CHEAT SHEET
#
##################################################
##################################################
# # kill current tmux session
# tmux kill-session

##################################################
##################################################
#
# aliases & functions
#
##################################################
##################################################

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

function mkdircd() {
		mkdir $@
		cd $@
}

function fmt-jsonnet-all() {
	git diff --name-only HEAD *sonnet  | xargs jsonnetfmt -i
}

alias sz='source ~/.zshrc'
alias st='tmux source-file ~/.tmux.conf'

function stg {
	cd ~/settings-mac
	tmux rename-window settings-mac
	nvim .config/nvim/init.lua -c "NvimTreeOpen"
}

function stg-secret {
	cd ~/settings-mac-secret
	tmux rename-window settings-mac-secret
	nvim secret.zsh -c "NvimTreeOpen"
}

zshrc_var_learn_params=('rust' 'java' 'go')
function learn {
	local language=$1
	if (( $zshrc_var_learn_params[(I)${language}] )); then
		cd ${HOME}/devspace/learn/${language}/learn-project/
		clear
		tmux rename-window code-${language}
		tmux new-window -d -n exec-${language}
		nvim README.md -c 'NvimTreeOpen'
	else
		echo "Invalid language: ${language}"
		return 1
	fi
}
function _learn {
	if [[ $CURRENT == 2 ]] then
		_describe -t language "Language" zshrc_var_learn_params
	fi
	return 1
}
compdef _learn learn

zshrc_var_drill_project_root=${HOME}/devspace/misc-drills
function drill {
	local subdir=$1
	if [ -z "${subdir}" ]; then
		cd ${project_root}
		tmux rename-window misc-drills
		nvim README.md -c 'NvimTreeOpen'
	elif [ -d ${zshrc_var_drill_project_root}/${subdir} ]; then
		cd ${project_root}
		tmux rename-window misc-drills
		nvim $dir/README.md -c 'NvimTreeOpen'
	else
		echo "${subdir} is not found in misc-drills"
	fi
}
function _drill {
	if [[ $CURRENT == 2 ]] then
		local -a subdirs=( $(find ${zshrc_var_drill_project_root}/* -type d -maxdepth 0 -exec basename '{}' ';') )
		_describe -t subdirectories "Subdirs" subdirs
	fi
	return 1
}
compdef _drill drill
