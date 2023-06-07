set appName to "Alacritty"
set visibilityFlag to false
set isFrontmost to false
tell application "System Events"
if process appName is frontmost then
set isFrontmost to true
end if
	if visible of process appName and isFrontmost then
		set visible of process appName to false
		set visibilityFlag to false
	else
		set visible of process appName to true
		set visibilityFlag to true
	end if
	tell application appName to activate
end tell
if visibilityFlag or not isFrontmost then
	tell application appName to activate
end if
