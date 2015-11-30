#!/bin/bash

# Needs Mjolnir and lua installed via Homebrew first (included in Brewfile)
echo 'rocks_servers = { "http://rocks.moonscript.org" }' >> /usr/local/etc/luarocks52/config-5.2.lua
luarocks install mjolnir.hotkey
luarocks install mjolnir.application
