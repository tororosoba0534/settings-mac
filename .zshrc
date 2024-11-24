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

# For eliminationg delays on ESC
# default: 40 (400ms)
KEYTIMEOUT=1

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

export DENO_INSTALL="${HOME}/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Haskell (ghcup)
export PATH="${HOME}/.ghcup/bin:$PATH"
export PATH="$HOME/.cabal/bin:$PATH"

# Go
export PATH="$(go env GOPATH)/bin:$PATH"

# Scala
export PATH="$PATH:${HOME}/Library/Application Support/Coursier/bin"


# completion
fpath=(~/settings-mac/shell/completion $fpath)
autoload -Uz compinit
compinit -u
source <(kubectl completion zsh)

# Prevent `no matches found` error on curl 
setopt nonomatch

SECRET_SETTING_FILE=~/settings-mac-secret/secret.zsh
if [[ -f $SECRET_SETTING_FILE ]] then
		source $SECRET_SETTING_FILE
fi

# export DOCKER_DEFAULT_PLATFORM=linux/arm64

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

alias g='git'
alias gs='git status'

alias ls='ls -F'

function fmt-jsonnet-all() {
	git diff --name-only HEAD *sonnet  | xargs jsonnetfmt -i
}

alias sz='source ~/.zshrc'
alias st='tmux source-file ~/.tmux.conf'

function stg {
	cd ~/settings-mac
	tmux rename-window settings-mac
	ls -a
}

function stg-secret {
	cd ~/settings-mac-secret
	tmux rename-window settings-mac-secret
	ls -a
}

####################
# Auto-generated functions
####################
function create_nested_pattern {
	local func_name=$1
	local root_dir=$2

	local func_definition
	read -r -d '' func_definition <<-HEREDOC
	function ${func_name} {
		local current_dir=${root_dir}
		local window_name=${func_name}
		for param in "\$@"; do
			if [ -z "\${param}" ]; then
				cd \${current_dir}
				echo "Change directory to \${current_dir}"
				tmux rename-window \${window_name}
				return 0
			fi
			if [ -f "\${current_dir}/\${param}" ]; then
				cd \${current_dir}
				echo "Change directory to \${current_dir}"
				tmux rename-window \${window_name}
				nvim \${param}
				return 0
			fi
			current_dir=\${current_dir}/\${param}
			if [ ! -d "\${current_dir}" ]; then
				echo "Command execution failed. \${current_dir} does not exist."
				return 1
			fi
			window_name=\${window_name}-\${param}
		done
		cd \${current_dir}
		echo "Change directory to \${current_dir}"
		tmux rename-window \${window_name}
	}
	function _${func_name} {
		local context state state_descr line
		_arguments '-c[Change directory only]' '*::arg:->args'
		local root_dir=${root_dir}
		local current_dir=\${root_dir}
		for (( i=1; i<\${#line[@]}; i++ )); do
			current_dir=\${current_dir}/\${line[\$i]}
		done
		if [ -d "\${current_dir}" ]; then
			local -a comps=(\$(ls -A \${current_dir} 2>/dev/null))
			_values "comps" \$comps
		fi
	}
	compdef _${func_name} ${func_name}
	HEREDOC

	eval "${func_definition}"
}
create_nested_pattern dev ${HOME}/devspace/dev
unfunction create_nested_pattern

function note {
	local year=$(date "+%Y")
	local today=$(date "+%m%d")
	local root_dir="${HOME}/notes/${year}/${today}"

	mkdir -p $root_dir
	cd $root_dir
	tmux rename-window $today
	pwd
	ls -a
}

function keep {
	local root_dir="${HOME}/keep/"
	mkdir -p $root_dir
	cd $root_dir
	tmux rename-window keep
	ls -a
}

function cheat {
	local root_dir="${HOME}/cheat/"
	if [ ! -d $root_dir ]; then
		echo "Directory ${root_dir} does'nt exist."
		echo "Please clone it from GitHub."
		return 1
	fi
	cd $root_dir
	tmux rename-window cheat
	ls -a
}

function cheat-secret {
	local root_dir="${HOME}/cheat-secret/"
	mkdir -p $root_dir
	cd $root_dir
	tmux rename-window cheat-secret
	ls -a
}
