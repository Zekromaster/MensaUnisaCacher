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

mkdir -p "${DATADIR}"
mkdir -p "${FILESDIR}"
mkdir -p "${INTERNAL}"

if test ! -f "${DATABASE_MENUS}";
then
	echo "id;date;meal" > "${DATABASE_MENUS}"
fi

if test ! -f "${DATABASE_DISHES}";
then
	echo "id;serving;contents" > "${DATABASE_DISHES}"
fi

if test ! -f "${INTERNAL}/latest_menu_id";
then
	echo "${STARTING_ID}" > "${INTERNAL}/latest_menu_id"
fi

if test ! -f "${INTERNAL}/latest_dish_id";
then
	echo "${STARTING_ID}" > "${INTERNAL}/latest_dish_id"
fi
