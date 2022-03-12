#!/bin/sh

mkdir -p $XDG_DATA_HOME/fonts
cp -r assets/fonts/ $XDG_DATA_HOME/fonts/vips-nix-testing
fc-cache -f -v
