#!/bin/bash

icon_glyph() {
	lua -e "
package.path = '$CONFIG_DIR/?.lua;$CONFIG_DIR/?/init.lua;;'
local icons = require('helpers.app_icons')
print(icons['$1'] or icons['Default'])
" 2>/dev/null
}

output="$("$CONFIG_DIR/helpers/aerospace_query.sh" "$FOCUSED_WORKSPACE")"

ws=""
focused_app=""
focused_ws=""
apps=()

while IFS= read -r line; do
	case "$line" in
	WS:*)
		ws="${line#WS:}"
		;;
	FOCUSED:*)
		IFS='|' read -r focused_app focused_ws <<< "${line#FOCUSED:}"
		;;
	"")
		;;
	*)
		apps+=("$line")
		;;
	esac
done <<< "$output"

if [ -z "$ws" ]; then
	exit 0
fi

active_icon=""
rest_icons=""
seen=""

for app in "${apps[@]}"; do
	case " $seen " in
	*" $app "*) continue ;;
	esac
	seen="$seen $app"
	glyph="$(icon_glyph "$app")"
	if [ "$app" = "$focused_app" ] && [ "$focused_ws" = "$ws" ]; then
		active_icon="$glyph"
	else
		rest_icons="${rest_icons}${glyph}"
	fi
done

[ -z "$active_icon" ] && [ -z "$rest_icons" ] && rest_icons=" —"

sketchybar --set aerospace.ws icon="$ws"

if [ -n "$active_icon" ]; then
	sketchybar --set aerospace.apps icon="$active_icon" icon.drawing=on label="$rest_icons"
else
	sketchybar --set aerospace.apps icon="" icon.drawing=off label="$rest_icons"
fi
