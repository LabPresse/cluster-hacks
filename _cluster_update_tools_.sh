#!/bin/bash

my_name=jsbryan4
password=$(head -n 1 _password_.txt)

path_local="./tools/*"
path_agave="$my_name@agave.asu.edu:/home/$my_name/tools/."

echo "Copying tools from $path_local to $path_agave"
sshpass -p "$password" rsync -rv $path_local $path_agave

echo "..done"

