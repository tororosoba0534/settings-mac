hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "W", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()

	f.x = f.x - 10
	win:setFrame(f)
end)
