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

OLDPWD=$PWD
cd "${FILESDIR}"
for file in *.pdf
do
	if test ! -f "$(echo $file | sed 's/pdf/png/')";
	then
		pdftoppm $file -singlefile -png > "$(echo "$file" | sed 's/pdf/png/')"
	fi
done
cd $OLDPWD
