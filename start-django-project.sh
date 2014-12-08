#!/bin/bash

[ $# -eq 0 ] && { echo "Usage: $0 projectname login"; exit 1; }
[ "$2" == "" ] && { echo "Usage: $0 projectname login"; exit 1; }


[ -e $1 ] && { echo "$1: file is exists"; exit 2;}

source `which virtualenvwrapper.sh`

repo=$1
login=$2


mkvirtualenv $repo
retval=$?
if [ $retval != 0 ]; then
    echo Error: mkvirtualenv
    exit
fi

workon $repo
pip install Django
if [ $retval != 0 ]; then
    echo Error: pip install Django
    exit
fi

django-admin.py startproject $repo

if [ $retval != 0 ]; then
    echo Error: django-admin.py startproject $repo
    exit
fi

cd $repo
git init
git add .
git commit -m "Initial commit"

echo "Input password for $login:"
read -s pass

curl --user $login:$pass https://api.bitbucket.org/1.0/repositories/ \
--data name=$repo --data is_private='true' --data language="python"

if [ $retval != 0 ]; then
    echo Error: bitbucket API error
    exit
fi

git remote add origin git@bitbucket.org:$login/$repo.git
git push -u origin --all
git push -u origin --tags
