#! /usr/bin/bash

ls $1/* | entr -s "./build_plug.sh $1"