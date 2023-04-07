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
