set appName to "Google Chrome"
set isFrontmost to false
tell application "System Events"
	if process appName is frontmost then
		set isFrontmost to true
	else
		set isFrontmost to false
	end if
end tell
if isFrontmost then
	tell application appName
		set index of last window to 1
		activate front window
	end tell
else
	tell application appName to activate
end if
