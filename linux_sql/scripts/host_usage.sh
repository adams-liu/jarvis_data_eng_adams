#!/bin/bash

# declaring user-input variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# error check to see if user inputted 5 arguments
if [ "$#" != 5 ];then
  echo "invalid number of arguments"
  exit 1
fi

# parsing through host_usage data and declaring output to respective column vars
vmstat=$(vmstat -t)
timestamp=$(echo "$vmstat" | awk 'NR==3 {print $(NF-1),$(NF)}')
vmstat=$(vmstat --unit M)
memory_free=$(echo "$vmstat" | awk 'NR==3 {print $4}')
vmstat=$(vmstat)
cpu_idle=$(echo "$vmstat" | awk 'NR==3 {print $15}')
cpu_kernel=$(echo "$vmstat" | awk 'NR==3 {print $14}')
disk_io=$(echo "$vmstat" | awk 'NR==3 {print $(NF-1)}')
df=$(df -BM /)
disk_available=$(echo "$df" | awk 'NR==2 {print substr($(NF-2),1,length($(NF-2))-1)}')

#create a psql insert statement to create a row in the table
insert_stmt=$(cat <<-END
INSERT INTO host_usage ("timestamp", host_id, memory_free, cpu_idle,cpu_kernel,disk_io,disk_available)
VALUES ('$timestamp',2,$memory_free,$cpu_idle,$cpu_kernel,$disk_io,$disk_available)
END
)

# psql CLI command
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"

exit $?
