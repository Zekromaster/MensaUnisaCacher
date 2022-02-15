#/usr/bin/env sh
# Copyright (C) 2022 Luca Cristiano (Zekromaster) <dev@zekromaster.net>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see http://www.gnu.org/licenses/.

: <<'END_COMMENT'
This variable contains a RegExp to find a menu's day and meal.
Groups:
	1: The date
	2: If it's lunch (Pranzo) or dinner (Cena)
END_COMMENT
DATE_REGEXP='.* ([[:digit:]]{2} .* [[:digit:]]{4}) +(Pranzo|Cena).*'

: <<'END_COMMENT'
This function, given an ID, returns the URL of the corresponding file on the
ADiSURC servers.

Arguments:
	$1: The ID of the file
Returns:
	The URL
END_COMMENT
get_url_by_id() {
	printf "https://www.adisurcampania.it/moduli/output_immagine.php?id=%s" \
		"${1}"
}

: <<'END_COMMENT'
This function, given an ID returns the filename of the corresponding file on the
ADiSURC servers.

Arguments:
	$1: The ID of the file
Returns:
	The filename, as indicated in the Content-Disposition header of the request,
	UTF-8 Encoded.
END_COMMENT
get_filename_by_id() {
	curl -LsI "$(get_url_by_id "${1}")" |\
	iconv -f ISO-8859-1 -t UTF-8 |\
	grep Content-Disposition |\
	sed -En 's/Content-Disposition: attachment; filename=(.*)/\1/p' |\
	tr -d '"' |\
	tr -d "\r"
}

: <<'END_COMMENT'
This function, given an ID downloads the corresponding file to $FILESDIR.

Arguments:
	$1: The ID of the file
Returns:
	Nothing
END_COMMENT
download_file_by_id() {
	LOCAL_FILENAME="${FILESDIR}/${1}.pdf"
	curl -Ls "$(get_url_by_id "${1}")" --output "${LOCAL_FILENAME}"
}

: <<'END_COMMENT'
Returns:
	The menu that returns ad null result from the ADiSURC servers last execution.
	If no id is in the database, it returns the starting id as defined in the calling
	script.
END_COMMENT
get_latest_id() {
	cat "${INTERNAL}/latest_menu_id"
}

: <<'END_COMMENT'
Establishes if a specific filename is actually a date.

Arguments:
	$1: The filename
Returns:
	1 if the filename is a date, 0 if it isn't. (Boolean convention)
END_COMMENT
is_date() {
	(echo "${1}" | grep -Ei "${DATE_REGEXP}")>/dev/null && printf "1" || printf "0"
}

: <<'END_COMMENT'
Turns a specific filename into a valid date. Filename MUST be an italian date.

Arguments:
	$1: The filename
Returns:
	A date in YYYYMMDD format
END_COMMENT
convert_date() {
	echo "${1}" |\
	sed -En "s/${DATE_REGEXP}/\1/ip" |\
	sed 's/gennaio/01/i' |\
	sed 's/febbraio/02/i' |\
	sed 's/marzo/03/i' |\
	sed 's/aprile/04/i' |\
	sed 's/maggio/05/i' |\
	sed 's/giugno/06/i' |\
	sed 's/luglio/07/i' |\
	sed 's/agosto/08/i' |\
	sed 's/settembre/09/i' |\
	sed 's/ottobre/10/i' |\
	sed 's/novembre/11/i' |\
	sed 's/dicembre/12/i' |\
	awk -v OFS='' -F' ' '{ print $3,$2,$1 }'
}

: <<'END_COMMENT'
Gets the meal from the filename.

Arguments:
	$1: The filename
Returns:
	0 for Lunch, 1 for Dinner
END_COMMENT
get_meal() {
	echo "${1}" |\
	sed -En "s/${DATE_REGEXP}/\2/ip" |\
	sed 's/Pranzo/0/i' |\
	sed 's/Cena/1/i'
}

LATEST_ID=$(get_latest_id)
while true
do
	FILENAME=$(get_filename_by_id "${LATEST_ID}")
	echo "Downloading and checking file ${FILENAME}"
	if test "$FILENAME" = "nessuna_immagine.gif"
	then
		break
	fi
	if test "$(is_date "$FILENAME")" -eq 1
	then
		if ! grep "^${LATEST_ID};" "${DATABASE_MENUS}";
		then
			DATE="$(convert_date "$FILENAME")"		
			MEAL="$(get_meal "$FILENAME")"
			echo "Proceeding to download PDF for menu #${LATEST_ID}"
			download_file_by_id "$LATEST_ID"
			echo "${LATEST_ID};${DATE};${MEAL}" >> "${DATABASE_MENUS}"
		fi
	fi
	LATEST_ID=$((LATEST_ID+1))
done
echo "${LATEST_ID}" > "${INTERNAL}/latest_menu_id"
