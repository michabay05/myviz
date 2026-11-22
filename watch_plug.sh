#! /usr/bin/bash

ls $1/* utils/* | entr -s "./build_plug.sh $1"
