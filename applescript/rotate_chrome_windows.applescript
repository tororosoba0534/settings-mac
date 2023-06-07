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
		set wCount to count every window
		set index of front window to wCount
		activate front window
	end tell
else
	tell application appName to activate
end if
