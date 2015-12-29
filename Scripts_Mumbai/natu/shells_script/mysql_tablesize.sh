#!/bin/bash
mysql -p  -e 'SELECT table_name AS "Tables",  round(((data_length + index_length) / 1024 / 1024), 0) "Size in MB"  FROM information_schema.TABLES  WHERE table_schema = "efeap" ORDER BY (data_length + index_length) DESC;' | grep -v "Size in MB" |awk 'BEGIN { FS=" " }{ if ($2 >= 1024) print $1,$2 } END { }'


mysql -e 'SELECT table_name AS "Tables",  round(((data_length + index_length) / 1024 / 1024), 0) "Size in MB"  FROM information_schema.TABLES  WHERE table_schema = "efeap" ORDER BY (data_length + index_length) DESC;' | grep -v "Size in MB" |awk 'BEGIN { FS=" "; printf "Table_Name                Size_in_MB \n" }{ if ($2 >= 1024) print $1,$2 } END { }' | column -t



mysql -e 'SELECT table_name AS "Tables",  round(((data_length + index_length) /1024 / 1024 / 1024), 0) "Size in MB"  FROM information_schema.TABLES  WHERE table_schema = "efeap" ORDER BY (data_length + index_length) DESC;' | grep -v "Size in MB" |awk 'BEGIN { FS=" "; printf "Table_Name                Size_in_MB \n" }{ if ($2 >= 1) print $1,$2 } END { }' | column -t
