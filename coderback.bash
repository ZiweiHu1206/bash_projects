#!/bin/bash
  

#check the number of input arguments
if [[ $# -ne 2 ]]
then
        echo "Error: Expected two input parameters."
        echo "Usage: ./coderback.bash <backupdirectory> <fileordirtobackup>"
        exit 1
fi       

#check the existence of the directory to store the tar file
if [[ ! -d $1 ]]
then    
        echo "Error: The directory '$1' does not exist."
	exit 2
fi           

#check the existence of file or directory to back up
if [[ ! -f $2 && ! -d $2 ]]
then 
	echo "Error: The directory or file '$2' does not exist."
	exit 2
fi

#check if both arguments are the same directory
if [[ $1 -ef $2 ]]
then 
echo "Error: The directory '$1' and '$2' are the same directory."
exit 2
fi

#make a tar filename
dateformat=$(date "+%Y%m%d")

filename=$(basename $2)

tarname="${1}/${filename}.${dateformat}.tar"

#check if the tar file with the same name alredy exists
if [[ -e $tarname ]]
then
	echo -n "Back up file '$tarname' already exists. Overwrite? (y/n)"
	read answer
	if [[ ! $answer = 'y' ]]
	then
		exit 3
	fi
fi

#back up the file or directory
tar -cf $tarname -P $2
exit 0




