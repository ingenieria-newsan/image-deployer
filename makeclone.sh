#! /bin/bash

# mensaje
printf "\033[5;33m" && figlet -c -f big CLONING... && printf "\033[0m \n"

# parametros de clonado
printf "\n\n --- IMAGE ${1} \n --- TARGET ${2} \n\n"

# volcado de imagen
sudo /usr/sbin/ocs-sr -g auto -e1 auto -e2 -r -j2 -batch -scr -p true restoredisk ${1} ${2}     #### ¡¡ MARK AS COMMENT FOR DEBUG !! ####

# esperando para salir
sleep 10

# aviso sonoro de que finalizo el proceso
sudo timeout 1.5 speaker-test --frequency 500 --test sine > /dev/null 2>&1
