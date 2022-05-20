#!/bin/bash

#this script is to process data files
#if the number of arguments is not 1 or not a directory, terminate
if [[ $# -ne 1 ]]
then
	echo "Usage ./wparser.bash <weatherdatadir>"
	exit 1
elif [[ ! -d $1 ]]
then
       echo "Error! $1 is not a valid directory name" 1>&2
       exit 1
fi

dir_name=$1

#define function extractData to output a clean format of data
extractData(){
	
	#extract only the lines of interest from the datafile
	greplines=$(grep 'observation line' $1)
	
	#reformat the data
	sedlines=$(sed -e 's/NOINF/a/g' -e 's/MISSED SYNC STEP/a/g' -e 's/observation line//g' -e 's/\<data log flushed\>//g' -e 's/[][]//g' <<< ${greplines})


	#ouput a clean format of data using awk
	awklines=$(awk '

	BEGIN {OFS=",";temp1=$3;temp2=$3;temp3=$5;temp4=$6;temp5=$7}

	{if ($3 != "a")
		{temp1=$3}
	}

	{if ($4 != "a")
		{temp2=$4}
	}

	{if ($5 != "a")
		{temp3=$5}
	}

	{if ($6 != "a")
		{temp4=$6}
	}

	{if ($7 != "a")
		{temp5=$7}
	}

	{gsub("0","N",$11)}
	{gsub("1","NE",$11)}
	{gsub("2","E",$11)}
	{gsub("3","SE",$11)}
	{gsub("4","S",$11)}
	{gsub("5","SW",$11)}
	{gsub("6","W",$11)}
	{gsub("7","NW",$11)}

	{print substr($1,1,4), substr($1,6,2), substr($1,9,2), substr($2,1,2), temp1, temp2, temp3, temp4, temp5, $8, $9, $10, $11}
' <<< ${sedlines})


#produce the statistic with max and min temperature for given hour, as well as max and min wind speed
summary=$(awk '
BEGIN {OFS=","}
{maxTemp=-2000;minTemp=2000;maxWS=$8;minWS=$8}
{for (i=3; i<=7; i++){
	if ($i == "a")
		continue;
	if ($i > maxTemp)
		{maxTemp=$i}
	if ($i < minTemp)
		{minTemp=$i}
	}
}

{for (i=8; i<=10; i++){
	if ($i > maxWS)
		{maxWS=$i}
	if ($i < minWS)
		{minWS=$i}
	}
}
{print substr($1,1,4),substr($1,6,2),substr($1,9,2),substr($2,1,2),maxTemp,minTemp,maxWS,minWS}
' <<< ${sedlines})

#print out the two statistics
echo "Processing Data From $1"
echo "===================================="
echo "Year,Month,Day,Hour,TempS1,TempS2,TempS3,TempS4,TempS5,WindS1,WindS2,WindS3,WinDir"

echo "${awklines}"

echo "===================================="
echo "Observation Summary"
echo "Year,Month,Day,Hour,MaxTemp,MinTemp,MaxWS,MinWS"

echo "${summary}"

echo "===================================="
echo "          "
}




#loop through each file with weather info in given directory,use extractdata function to output the two statistics
for filename in $(find ${dir_name} -type f -name 'weather_info_*.data') 
do
	extractData "${filename}"
done



report=""

#report on the health of the temperature sensors across files
for filename in $(find ${dir_name} -type f -name 'weather_info_*.data')
do
	#extract only the lines of interest from the datafile
        greplines=$(grep 'observation line' ${filename})

        #reformat the data
        sedlines=$(sed -e 's/NOINF/a/g' -e 's/MISSED SYNC STEP/a/g' -e 's/observation line//g' -e 's/\<data log flushed\>//g' -e 's/[][]//g' <<< ${greplines})
	
	#output the line of error for each day
	eachday=$(awk '
	BEGIN {total_error=0; error1=0; error2=0; error3=0; error4=0; error5=0}
	{if ($3 == "a")
        {error1=error1+1; total_error=total_error+1}}
	
	{if ($4 == "a")
        {error2=error2+1; total_error=total_error+1}}
	
	{if ($5 == "a")
        {error3=error3+1; total_error=total_error+1}
        }

	{if ($6 == "a")
		{error4=error4+1; total_error=total_error+1}
	}

	{if ($7 == "a")
		{error5=error5+1; total_error=total_error+1}
	}

	END {print substr($1,1,4),substr($1,6,2),substr($1,9,2),error1,error2,error3,error4,error5,total_error}
	'  <<< ${sedlines})

	#append error report of each day to the full report
	report="${report}"$'\n'"${eachday}"

done  


#sort the report of temperature sensor errors   
report=$(echo "${report}" | sort -k9nr -k1,1n -k2,2n -k3,3n)


#format the file into an html table
table=$( awk '

BEGIN {print "<HTML>\n<BODY>\n<H2>Sensor error statistics</H2>\n<TABLE>\n<TR><TH>Year</TH><TH>Month</TH><TH>Day</TH><TH>TempS1</TH><TH>TempS2</TH><TH>TempS3</TH><TH>TempS4</TH><TH>TempS5</TH><TH>Total</TH></TR>"}

{print "<TR><TD>",$1,"</TD><TD>",$2,"</TD><TD>",$3,"</TD><TD>",$4,"</TD><TD>",$5,"</TD><TD>",$6,"</TD><TD>",$7,"</TD><TD>",$8,"</TD><TD>",$9,"</TD></TR>"}

END {print "</TABLE>\n</BODY>\n</HTML>"}

' <<< ${report})

#store the table to a file called sensorstats.html
echo "${table}" > sensorstats.html





