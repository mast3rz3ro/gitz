#!/bin/env bash

if [ ! -x "$(which git)" ]; then
   printf "git is missing.\n"
   exit 1
fi




usage ()
{
printf "usage: gitz [parameter]
 setup or s (setup git for first run)
 clone or c (clone repo with their username)
 clean or c2 (clean repo from garbage files)
 reset or r (permanently reset into initial commit)
"
exit 0
}


if [ -s "./gitz.sh" ] && [ -z "$1" ]; then
   printf "Installing: '$PREFIX/bin/gitz'\n"
   cp "./gitz.sh" "$PREFIX/bin/gitz"
elif [ "$1" = "clone" ] || [ "$1" = "c" ]; then
   u="$(printf $2 | sed 's/.*github.com\///; s/\/.*//')"
   r="$(printf $2 | sed 's/.*github.com\/.*\///')"
   git clone "$2" "${r}_${u}"
elif [ "$1" = "setup" ] || [ "$1" = "s" ]; then
   read -p "username: " u
   read -p "email: " e
   read -p "token: " t
  if [ ! -z "$u" ] && [ ! -z "$e" ] && [ ! -z "$t" ]; then
   read -p "Override your current settings (y/n): " choice
  if [ "$choice" = "y" ]; then
   git config --global init.defaultBranch main
   git config --global credential.helper store
   git config --global user.name "$u"
   git config --global user.email "$e"
   printf "Saving token into: "~.git-credentials
   printf "https://${u}:${t}@github.com">~/.git-credentials
  else
   printf "Aborting..\n"
  fi
 fi
elif [ "$1" = "reset" ] || [ "$1" = "r" ]; then
   printf "Reseting the repo ..\n"
   printf "WARNING: THIS CAN NOT BE UNDONE !\n"
   read -p "Continue ? (y/n)" choice
 if [ "$choice" = "y" ]; then
   git config --global init.defaultBranch main
   r="$(git config --get remote.origin.url)"
   printf "Repo origin: '$r'\n"
   rm -rf .git
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin "$r"
   git status
   read -p "Are you sure want to push the changes (y/n): " choice
   if [ "$choice" = "y" ]; then
     sleep 5
     git push -u --force origin main
   else
     printf "Aborting ..\n"
   fi
 else
   printf "Aborting ..\n"
 fi
elif [ "$1" = "clean" ] || [ "$1" = "c2" ]; then
   g="\
   autom4te.cache
   aclocal.m4
   config.h
   config.log
   config.sub
   config.guess
   config.status
   configure
   configure~
   depcomp
   install-sh
   compile
   main
   m4
   *.pc
   *.o
   ltmain.sh
   missing
   mkinstalldirs
   libtool
   stamp-h1
   Makefile
"
   make clean >/dev/null 2>&1
  for x in $g; do
    x="$(find . -name "$x" 2>/dev/null | tr '\n' ' ')"
   for r in $x; do
      rm -rf "$r" >/dev/null 2>&1
     if [ ! -z "$r" ] && [ "$0" != "0" ]; then
      printf "error: rm -rf '$r'\n"
      #printf "error [$0]: rm -rf '$r'\n"
     fi
   done
  done
   git status
  if [ "$(git status | grep -coF "modified:")" != "0" ] || [ "$(git status | grep -coF "deleted:")" != "0" ]; then
   c="$(git log --oneline -n1 | awk '{print $1}')"
   printf "An error occurred, reseting into last commit: $c\n"
   git reset --hard "$c"
  fi
else
   usage
fi

