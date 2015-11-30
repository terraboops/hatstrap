local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local fnutils = require "mjolnir.fnutils"

local ctrlaltcmd  = {"ctrl", "alt", "cmd"}
local saltcmd  = {"shift", "alt", "cmd"}

function getFullScreenWidthFor(window)
	return window:screen():frame().w;
end

function getFullScreenHeightFor(window)
	return window:screen():frame().h;
end

function getLeftOfScreenFor(window)
	return window:screen():frame().x
end

function getTopOfScreenFor(window)
	return window:screen():frame().y
end

-- make the focused window half-width, full-height window and put it at the left screen edge
hotkey.bind(ctrlaltcmd, 'left', function()
  local win = window.focusedwindow()
  local f = win:frame()
  f.w = getFullScreenWidthFor(win) / 2
  f.h = getFullScreenHeightFor(win)
  f.x = getLeftOfScreenFor(win)
  f.y = getTopOfScreenFor(win)
  win:setframe(f)
end)

-- make the focused window half-width, full-height window and put it at the right screen edge
hotkey.bind(ctrlaltcmd, 'right', function()
  local win = window.focusedwindow()
  local f = win:frame()
  f.w = getFullScreenWidthFor(win) / 2
  f.h = getFullScreenHeightFor(win)
  f.x = getLeftOfScreenFor(win) + (getFullScreenWidthFor(win) - (getFullScreenWidthFor(win)) / 2)
  f.y = getTopOfScreenFor(win)
  win:setframe(f)
end)

-- full-height window, full-width window, and a combination
hotkey.bind(ctrlaltcmd, 'up', function()
  local win = window.focusedwindow()
  local f = win:frame()
  f.w = getFullScreenWidthFor(win)
  f.h = getFullScreenHeightFor(win)
  f.x = getLeftOfScreenFor(win)
  f.y = getTopOfScreenFor(win)
  win:setframe(f)
end)

hotkey.bind(saltcmd, 'right', function()
  local win = window.focusedwindow()
  local f = win:frame()
  f.x = getFullScreenWidthFor(win)
  f.y = getTopOfScreenFor(win)
  win:setframe(f)
end)

hotkey.bind(saltcmd, 'left', function()
  local win = window.focusedwindow()
  local f = win:frame()
  f.x = 0
  f.y = 0
  win:setframe(f)
end)