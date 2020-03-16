#!/bin/bash

source "$(dirname $(realpath $0))/functions.sh"

CONFIG="/home/dj/Tools/BugBounty/Toolkit/github/basic.conf"

help_text() {
	echo "Usage: github [init|commit|history|show|help] [<args>]"
	if [ "$1" == "extended" ]; then
		echo
		echo "	init		Creates a new repository on Github"
		echo "	commit		Commits a file in the specified repository"
		echo "	commit-all	Commits everything in the specified git repository"
		echo "	log		Show commit history"
		echo "	show		Show recent changes"
		echo "	help		Print this help text"
	fi
	exit 1
}

case $1 in
	"init")
		user=$(cat $CONFIG|grep username|cut -d: -f2)
		is_private=$(cat $CONFIG|grep private|cut -d: -f2)

		# make sure the right amount of args are there
	 	if [ -d "basic.conf" ]; then
			echo -e "\nConfiguration file basic.conf doesn't exist!"
                	exit 1
        	fi

		if [ "$2" == "help" ]; then
			echo "usage: djgit init [<repository>]"
			exit 1
		fi
		github_new_repo $2 $user $is_private
		;;
	"commit")
		if [ "$2" == "help" ]; then
			echo "usage: djgit commit [repository] [commit_message] [file1 file2 etc..]"
			exit 1
		fi
		github_commit $@
		;;
	"commit-all")
		if [ "$2" == "help" ]; then
			echo "usage: djgit commit-all [repository] [commit_message]"
			exit 1
		fi
		github_commit_all $2 $3  
		;;
	"log")
		if [ "$2" == "help" ]; then
			echo "usage: djgit log [repository]"
			exit 1
		fi
		github_history $2
		;;
	"show")
		if [ "$2" == "help" ]; then
			echo "usage: djgit show [repository]"
			exit 1
		fi
		github_show $2
		;;
	"help")
		help_text "extended"
		;;
	*)
		help_text
		;;
esac

