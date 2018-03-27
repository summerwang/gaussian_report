#!/usr/bin/env bash
#
# Author: Summer Wang (xwang@osc.edu) 
# Modified: 03/27/18
#
# This script queries the jobs database to calculate the CPU hours for commercial jobs using Gaussian. 
#
# For more information on this cronjob see the sys doc page at https://wiki.osc.edu/index.php?title=Report_basf_gaussian_usage.sh
#

tmp=`mktemp -d tmp.XXXXXXXX`
cd $tmp

echo "Enter the start date from which the report of Gaussian usage of commercial clients is generate (yyyy-mm-dd). For example, July 01, 2017 is 2017-7-1."
read  s_date
echo "Enter the end date by which the report of Gaussian usage of commercial clients is generate (yyyy-mm-dd). For example, July 01, 2017 is 2017-7-1."
read e_date

mysql -hdbsys01.infra -uwebapp pbsacct --execute=" 
SELECT '$s_date' AS startDate, '$e_date' AS endDate;
SELECT account, username, system, COUNT(jobid) AS jobs, 
SUM(nproc*TIME_TO_SEC(walltime))/3600. AS cpuhours FROM Jobs WHERE ( 
start_date>='$s_date' AND start_date<='$e_date') AND ( 
sw_app='gaussian' ) AND ( 
account LIKE 'PYS%' or account LIKE 'PAN%' or account LIKE 'PAW%' or account='PAS1194' \
or account='PZS0666' or groupname LIKE 'PYS%' or groupname LIKE 'PAN%' or groupname LIKE 'PAW%' \
or groupname='PAS1194' or groupname='PZS0666' )  
GROUP BY account, username, system"  > out.txt

awk '{if(NR<4)print $0}' out.txt >>  gaussian_user1.txt;

awk '{if(NR>3)print $2}' out.txt | while read LINE; 
do  new=$(groups "$LINE");
 if [[ $new = *"GaussC"* ]]; then
  grep $LINE out.txt >>  gaussian_user1.txt;
 fi;
done

awk '!a[$0]++' gaussian_user1.txt > gaussian_user.txt
cat gaussian_user.txt | mail -s "Regular Reporting: Gaussian Usage of Commercial Clients between $s_date and $e_date" -S from="hhamblin@osc.edu" -c "xwang@osc.edu" -c "alanc@osc.edu"  hhamblin@osc.edu

cd ..
rm -rf $tmp



