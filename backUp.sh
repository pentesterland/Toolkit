#!/bin/bash
#	Created by DJ Nelson
# 	A script for backing up files with an option to upload to github

source ~/.bash_colors

HOME_BACKUP="/home/dj/Backup"
BACKUP="/home/dj/Public/MyCloud"
DESTINATION="SeagateBackup/BUP_Slim_BL-1/backups"


function help() {
        echo -e "\nUsage: backup -b=<backup_name> -l=<file1,file2> [options]"
        echo "[options]:"
        echo -e "\t-b=[BACKUP_NAME]\tName for the backup"
        echo -e "\t-l=[BACKUP_LIST]\tList containing files to back up"
	echo -e "\t-g=[GITHUB_REPO]\tGithub repository to backup the archive to"
        echo -e "\t-h\t\t\tShow help text"

        exit 1
}

## COMMAND LINE PARSING
#
while [ "$1" != "" ]; do
        param=`echo $1 |awk -F= '{ print $1 }'`
        value=`echo $1 |awk -F= '{ print $2 }'`

        # if the -help option was specified
        if [ $1 == "-h" ]; then
                echo "A simple linux backup script"
                help
        fi

        case $param in
                -b)
                        backup_name=$value
                        ;;
                -l)
                        backup_list=$value
                        ;;
		-g)
			github_repo=$value
			;;
                *)
                        echo "[!] $param is an incorrect option. See -h for more info."

                        exit 1
                        ;;
        esac
        shift
done

# make sure script runs as root
if [[ $EUID -ne 0 ]]; then
	echo -e "[${RED}!${OFF}] This script must be run as root"
	exit 1
fi


## PARAMETER CHECK
# check to make sure the backup_name and backup_list variables are set
if [ -z "$backup_name" ]; then
        # print the help message
        echo -e "[${RED}!${OFF}] You must specify a name for your backup directory"
else
        # create the temporary backup directory
        mkdir -p $backup_name

        # name the archive using the directory basename
        archive="${backup_name}_$(date +'%m-%d-%y_%H-%M'.zip)"
fi

if [ -z "$backup_list" ]; then
        # print the help message
        echo -e "[${RED}!${OFF}] You must specify a backup list to read filenames from"
fi

## ARCHIVE
# copy the files to the backup directory and archive them
for file in $(echo $backup_list |tr -s ',' '\n'); do
	rsync -rz $file $backup_name

	if [[ $? -eq 0 ]]; then
		echo -e "[${BLUE}*${OFF}] Copied $file to $backup_name"
	else 
		echo -e "[${RED}!${OFF}] Failed to copy $file to $backup_name"
		exit 1
	fi
done

zip -r -q $archive $backup_name

# make sure archiving the backup directory was successful
if [ $? -eq 0 ]; then
        echo -e "[${BLUE}*${OFF}] Files archived in ${YELLOW}$archive${OFF}"
        # remove the backup directory when the archive is successful
        rm -rf $backup_name
else
        echo -e "[${RED}!${OFF}] Failed to create $backup_name"
        exit 1
fi

## BACKUP
# move the archive over to MyCloud
MOUNT=$(showmount -e mycloud| grep -v Export| cut -d' ' -f1)

if ! grep -qs $MOUNT /proc/mounts; then
	mount -t nfs mycloud:$MOUNT $BACKUP
fi

rsync -z $archive $BACKUP/$DESTINATION

if [[ $? -eq 0 ]]; then
	echo -e "[${BLUE}*${OFF}] Successfully backed up ${YELLOW}$archive${OFF} to MyCloud"
else
	echo -e "[${RED}!${OFF}] Failed to back up $archive"
	exit 1
fi

## GITHUB
# optional upload the archive to Github as well
if [ -d "$github_repo" ]; then
	mv $archive $github_repo		
fi

# use custom github tool to upload to github repository
/home/dj/.bin/github commit-all $github_repo "backing up $archive"

