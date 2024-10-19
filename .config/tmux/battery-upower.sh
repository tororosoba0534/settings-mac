# Battery percentage
upower -i $(upower -e | grep 'BAT') | grep -E "percentage" | awk 'match($2, /[0-9]*%/) {print substr($2, RSTART, RLENGTH - 1)}'
