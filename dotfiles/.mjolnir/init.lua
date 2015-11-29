local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local fnutils = require "mjolnir.fnutils"

local winter = require "mjolnir.winter"
local win = winter.new()

local ctrlaltcmd  = {"ctrl", "alt", "cmd"}
local saltcmd  = {"shift", "alt", "cmd"}

local focused_window = window:focusedwindow();
local half_width = focused_window:screen():frame().w / 2;

-- make the focused window a 200px, full-height window and put it at the left screen edge
hotkey.bind(ctrlaltcmd, 'left', win:focused():wide(half_width):tallest():leftmost():place())

-- make a full-height window and put it at the right screen edge
hotkey.bind(ctrlaltcmd, 'right', win:focused():wide(half_width):tallest():rightmost():place())

-- full-height window, full-width window, and a combination
hotkey.bind(ctrlaltcmd, 'up', win:focused():widest():tallest():resize())

-- push to different screen
hotkey.bind(saltcmd, '[', win:focused():prevscreen():move())
hotkey.bind(saltcmd, ']', win:focused():nextscreen():move())