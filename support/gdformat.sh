#!/bin/bash

args=$@

if [ -z "$args" ]; then
  find . -iname *.gd | xargs ./venv/bin/gdformat --check
elif [ "$args" = "--apply" ]; then
  find . -iname *.gd | xargs ./venv/bin/gdformat
else
  ./venv/bin/gdformat $args
fi
