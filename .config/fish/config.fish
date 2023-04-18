if status is-interactive
    # Commands to run in interactive sessions can go here
end

#
# Autostart tmux
# tmux_count=$(ps aux | grep tmux | grep -v grep | wc -l)
set tmux_count $(ps aux | grep tmux | grep -v grep | wc -l)
# tmux_window_name_settings="settings"
set tmux_window_name_settings "settings"
if test $tmux_count -eq 0
	tmux new -s init-session -n $tmux_window_name_settings
# else
#	# # If you attach existing tmux session here, dangerous infinite loop occures.
#	# # DO NOT tmux attach automatically.
#	# tmux attach
# 	tmux ls
end
if [ -n "$TMUX" ]
	# tmux_current_window_name=$(tmux display-message -p '#{window_name}')
	set tmux_current_window_name $(tmux display-message -p '#{window_name}')
	echo "HELLO WORLD! The name of this window is $tmux_current_window_name" 
	if [ $tmux_current_window_name = $tmux_window_name_settings ]
		echo "Settings!!!"
		if [ $(tmux display-message -p '#{pane_id}') = "%0" ]
			echo "Init pane"
		end
	end
else 
	echo "Here is OUTSIDE of tmux session."
	tmux ls
	echo "Please run 'tmux attach' command."
end

# 
# Custom man command
function man 
	if [ -z "$TMUX" ]
		command man $argv
		# echo "OUTSIDE"
	else 
		tmux split-window -h "command man $argv"
		tmux select-layout even-horizontal
		# command man $argv
		# echo "$argv is ${@}"
		# echo "INSIDE"
	end
end

#
# Custom commands
alias ides='cd ~/settings-mac; nvim .config/nvim/init.lua'
alias md='cd ~/Notes; nvim index.md'

