#! /bin/bash

# volcado de imagen
sudo /usr/sbin/ocs-sr -g auto -e1 auto -e2 -r -j2 -batch -scr -p true restoredisk ${1} ${2}

#### DEBUG !!

    printf "\n  --- CLONE --- PARAMETERS --- ${1} --- ${2} ---"
    # sleep 10

#### DEBUG !!

# aviso sonoro de que finalizo el proceso
sudo timeout 1.5 speaker-test --frequency 500 --test sine > /dev/null 2>&1
