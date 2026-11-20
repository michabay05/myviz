#! /usr/bin/bash

set -xe

odin build $1 -debug -file -build-mode:dll -define:RAYLIB_SHARED=true
