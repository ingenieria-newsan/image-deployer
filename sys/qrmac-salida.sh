#! /bin/bash

# obtiene mac address
mac=$(ip addr show $(awk 'NR==3{print $1}' /proc/net/wireless | tr -d :) | awk '/ether/{print $2}' | sed "s/://g")

# genera qr con la mac obtenida y lo muestra
printf "\t"
qrencode -t ansi256 ${mac^^}

# obtengo el serial del disco de volcado
printf "\n\n\t"
serial=$(lsblk --nodeps -no serial /dev/${1})

# muestra el serial del disco
qrencode -t ansi256 $serial

# espera 3 segundos 
sleep 6
