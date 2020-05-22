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

# parsing through host_info data and declaring output to respective column vars
lscpu_out=`lscpu`
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Arch*" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^Model \name:" | awk '{print $3,$4,$5,$6,$7}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "^CPU \MHz:" | awk '{print $3}')
l2_cache=$(echo "$lscpu_out"  | egrep "^L2 \cache" | awk '{print substr($3,1,length($3)-1)}')
total_mem=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
vmstat=$(vmstat -t)
timestamp=$(echo "$vmstat" | awk 'NR==3 {print $(NF-1),$(NF)}')

#create a psql insert statement to create a row in the table
insert_stmt=$(cat <<-END
INSERT INTO host_info (id, hostname, cpu_number,cpu_architecture,cpu_model,cpu_mhz,l2_cache,total_mem,"timestamp")
VALUES (DEFAULT,'$hostname',$cpu_number,'$cpu_architecture','$cpu_model',$cpu_mhz,$l2_cache,$total_mem,'$timestamp')
END
)

# psql CLI command
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"

exit $?
