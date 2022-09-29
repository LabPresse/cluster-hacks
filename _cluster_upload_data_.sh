#!/bin/bash

my_name=jsbryan4
password=$(head -n 1 _password_.txt)

project=$1

path_local="data/$project"
path_agave="$my_name@agave.asu.edu:/home/$my_name/data/"

echo "Copying data from $path_local to $path_agave"
sshpass -p "$password" rsync -av --exclude=*/raw/ --exclude=*/old --exclude=*/Raw --exclude=*/raw $path_local $path_agave

echo "..done"

