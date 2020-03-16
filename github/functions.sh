source ~/.bash_colors

github_new_repo() {
	repo=$1
	user=$2
	is_private=$3

        # create and navigate to the git directory 
	if [ -d "$repo" ]; then
		if [ -d "$repo/.git" ]; then
			echo -e "\033[31m! $repo already initialized as a git repository\033[0m"
			exit 1
		fi		
	else
        	mkdir $repo
	fi
	
        # initialize git repository
        git -C $repo init
        echo "New git project: $repo" > $repo/README.md
        git -C $repo add README.md
        git -C $repo commit -m "Initialized $repo"

        # create the remote repository on Github.com
	repo_name=`echo $repo|cut -d/ -f5`
        curl -s -u $user https://api.github.com/user/repos -d "{\"name\": \"$repo_name\", \"private\": $is_private}" 1>/dev/null
	if [ "$?" -eq 0 ]; then
		git -C $repo remote add origin git@github.com:$user/$repo_name.git
		echo -e "\033[34m- Successfully created $repo_name on github.com\033[0m"
	else
		echo -e "\033[31m! Failed to create $repo_name on github.com\033[0m"
		exit 1
	fi

        # push the changes to finish creating the project
        git -C $repo push --set-upstream origin master
} 

github_commit_all() {
	repo=$1
	commit_message="$2"

	if [ ! -d $repo ]; then
		echo -e "\033[31m! Github repo $repo doesn't exist. Try running github init <repo-name>\033[0m"
		exit 1
	elif [ -z $commit_message ]; then
		echo -e "$RED You must specify a commit message! $OFF"
	else
        	git -C $repo add .
        	git -C $repo commit -m $commit_message
        	git -C $repo push origin master
	fi
}

github_commit() {
	repo=$2
	commit_message="$3"
	shift
	shift
	shift
	shift
	if [ ! -d $repo ]; then
		echo -e "\033[31m! Github repo $repo doesn't exist. Try running github init <repo-name>\033[0m"
		exit 1
	elif [ -z $commit_message ]; then
		echo -e "$RED You must specify a commit message!"
	else
		git -C $repo add $@
		git -C $repo commit $@ -m "$commit_message"
		git -C $repo push origin master
	fi

}

github_history() {
	repo=$1

	if [ ! -d $repo ]; then
		echo -e "\033[31m! Github repo $repo doesn't exist. Try running github init <repo-name>\033[0m"
		exit 1
	else
        	git -C $repo log
	fi
}

github_show() {
	repo=$1

	if [ ! -d $repo ]; then
		echo -e "\033[31m! Github repo $repo doesn't exist. Try running github init <repo-name>\033[0m"
		exit 1
	else
        	git -C $repo show
	fi
}
