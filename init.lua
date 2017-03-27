--
-- init.lua: Hammerspoon config
-- created: March 2017
-- author: Leonardo Etcheverry <leo@kalio.net>
--

print "hs init.lua: starting"

local hsapp = hs.application
local hswin = hs.window
local hswf  = hs.window.filter

mbi = hs.menubar.new()
local mbi_text = hs.styledtext.new('🍄')
local modal = hs.hotkey.modal 	-- modal handler a la ratpoison/stumpwm
root = modal.new("ctrl", "t")
function root.entered()
   mbi:setTitle(mbi_text)
end
function root.exited()
   mbi:setTitle()
end

-- Binds a key so that the modal will auto exit once the key was activated
local bind_modal_with_autoexit = function (modal, mods, key, msg, pressfn, relfn, repfn)
   modal:bind(mods, key,
	      msg,
	      function () modal:exit(); if pressfn then pressfn() end end,
              function () modal:exit(); if relfn then relfn() end end,
	      function () modal:exit(); if repfn then repfn() end end)
end
setmetatable(hs.hotkey.modal, {__index = {bind_ae = bind_modal_with_autoexit} })

-- config reload
root:bind_ae("ctrl", "t", nil, function () root:exit() end)
root:bind_ae("", "r", nil, function ()
	     hs.notify.new({title="Hammerspoon", informativeText="Reloading config..."}):send()
	     hs.reload()
end)

-- console
root:bind_ae("shift", "c", nil, function () hs.toggleConsole(); root:exit() end)

-- window management
root:bind_ae("", "`", nil, function () hswin.focusedWindow():maximize(0) end)
root:bind_ae("", ".", nil, function () hswin.focusedWindow():moveToUnit('[50,0 50x100]',0) end)
root:bind_ae("", ",", nil, function () hswin.focusedWindow():moveToUnit('[0,0 50x100]', 0) end)
root:bind_ae("", "s", nil,
	     function ()
		local win=hswin.focusedWindow()
		if win then
		   win:setSize(win:size():scale({0.5, 1}))
		end
             end)
root:bind_ae("shift", "s", nil,
	     function ()
		local win=hswin.focusedWindow()
		if win then
		   win:setSize(win:size():scale({1, 0.5}))
		end
	     end)

-- run-or-raise applications
root:bind_ae("", "e", nil, function () run_or_raise_next("Emacs"); end)
root:bind_ae("", "c", nil, function () run_or_raise_next("iTerm2");  end)
root:bind_ae("", "f", nil, function () run_or_raise_next("Firefox", "open -a Firefox --args --app ~/Apps/conkeror/application.ini"); end)

function run_or_raise_next(appname, command)
   local apps = hsapp.find(appname)
   if not apps then
      -- failed to find any instances of this running app,
      -- launch a new one.
      if command then 
	 local err = hs.osascript.applescript(string.format('do shell script "%s"',command))
	 if err then
	    hs.alert('error: ' .. err)
	 end
      else
	 hsapp.launchOrFocus(appname)
      end
   else
      local wf = hs.window.filter.new {appname}
      local windows = wf:getWindows()
      if windows then
	 table.sort(windows, function (w1,w2) return w1:id() < w2:id() end)
	 local currw = hs.window.focusedWindow()
	 local curri = hs.fnutils.indexOf(windows, currw) or #windows
	 local nexti = (curri % #windows) + 1
	 hs.alert(string.format('%s - (%d of %d) \t %s', appname, nexti, #windows, windows[nexti]:title()))
	 windows[nexti]:focus()
      end
   end
end

print "hs init.lua: done"
