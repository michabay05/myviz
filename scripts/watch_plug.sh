#! /usr/bin/bash

ls $1/* utils/* | entr -s "scripts/build_plug.sh $1"
