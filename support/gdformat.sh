#!/bin/bash

args=$@

if [ -z "$args" ]; then
  args="--check"
fi
if [ "$args" = "--apply" ]; then
  args=""
fi

find . -iname *.gd -not -ipath './addons/*' | xargs ./venv/bin/gdformat $args