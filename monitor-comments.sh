#! /bin/bash
NAME="Margaret Maina"
STUDENTID="S1906597"


BIN=$HOME/.trashCan

#looping to execute until the monitor script is killed
while : ;
do 
    clear
    cd $BIN
# Passing the  variable to md5sum to generate hash values and the results are saved in a hidden file in the trashcan directory.
    md5sum $(ls) > "../.file.md5" 
    echo -n "Watching your trashCan directory for changes ..."
#delaying the next action by 8 seconds
    sleep 8
    #initialize variables to store each change
    updatedFiles=0; addedFiles=0; deletedFiles=0
#storing the hashed result to a file
    md5sum $(ls) > "../.checking.md5"
#counting the number of new lines in both files and storing the counts to two variables
    list1=$(wc -l "../.checksums.md5" | awk '{ print $1 }')
    list2=$(wc -l "../.updatedchecksums.md5" | awk '{ print $1 }')

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
#delays the start of next loop by 7 seconds
    sleep 7
done 

