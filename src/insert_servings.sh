#!/usr/bin/env sh
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
Returns:
	The latest menu id that was to be inserted in the database.
	If no id is in the database, it returns the starting id as defined in the
	calling script.
END_COMMENT
get_latest_id() {
	cat "${INTERNAL}/latest_dish_id"
}

: <<'END_COMMENT'
Returns:
	A list of ids with a file downloaded that were not already processed.
END_COMMENT
get_ids_list() {
	tail -n +2 "${DATABASE_MENUS}" | awk -v STARTFROM="$(get_latest_id)" -F';' '$1>STARTFROM {printf "%d ", $1}'
}

LAST_MENU=$(get_latest_id)
for MENU in $(get_ids_list); 
do
	LAST_MENU="${MENU}"
	CURRENT_SERVING=0
	while read CURRENT_LINE
	do
		if test "$CURRENT_LINE" = "----"
		then
			CURRENT_SERVING=$((CURRENT_SERVING+1))
			continue
		fi
		echo "${MENU};${CURRENT_SERVING};${CURRENT_LINE}" >> ${DATABASE_DISHES}
	done < "${FILESDIR}/${MENU}.txt"
done
echo "${LAST_MENU}" > "${INTERNAL}/latest_dish_id"
