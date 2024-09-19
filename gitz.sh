#!/bin/env bash

if [ ! -x "$(which git)" ]; then
   printf "git is missing.\n"
   exit 1
fi


if [ "$1" = "clone" ]; then
   u="$(printf $2 | sed 's/.*github.com\///; s/\/.*//')"
   r="$(printf $2 | sed 's/.*github.com\/.*\///')"
   git clone "$2" "${r}_${u}"
elif [ "$1" = "setup" ]; then
   read -p "username: " u
   read -p "email: " e
  if [ ! -z "$u" ] && [ ! -z "$e" ]; then
   git config --global credential.helper store
   git config --global user.name "$u"
   git config --global user.email "$e"
  fi
elif [ "$1" = "reset" ]; then
   printf "Reseting the repo ..\n"
   git config --global init.defaultBranch main
   r="$(git config --get remote.origin.url)"
   printf "Repo origin: '$r'\n"
   exit
   rm -rf .git
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin "$r"
   git push -u --force origin main
fi
