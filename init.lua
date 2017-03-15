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

-- config reload
root:bind("ctrl", "t", function () root:exit() end)
root:bind("", "r", function ()
	     hs.notify.new({title="Hammerspoon", informativeText="Reloading config..."}):send()
	     hs.reload()
end)

-- console
root:bind("shift", "c", function () hs.toggleConsole(); root:exit() end)

-- window management
root:bind("", "`", function () hswin.focusedWindow():maximize(0); root:exit() end)

-- run-or-raise applications
root:bind("", "e", function () run_or_raise_next("Emacs"); root:exit() end)
root:bind("", "c", function () run_or_raise_next("iTerm"); root:exit() end)
root:bind("", "f", function () run_or_raise_next("Firefox", "open -a Firefox --args --app ~/Apps/conkeror/application.ini"); root:exit() end)

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
      table.sort(windows, function (w1,w2) return w1:id() < w2:id() end)
      local currw = hs.window.focusedWindow()
      local curri = hs.fnutils.indexOf(windows, currw) or #windows
      local nexti = (curri % #windows) + 1
      hs.alert(string.format('%s (%d of %d)', appname, nexti, #windows))
      windows[nexti]:focus()
   end
end

print "hs init.lua: done"
