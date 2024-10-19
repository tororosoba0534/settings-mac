# Memory usage
memory_pressure -Q | awk 'NR==2{print 100 - $NF}'
