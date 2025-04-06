#!/usr/bin/env bash

args=$@

if [ -z "$args" ]; then
  find /repo -iname *.gd -not -ipath '/repo/addons/* ' | grep -v wwise_ids.gd | xargs /usr/local/bin/gdformat --check
elif [ "$args" = "--apply" ]; then
  find /repo -iname *.gd -not -ipath '/repo/addons/*' | grep -v wwise_ids.gd | xargs /usr/local/bin/gdformat
else
  /usr/local/bin/gdformat $args
fi
