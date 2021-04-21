#! /bin/bash

git add .
git commit -m "new post at $(date '+%Y-%m-%d')"
git push
