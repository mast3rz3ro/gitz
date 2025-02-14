#!/bin/env bash

if [ ! -x "$(which git)" ]; then
	echo "git is missing."
	exit 1
fi




usage()
{
	echo -e "\
usage: gitz [parameter]
 setup or s (setup git for first run)
 clone or c (clone repo with their username)
 clean or c2 (clean repo from garbage files)
 reset or r (permanently reset into initial commit)"
exit 0
}


if [ -s "./gitz.sh" ] && [ -z "$1" ]; then
	echo "Installing: '$PREFIX/bin/gitz'"
	cp "./gitz.sh" "$PREFIX/bin/gitz"
elif [ "$1" = "clone" ] || [ "$1" = "c" ]; then
	r="$(basename "$2")"
	u="$(dirname "$2")"; u="${u/*\/}"
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
			echo "Saving token into: "~.git-credentials
			echo "https://${u}:${t}@github.com">~/.git-credentials
		else
			echo "Aborting..."
		fi
	fi
elif [ "$1" = "reset" ] || [ "$1" = "r" ]; then
		echo "Reseting the repo..."
		echo "WARNING: THIS CAN NOT BE UNDONE !"
		read -p "Continue ? (y/n)" choice
	if [ "$choice" = "y" ]; then
			b="$(git rev-parse --abbrev-ref HEAD)"
			[ -z "$b" ] && b="main"
			git config --global init.defaultBranch "$b"
			r="$(git config --get remote.origin.url)"
			echo "Repo origin: '$r'"
			echo "Branch: '$b'"
			rm -rf ./.git
			git init; git add .; git commit -m "Initial commit"
			git remote add origin "$r"; git status
			read -p "Are you sure want to push the changes (y/n): " choice
		if [ "$choice" = "y" ]; then
			sleep 5
			git push -u --force origin "$b"
		else
			echo "Aborting..."
		fi
	else
		echo "Aborting..."
	fi
elif [ "$1" = "clean" ] || [ "$1" = "c2" ]; then
	git clean -dfx
else
		usage
fi

