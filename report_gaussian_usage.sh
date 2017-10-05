#!/usr/bin/env bash
#
# Author: Summer Wang (xwang@osc.edu) 
# Modified: 10/03/17
#
# This script queries the jobs database to calculate the CPU hours for commercial jobs using Gaussian. 
#
# For more information on this cronjob see the sys doc page at https://wiki.osc.edu/index.php?title=Report_basf_gaussian_usage.sh
#

echo "Enter the start date from which the report of Gaussian usage of commercial clients is generate (yyyy-mm-dd). For example, July 01, 2017 is 2017-7-1."
read  s_date
echo "Enter the end date by which the report of Gaussian usage of commercial clients is generate (yyyy-mm-dd). For example, July 01, 2017 is 2017-7-1."
read e_date

mysql [database] --execute=" 
SELECT '$s_date' AS startDate, '$e_date' AS endDate;
SELECT account, username, system, COUNT(jobid) AS jobs, 
SUM(nproc*TIME_TO_SEC(walltime))/3600. AS cpuhours FROM Jobs WHERE ( 
start_date>='$s_date' AND start_date<='$e_date') AND ( 
sw_app='gaussian' ) AND ( 
account LIKE 'PYS%' or account LIKE 'PAN%' or account LIKE 'PAW%' or account='PAS1194' \
or account='PZS0666' or groupname LIKE 'PYS%' or groupname LIKE 'PAN%' or groupname LIKE 'PAW%' \
or groupname='PAS1194' or groupname='PZS0666' )  
GROUP BY account, username, system"  | 
mail -s "Regular Reporting: Gaussian Usage of Commercial Clients between $s_date and $e_date" -S from="hhamblin@osc.edu" -c "xwang@osc.edu" -c "alanc@osc.edu"  hhamblin@osc.edu
