#!/usr/bin/env bash

rows=$(tput lines);
cols=$(tput cols);

while true;
do
	x=$(( (RANDOM % $rows) + 1 ));
	y=$(( (RANDOM % $cols) + 1 ));
	color=$(( (RANDOM % 7) + 1 ));
	content="$(hostname)";

	tput setaf $color
	printf "\033[%d;%dH%s" $x $y  "$content";

	sleep 1.0;
done;
