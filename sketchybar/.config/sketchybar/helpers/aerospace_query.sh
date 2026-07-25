#!/bin/bash

ws="$1"
if [ -z "$ws" ]; then
	ws=$(aerospace list-workspaces --focused)
fi

printf "WS:%s\n" "$ws"
aerospace list-windows --workspace "$ws" --format "%{app-name}" 2>/dev/null
printf "FOCUSED:%s\n" "$(aerospace list-windows --focused --format "%{app-name}|%{workspace}" 2>/dev/null)"
