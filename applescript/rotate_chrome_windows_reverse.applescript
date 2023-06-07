set appName to "Google Chrome"
set isFrontmost to false
if application appName is running then
	tell application appName
		if (count of every window) > 0 then
			tell application "System Events"
				if process appName is frontmost then
					set isFrontmost to true
				else
					set isFrontmost to false
				end if
			end tell
			if isFrontmost then
				set index of last window to 1
				activate front window
			else
				activate
			end if
		else
			make new window
			activate
		end if
	end tell
	
else
	tell application appName to activate
end if
