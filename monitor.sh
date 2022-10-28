#! /bin/bash
NAME="Margaret Maina"
STUDENTID="S1906597"


BIN=$HOME/.trashCan


while : ;
do 
    clear
  
    cd $BIN
    md5sum $(ls) > "../.checksums.md5" 

    echo -n "Monitoring the trashCan directory ..."

    sleep 8

    updatedFiles=0; addedFiles=0; deletedFiles=0

    md5sum $(ls) > "../.checking.md5"

    list1=$(wc -l "../.checksums.md5" | awk '{ print $1 }')
    list2=$(wc -l "../.checking.md5" | awk '{ print $1 }')

    [ $list1 -lt $list2 ] && addedFiles=$(($list2 - $list1))
    [ $list1 -gt $list2 ] && deletedFiles=$(($list1 - $list2))

    updatedFiles=$(md5sum --quiet --check ../.checksums.md5 2>/dev/null | wc -l)
    

 echo "=============="  
 ls -tl;
 echo "=============="



    echo "  Deleted Files : $deletedFiles "
    echo "  Added Files  : $addedFiles "
    echo "  Updated Files: $updatedFiles "


    echo ""
    sleep 7
done 

