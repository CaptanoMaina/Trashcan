#! /bin/bash
NAME="Margaret Maina"
STUDENTID="S1906597"


if [ ! -d "$HOME/.trashCan" ]
then
	echo "Creating Trashcan Directory"
	mkdir "$HOME/.trashCan"
else 
	echo "You have a Trashcan"
fi


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




USAGE="usage: $0 safeDel.sh[OPTION].. [FILE].." 


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



function recoverFiles(){
	if [ "$(find $HOME/.trashCan/$1)" ]
then	
	mv $HOME/.trashCan/$1 $(pwd)
	echo "file has been restored"
else 
	echo "file not found"
fi
}




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



function totalUsage(){
	echo "Total trashcan usage is $(du -sh $HOME/.trashCan/ | cut -f1)"
	if [ "$(du -s $HOME/.trashCan/ | cut -f1)" -gt 1 ];
then 
	echo "Warning!! The disk usage exceeds 1kb"

fi
}


function launchMonitor(){
	xfce4-terminal -x  ./monitor.sh &
	echo "Monitor has been launched"

}



function killingMonitor(){
	MONITOR_PID=$(pgrep -f ./monitor.sh) 
	kill $MONITOR_PID
	echo "The Monitor has been killed"
}




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


((pos = OPTIND - 1))

shift $pos

PS3='option> '


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



