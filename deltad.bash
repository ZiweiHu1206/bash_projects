#!/bin/bash

#Ziwei Hu
#Faculty of Science, Computer Science
#zhu21@mimi.cs.mcgill.ca 260889365

#check the number of arguments
if [[ $# -ne 2 ]]
then 
	echo "Error: Expected two input parameters."
	echo "Usage: ./deltad.bash <originaldirectory> <comparisondirectory>"
	exit 1
fi

#check both input arguments are directory
if [[ ! -d $1 ]]
then
	echo "Error: Input parameter #1 '$1' is not a directory."
	echo "Usage: ./deltad.bash <originaldirectory> <comparisondirectory>"
	exit 2
fi

if [[ ! -d $2 ]]
then 
	echo "Error: Input parameter #2 '$2' is not a directory."
	echo "Usage: ./deltad.bash <originaldirectory> <comparisondirectory>"
	exit 2
fi

#check the two directories are different directory
if [[ $1 -ef $2 ]]
then
	echo "Error: The two parameters are the same directory."
	exit 2
fi


#report files which are differ or missing
filelist_firstdir=$(ls -p $1)
filelist_seconddir=$(ls -p $2)
declare -i num_diff=0

#iterate through the file list of the first directory and check missing or differ files
for afile in $filelist_firstdir
do
	pathname_a="${1}/${afile}"
	pathname_b="${2}/${afile}"

	#if afile is a directory, then ignore it
	if [[ $afile = */ ]]
	then
		continue
	fi

	#if afile is not in the second directory, then report
	if [[ ! -f ${pathname_b} ]]
	then
		echo "${pathname_b} is missing"
		num_diff=$[${num_diff}+1]
		continue
	fi

	#if afile is in the second directory, then check for the content
	if [[ $(diff ${pathname_a} ${pathname_b} | wc -l) -ne 0 ]]
	then
		echo "${pathname_a} differs"
		num_diff=$[${num_diff}+1]
		continue
	fi
done


#iterate through the second directory file list to check missing files
for bfile in $filelist_seconddir
do
	bpathname="${2}/${bfile}"
	apathname="${1}/${bfile}"
	if [[ ${bfile} = */ ]]
	then
		continue
	fi

	if [[ ! -f ${apathname} ]] 
	then
		echo "${apathname} is missing"
		num_diff=$[${num_diff}+1]
		continue
	fi
done


if [[ $num_diff -eq 0 ]]
then
	exit 0
else
	exit 3
fi

		

	  













