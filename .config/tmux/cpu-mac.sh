# CPU usage
top -l 1 | grep -E "^CPU" | awk '{print int(100 - substr($7, 1, length($7) - 1))}'
