#! /bin/bash
NAME="Margaret Maina"
STUDENTID="S1906597"

#A trashcan directory is created if none is present. If one is resent a message is sent to show a trashcan directory is present.A menu showing the safeDel options 


if [ ! -d "$HOME/.trashCan" ]
then
	echo "Creating Trashcan Directory"
	mkdir "$HOME/.trashCan"
else 
	echo "You have a Trashcan"
fi


#Every time a command is terminated by SIGINT using Ctr-c,  the trap  indicates the current total number of regular files in the user’s trashCan directory in an appropriate message and then the script terminates.

trap trapInt SIGINT
trapInt(){
local increment
    if find $HOME/.trashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
      for var in $HOME/.trashCan/*; do
       increment=$(($increment+1))
      done 
	echo -e "\n"
	echo  "There are $increment files in the trashcan."
else 
	echo -e "\n"
     echo "There are no files in the trashcan"
    fi
    exit 130
}


# $0 expands to the name of the shell script.
# declaring a string providing helper documentation to the user on the different options

USAGE="usage: $0 safeDel.sh[OPTION]... [FILE]..." 

#The file is moved to the trashcan if a similar file doesn’t exist already. User is prompted to rename the file if the file exists in the trashcan. The renamed file is moved to the trashcan.

safeDelete(){
for fname in "$@"; do
    
    if [[ -e $fname ]]; then
      echo "Are you sure want to delete $fname (y/n): "
      read resp  
      case $resp in
         n | N)
          echo "$fname deletion cancelled"
         ;;
          y | *)
          if [[ -e $HOME/.trashCan/$fname ]]; then
             chname=$fname
             while [[ -e $HOME/.trashCan/$chname ]]; 
do
             	echo "A similar file $fname already exists,please rename this file: "
                read chname
             done   
	     mv $fname $chname
        
             mv $chname $HOME/.trashCan 
          echo "The file $fname has been renamed to $chname and suceessfully deleted"  
          else
          mv $fname $HOME/.trashCan
          echo "The file $fname has been deleted successfully"
          fi
        ;;
      esac
     else
       echo "This file does not exist in this directory."	

     fi
   done
}


#checking if trashcan has any files and a list is displayed  on screen with the contents of the trashCan directory; output is properly formatted as “file name” (without path), “size” (in bytes) and “type” for each file

function listFiles(){
	if  find $HOME/.trashCan/*  -mindepth 1  
then
	for var in $HOME/.trashCan/*;
	do 
	  FILENAME="${var##*/}"
	  SEPARATOR="${FILENAME%.[^.]*}" 
	  FILESIZE=$(du -sh "$var" | cut -f1)
	  FILETYPE="${FILENAME:${#SEPARATOR} + 1}"
	echo -e "FileName: $FILENAME\n FileSize: $FILESIZE\n FileType: $FILETYPE\n\n"
done
else
	echo "There are no files in Trashcan"
fi

}


#recovering files from the trashcan by moving it from the trashcan to the current directory

function recoverFiles(){
	if [ "$(find $HOME/.trashCan/$1)" ]
then	
	mv $HOME/.trashCan/$1 $(pwd)
	echo "file has been restored"
else 
	echo "file not found"
fi
}


#deleting files from the trashcan by removing it from the trashcan after prompting the user if they want to delete the file
function emptyTrash(){
	if [ "$(find $HOME/.trashCan/*)" ]
then
	for var in $HOME/.trashCan/* ;
do	
	FILENAME="${var##*/}"
echo -e "Are you sure you want to delete $FILENAME? (y/n)"
	read RESPONSE 
	if [ $RESPONSE == y ]
then
	rm $var
echo "$FILENAME has been deleted permanently"

elif [ $RESPONSE == n ]
then
	echo -e "$FILENAME deletion has been cancelled"
else 
	echo "Invalid Option"

fi
done
else 
	echo "Trashcan is empty"
fi
}



#checking displaying the total usage of trashcan in bytes snd giving a warning if exceeds 1kb
function totalUsage(){
	echo "Total trashcan usage is $(du -sh $HOME/.trashCan/ | cut -f1)"
	if [ "$(du -s $HOME/.trashCan/ | cut -f1)" -gt 1 ];
then 
	echo "Warning!! The disk usage exceeds 1kb"

fi
}


#launching the monitoron a separate terminal
function launchMonitor(){
	xfce4-terminal -x  ./monitor.sh &
	echo "Monitor has been launched"

}


#killing the monitor by closing the terminal the monitor was on
function killingMonitor(){
	MONITOR_PID=$(pgrep -f ./monitor.sh) 
	kill $MONITOR_PID
	echo "The Monitor has been killed"
}


# looping through and retreiving the positional parameters using getopts

while getopts :dlr:etmk args #options
do
  case $args in
     d) read fname
	safeDelete $fname;;
     l) listFiles;;
     r) recoverFiles; data: $OPTARG;;
     e) emptyTrash;; 
     t) totalUsage;; 
     m) launchMonitor;; 
     k) killingMonitor;;     
     :) echo "data missing, option -$OPTARG";;
    \?) echo "$USAGE";;
  esac
done

#OPTIND is initialized by 1

((pos = OPTIND - 1))
# removes all the options
shift $pos

PS3='option> '

# $# is the number of positional parameters
# ensure no options have been passed

if (( $# == 0 ))
then if (( $OPTIND == 1 )) 
 then select menu_list in deleteFile list recover emptyTrash total monitor kill exit
      do case $menu_list in
	"deleteFile") 
	read fname
	safeDelete $fname;;
         "list") listFiles;;
         "recover") echo "Enter FileName"
	read FNAME 
	recoverFiles $FNAME;;
         "emptyTrash") emptyTrash;;
         "total") totalUsage;;
         "monitor") launchMonitor;;
         "kill") killingMonitor;;
         "exit") exit 0;;
         *) echo "unknown option";;
         esac
      done
 fi
else echo "extra args??: $@"
fi


