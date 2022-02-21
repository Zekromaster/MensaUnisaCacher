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

OLDPWD=$PWD
cd "${FILESDIR}"
for file in *.pdf
do
	if test ! -f "$(echo $file | sed 's/pdf/txt/')";
	then
		TEXT="$(pdftotext "$file" -)"
		TEXT="$(echo "$TEXT" | tail -n +17 | sed -n "/I prodotti con \* sono surgelati/q;p" | grep "^[[:upper:]][[:lower:]]\|^\=" | perl -0pe 's/Pasta \(glutine\).*\nBoiled.*/----/' | perl -0pe 's/Mozzarella(.|\n)*Freddi/----/' | perl -0pe 's/Insalata (M|m)ista(.|\n)*Cestino/----/' | head -n -1 | grep -v "Take " | sed 's/\= //' | sed -E '$ s/ \([^)]*\)//g' | sed '$ s/ - /\n/')"
		echo "$TEXT" > "$(echo $file | sed 's/pdf/txt/')"
	fi
done
cd $OLDPWD
