#!/bin/sh
uname | grep Darwin >/dev/null && open "$@" || xdg-open "$@"
