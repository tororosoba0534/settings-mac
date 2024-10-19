# Battery percentage
pmset -g ps | awk 'match($3, /[0-9]*%/) {print substr($3, RSTART, RLENGTH - 1)}'
