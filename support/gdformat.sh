#!/bin/bash

args=$@

if [ -z "$args" ]; then
  find . -iname *.gd -not -ipath './repo/addons/*' | xargs ./venv/bin/gdformat --check
elif [ "$args" = "--apply" ]; then
  find . -iname *.gd -not -ipath './repo/addons/*' | xargs ./venv/bin/gdformat
else
  ./venv/bin/gdformat $args
fi