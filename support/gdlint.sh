#!/usr/bin/env bash

args="$@"

find /repo -iname *.gd -not -ipath '/repo/addons/*' | xargs /usr/local/bin/gdlint $args
