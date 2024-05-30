#!/bin/bash

if [ -z "$1" ]; then
	echo "Geen bestanden geselecteerd"
	exit 1
fi

TIME_PROP_OPTS=(
	DateTimeOriginal
	FileModifyDate
	ModifyDate
)

CAMERA_OPTS_FILE="$HOME/.config/rename-images-cameras"

CAMERA_OPTS=()

if [ -f "$CAMERA_OPTS_FILE" ]; then
	readarray -t CAMERA_OPTS < "$CAMERA_OPTS_FILE"
fi

echo "Kies model (of voer handmatig in):"

select camera_model in "Geen" "${CAMERA_OPTS[@]}"; do
	if [ "$camera_model" = "Geen" ]; then
		camera_model=""
		break
	fi

	if [ -z "$camera_model" ]; then
		camera_model="$REPLY"
		echo "$camera_model" >> "$CAMERA_OPTS_FILE"
		break
	fi

	break
done

select time_prop in "${TIME_PROP_OPTS[@]}"; do
	if [ -n "$time_prop" ]; then
		break;
	fi

	echo "Ongeldige keuze"
done

if [ -n "$camera_model" ]; then
	time_str="%Y.%m.%d - %H.%M.%S - $camera_model"
else
	time_str="%Y.%m.%d - %H.%M.%S"
fi

exiftool -d "$time_str" "-testname<\${${time_prop}}.%le" "$@"

read -p "Druk op enter om door te gaan"

exiftool -d "$time_str" "-filename<\${${time_prop}}.%le" "$@"
