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

####################
# Auto-generated functions
####################
function create_sub_subsub_pattern {
	local func_name=$1
	local root_dir=$2

	local func_definition
	read -r -d '' func_definition <<-HEREDOC
	function ${func_name} {
		local root_dir=${root_dir}
		local sub=\$1
		local subsub=\$2
		if [ -z "\${sub}" ]; then
			cd \${root_dir}
			tmux rename-window ${func_name}
			nvim README.md -c 'NvimTreeOpen'
			return 0
		fi
		local sub_path=\${root_dir}/\${sub}
		if [ -f "\${sub_path}" ]; then
			tmux rename-window ${func_name}
			cd \${root_dir}
			nvim \${sub} -c 'NvimTreeOpen'
			return 0
		fi
		if [ ! -d "\${sub_path}" ]; then
			echo "Command execution failed. \${sub_path} does not exist."
			return 1
		fi
		if [ -z "\${subsub}" ]; then
			tmux rename-window ${func_name}-\${sub}
			cd \${sub_path}
			nvim README.md -c 'NvimTreeOpen'
			return 0
		fi
		local subsub_path=\${sub_path}/\${subsub}
		if [ -f "\${subsub_path}" ]; then
			tmux rename-window ${func_name}-\${sub}
			cd \${sub_path}
			nvim \${subsub} -c 'NvimTreeOpen'
			return 0
		fi
		if [ ! -d "\${subsub_path}" ]; then
			echo "Command execution failed. \${subsub_path} does not exist."
			return 1
		fi
		tmux rename-window ${func_name}-\${sub}-\${subsub}
		cd \${subsub_path}
		nvim \${subsub} -c 'NvimTreeOpen'
	}
	function _${func_name} {
		local line state
		_arguments -C '1: :->cmds' '*::arg:->args'
		local root_dir=${root_dir}
		case "\$state" in
			cmds)
				local -a subs=(\$(ls \${root_dir}))
				_values "sub" \$subs
				;;
			args)
				_${func_name}_subsub \$line[1]
				;;
		esac
	}
	function _${func_name}_subsub {
		local sub=\$1
		local line state
		_arguments -C '1: :->cmds' '2::arg:->args'
		local root_dir=${root_dir}
		case "\$state" in
			cmds)
				local sub_dir=\${root_dir}/\${sub}
				local -a subsubs=(\$(ls \${sub_dir}))
				_values "subsub" \$subsubs
				;;
			args)
				;;
		esac
	}
	compdef _${func_name} ${func_name}
	HEREDOC

	eval "${func_definition}"
}

create_sub_subsub_pattern drill ${HOME}/devspace/drill
create_sub_subsub_pattern learn ${HOME}/devspace/learn
unfunction create_sub_subsub_pattern
