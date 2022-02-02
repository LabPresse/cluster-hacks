#!/bin/bash

function storage () { 
    percent=`df -h | grep your_agave_user_name_here | awk '{ print $5 }'` 
    echo "STORAGE = $percent" 
} 
