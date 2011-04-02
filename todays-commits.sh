#!/bin/bash -

repos="hunchentoot-utils sandbox mizar/mizar-items mizar/xsl4mizar mizar/mizarmode mizar/mwiki dialogues polyhedra dotemacs";
github="https://github.com/jessealama";

# first, fetch (but don't pull) any new commits 

cannot_fetch=""; # repos from which we cannot fetch the latest commits

echo -n "Fetching new commits...";

for repo in $repos; do
    path=/Users/alama/sources/$repo;
    git --git-dir=$path/.git fetch --quiet origin > /dev/null 2>&1
    fetch_exit_code=$?;
    if [ ! $fetch_exit_code -eq "0" ]; then
	cannot_fetch="$repo $cannot_fetch";
    fi
done

echo "done.";

if [ ! "$cannot_fetch" = "" ]; then # something went wrong
    echo "Unable to fetch any new commits from github for the repos:";
    echo "  $cannot_fetch";
    echo "The following information may not accurately reflect your latest work."
fi

# now check for any uncommitted changes

uncommitted="";

for repo in $repos; do
    path=/Users/alama/sources/$repo;
    cd $path;
    changed=`git status --short --ignore-submodules`;
#                               ^^^^^^^^^^^^^^^^^^^
#                               submodules are either our own work, which is
#                               already being tracked, or the work of others,
#                               which we are not interested in tracking
    if [ ! "$changed" = "" ]; then
	uncommitted="$repo $uncommitted";
    fi
done

if [ ! "$uncommitted" = "" ]; then
    echo "There are uncommitted changes in the following repositories:"
    echo "  $uncommitted";
    echo "To proceed, please commit or stash your changes."
    exit 1;
fi

echo "<dl>";
for repo in $repos; do
    name=`basename $repo`;
    path=/Users/alama/sources/$repo;
    commits=`git --git-dir=$path/.git log --branches='*' --since yesterday | grep ^commit | cut -f 2 -d ' '`;
    if [ $? -eq "0" ]; then
	echo "<dt>$name</dt>";
	if [ "$commits" = "" ]; then
	    echo "<dd><em>(no activity in this repository)</em></dd>";
	else
	    for commit in $commits; do
		msg=`git --git-dir=$path/.git diff-tree -s --pretty=%s $commit`;
		if [ $? -eq "0" ]; then
		    echo -n "<dd>";
		    if [[ $msg = "" ]]; then
			echo -n "<a href=\"$github/$name/$commit\"><em>(no message was supplied)</em></a>";
		    else
			echo -n "<a href=\"$github/$name/commits/$commit\">$msg</a>";
		    fi;
		    echo "</dd>";
		else
		    echo "Uh oh: something went wrong calling git on the repo '$repo', with name '$name', at '$path'";
		    exit 1;
		fi
	    done
	fi
    else
	echo "Uh oh: something went wrong calling git on the repo '$repo', with name '$name', at '$path'";
	exit 1;
    fi
done
echo "</dl>";

exit 0;
