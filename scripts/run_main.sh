#! /usr/bin/bash

set -xe

odin run vizmain -debug -keep-executable -define:RAYLIB_SHARED=true \
    -extra-linker-flags:"-Wl,-rpath,/home/mabayneh/opt/odin-v2026-08/vendor/raylib/linux" \
    -out:./tmp/vizmain
    -- $1
