#!/bin/bash
START=$PWD
TL=$START/../../../

sed -e s/VER/"$1"/g $START/index_template.md >$START/index1.md
sed -e s/KERN/"$2"/g $START/index1.md >$START/index.md
#exit 0
cd $TL/CommonWealthRobotics.github.io/
git pull
cp $START/index.md $TL/CommonWealthRobotics.github.io/content/index.md
git commit -m"rev bump to $1" $TL/CommonWealthRobotics.github.io/content/index.md
git push
rm $START/index.md
rm $START/index1.md