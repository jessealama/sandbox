#!/bin/bash -

repos="hunchentoot-utils sandbox mizar/mizar-items mizar/xsl4mizar mizar/mizarmode mizar/mwiki dialogues polyhedra";
github="https://github.com/jessealama";

for repo in $repos; do
    name=`basename $repo`;
    path=/Users/alama/sources/$repo;
    commits=`git --git-dir=$path/.git log --branches='*' --since yesterday | grep ^commit | cut -f 2 -d ' '`;
    if [ $? -eq "0" ]; then
	for commit in $commits; do
	    msg=`git --git-dir=$path/.git diff-tree -s --pretty=%s $commit`;
	    if [ $? -eq "0" ]; then
		if [[ $msg = "" ]]; then
		    echo "<li><a href=\"$github/$name/$commit\"><em>(no message was supplied)</em></a>";
		else
		    echo "<li><a href=\"$github/$name/commits/$commit\">$msg</a></li>";
		fi;
	    else
		echo "Uh oh: something went wrong calling git on the repo '$repo', with name '$name', at '$path'";
		exit 1;
	    fi
	done
    else
	echo "Uh oh: something went wrong calling git on the repo '$repo', with name '$name', at '$path'";
	exit 1;
    fi
done

exit 0;
