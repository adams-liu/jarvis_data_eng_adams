# Linux Cluster Monitoring Agent

#Table of Contents

# Description
The Linux Cluster Monitor is a tool that allows IT admins to 
retrieve hardware information about all servers that are internally connected 
within its network via ethernet switch. The data will be stored in on a PostgreSQL
database and can be used later to generate reports for future resource planning.
This tool is an MVP and gives a high-level representation of how 
a real enterprise monitoring agent would work. 

#Architecture and Design

The architecture diagram above shows how the tool retrieves system hardware 
information. Each linux server will have a bash script what will be executed 
and sent to database. The server local to the database will send the information directly
whereas the other servers will be sent via the network switch to the database.

##Database and Tables
The PostgreSQL database, host_data, consists of 2 tables, host_info and 
host_usage. 

The host_info table consists of information pertaining to 
the hardware specification of the server. The data are as follows:

- id: Unique identifier that corresponds to each server. (Primary Key)
- hostname: Unique server system name (eg. jrvs-remote-desktop-centos7-6)
- cpu_number: Number of CPUs the respective server is running on
- cpu_architecture: The CPU architecture type (eg. x86_64)
- cpu_model: The CPU model type (Intel(R) Xeon CPU @ 2.30GHz)
- L2_cache: Size of level 2 CPU cache (in kB)
- total_mem: Total memory of server (in kB)
- timestamp: Time when server was first setup in UTC timezone (Eg. 2019-05-29 17:49:53)

The host_usage table contains information about each server's resource 
usage. This information is captured in host_data database every minute. The
data is as follows:

- timestamp: Time when the resource information was captured in UTC timezone.
- host_id: Unique identifier that corresponds to each server (Foreign Key to host_info id attribute)
- memory_free: Total amount of space available
- cpu_idle: Percentage of time cpu was idle
- cpu_kernel: Percentage of time running kernel code
- disk_io: Number of disk input/output process in progress
- disk_available: Size of available disk space (in MB)

## Scripts Descriptions

- psql_docker.sh: To create, start, and stop a psql database in a docker container.
- host_info.sh: Ran once for every server that is connected in the network. 
This is to initialize the host information in the host_info table so that data collected in the host_usage table can reference off it. 
- host_usage.sh: Collects resource usage data of the server and inserts the results into the host_usage table. 
The data is inserted every minute using crontab.
- ddl.sql: Creates the host_info and host_usage tables in the host_data database. 
It also populates each table with one default data. 
- queries.sql: Runs two queries to for reporting purposes.
    1) Group hosts by CPU number and sort by their memory size.
    2) Obtain average memory usage over 5 minute interval for each host.

# Usage
1. Initialize database and tables
2. host_info.sh
3. host_usage.sh
4. setting up crontab
- crontab- e
- '* * * * * bash [path]/host_usage'
- crontab -ls
- cat /tmp/host_usage.log

# Improvements
1. Currently, the host_usage script does not have a way to identify what it's 
host_id number is without providing a value. Creating a script to fetch the id based on the the hostname would be useful.

2. For the host_usage table there isn't a hard cap on how many rows there could be, this may lead to errors further on. 
To increase the usefulness, an automatic script should be set to delete records greater than a given time frame. (eg. 2 weeks, 1 month)

3. More queries can be provided so that the user can extract different types of information.
(eg. number of disk ios a server uses every hour)


 


