#! /bin/bash

# sonido de error
./sys/error-sonido.sh &

COLUMNS=$(tput cols)

# mensaje de error por falta de cargador
text="FALTA CONEXIÓN A ALIMENTACION EXTERNA"
printf "\n\n \033[1;30m %*s \033[0m \n" $(((${#text}+$COLUMNS)/2)) "$text"

text="Por favor, conecte el cargador al equipo"
printf "\n\n\n %*s \n" $(((${#text}+$COLUMNS)/2)) "$text"

# verifica conexion de cargador
bateria=$(cat /sys/class/power_supply/ADP1/online)
while [ $bateria != 1 ]
	do
		sleep 1
		bateria=$(cat /sys/class/power_supply/ADP1/online)
done

# mensaje de conexión detectada
printf '[ INFO ] Conexión a alimentación externa detectada\n'
