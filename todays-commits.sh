#!/bin/bash -

repos="hunchentoot-utils sandbox mizar/mizar-items mizar/xsl4mizar mizar/mizarmode mizar/mwiki";

for repo in $repos; do
    name=`basename $repo`;
    path=/Users/alama/sources/$repo;
    commits=`git --git-dir=$path/.git log --since yesterday | grep ^commit | cut -f 2 -d ' '`;
    if [[ $? -eq "0" ]]; then
	for commit in $commits; do
	    msg=`git --git-dir=$path/.git diff-tree -s --pretty=%s $commit`;
	    if [[ $? -eq "0" ]]; then
		if [[ $msg = '' ]]; then
		    echo "<li><a href=\"https://github.com/jessealama/$name/$commit\"><em>(no message was supplied)</em></a>";
		else
		    echo "<li><a href=\"https://github.com/jessealama/$name/commits/$commit\">$msg</a></li>";
		fi;
	    else
		echo "Uh oh: something went wrong calling git on the repo '$repo', with name '$name', at '$path'";
	    fi
	done
    else
	echo "Uh oh: something went wrong calling git on the repo '$repo', with name '$name', at '$path'";
    fi
done

exit 0;
