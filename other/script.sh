#!/bin/bash

# 1) check the date
date
# 2) check the user
whoami
# 3) print the current directory
pwd
# 4) create a dir called "demo"
mkdir demo
# 5) inside "demo", create 2 files: draft.py and readme.txt
cd demo && touch draft.py && touch readme.txt
# 6) inside "demo", create a "tmp/tmp.txt", "tmp/tmp.py", and"draft.txt"
mkdir tmp && touch tmp/tmp.txt && touch tmp/tmp.py && touch tmp/draft.txt
# 7) return to the demo folder and list all currently existing files.
ls
# 8) from the demo folder, find where is located "draft.txt"
find -name draft.txt
# 9) move draft.txt to the demo folder. rename it as drafts.txt
mv tmp/draft.txt draft.txt && mv draft.txt drafts.txt
# 10) add "hello world\n ni hao" to the drafts.txt file
echo -e "hello world\nni hao" >> drafts.txt
# 11) display the result using cat
cat drafts.txt
# 12) display the drafts.txt status and explain its status using stat.
stat drafts.txt
# 13) change its permission to read-write only
chmod 600 drafts.txt
# 14) display again its status and observe the 
stat drafts.txt
# 15) using grep, find if "bonjour"/"hello" appears in the drafts.txt.
grep "hello" drafts.txt 
grep "bonjour" drafts.txt 
# 16) remove the "hello world" line and replace it with "bonjour"
sed -i "s/^hello/bonjour/1" drafts.txt
# 17) remove "ni hao" from the drafts.txt
sed -i "2d" drafts.txt && cat drafts.txt
# 18) remove the demo folder
cd ..
rm -r demo
# 19) show the shell history
history
# 20) clear your terminal
clear

