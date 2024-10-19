# Memory usage
free | awk '/^Mem/ { printf "%3d", $3/$2 * 100 }'
