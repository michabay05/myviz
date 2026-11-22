#! /usr/bin/bash

set -xe

odin build $1 -debug -build-mode:dll -define:RAYLIB_SHARED=true -out:./tmp/$1.so
