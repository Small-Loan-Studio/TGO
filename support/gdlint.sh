#!/usr/bin/env bash

args="$@"

find /repo -iname *.gd -not -ipath '/repo/addons/*' | grep -v wwise_ids.gd | xargs /usr/local/bin/gdlint $args
