#! /bin/bash

clear
m_pass='\033[1;32m PASS \033[0m' # ${m_pass}
m_fail='\033[5;31m FAIL \033[0m' # ${m_fail}
m_warn='\033[1;33m WARN \033[0m' # ${m_warn}
m_info='\033[1;37m INFO \033[0m' # ${m_info}

# presentación
printf "\033[1;36m" && figlet -c -f small IMAGE DEPLOYER 1.0 && printf "\033[0m \n"

# directorio de trabajo
SCRIPT=$(readlink -f $0);
dir_base=`dirname $SCRIPT`;

# muestra la version de la herramienta
version=$(cat $dir_base/.git/refs/heads/master)
printf "[${m_info}] tool_version=${version}\n"

# chequea que nombre tiene el disco de systemDisk y el de targetDisk
systemDisk=$(lsblk -no pkname $(findmnt -n / | awk '{ print $2 }'))
targetDisk=$(cat $dir_base/config/image.target)

printf "[${m_info}] systemDisk=${systemDisk} targetDisk=${targetDisk}.\n"

if [ $systemDisk == $targetDisk ]
	then
		printf "[${m_fail}] systemDisk and targetDisk are the same.\n"
        printf "[# ${m_info}] Image deploy canceled. System will shutdown.\n"
        sleep 10
        shutdown now
fi

sleep .1

# monta la particion donde se encuentra la imagen a volcar en /home/partimag
printf "[${m_info}] Montando particiones...\n"
sudo umount /dev/${systemDisk}3 > /dev/null 2>&1
sudo umount /jmdisk > /dev/null 2>&1
sudo mount /dev/${systemDisk}3 /home/partimag
sudo mkdir /jmdisk > /dev/null 2>&1
sudo mount /dev/${targetDisk}3 /jmdisk

sleep .1

# chequea que el sku indicado en el disco target coincida con el configurado
printf "[${m_info}] Validación de SKU..."
sku_check=false
if [ $(cat $dir_base/config/image.sku) = $(sudo dmidecode -s bios-version) ]
	then
		printf "${m_pass}\n"
		sku_check=true
	else
		printf "${m_fail}\n"
		bios_check=false
		gnome-terminal --full-screen --hide-menubar --profile texto-error --wait -- ./sys/error-generico.sh BIOS
fi

sleep .1

# desmonta el disco donde se encuentra el flag del running
sudo umount /jmdisk > /dev/null 2>&1

sleep .1

# main process
if [ $hash_check == "true" ] &&  [ $bios_check == "true" ]
	then
		
		# valida que la bateria esté conectada
		bateria=$(cat /sys/class/power_supply/ADP1/online) #bateria=$(cat /sys/class/power_supply/ACAD/online)
		if [ $bateria != 1 ]
			then
				printf "[${m_warn}] Falta conexión a alimentación externa\n"
				gnome-terminal --full-screen --hide-menubar --profile texto-error --wait -- ./sys/error-bateria.sh
			else
				printf "[${m_info}] Conexión a alimentación externa detectada\n"
		fi
		
		# mensaje volcado de imagen
		printf "[${m_info}] Iniciando volcado de imagen...\n"
	
		# mensaje para apagado de modo incorrecto
		# COLUMNS=$(tput cols) 
		# text="ERROR EN EL APAGADO DEL EQUIPO"
		# printf "\n\n \033[5;31m %*s \n" $(((${#text}+$COLUMNS)/2)) "$text"
		# printf "\n\t Por favor apaguelo manualmente manteniendo presionado el boton \n\t de apagado durante 5 segundos \033[0m \n\n"
		
		# bucle de volcado y control de imagen		
		image_check=false
		image_counter=0

		while [ $image_check == "false" ]
			do
				# contador de errores y borrado de log previo
				error_counter=0
				if [ -e /var/log/clonezilla.log ]
					then
						sudo rm -f /var/log/clonezilla.log
						printf "[${m_info}] Se eliminó correctamente el log anterior de Clonezilla.\n"
				fi

				# volcado de imagen
				image_name=$(cat $dir_base/versiones/image.version)
				gnome-terminal --full-screen --hide-menubar --profile texto --wait -- ./sys/volcado.sh $image_name $targetDisk
				printf "[${m_info}] Volcado de imágen finalizado.\n"

				#validaciones
				printf "[${m_info}] Iniciando validaciones...\n"

				# validación de particiones
				if [ $(grep -c $targetDisk /proc/partitions) = 6 ]
					then
						printf "[${m_pass}]"
					else
						printf "[${m_fail}]"
						error_counter=$((error_counter+1))
				fi
				printf " Particiones en disco de destino.\n"

				sleep .1

				# validafion finalizacion del proceso Clonezilla
				if [ -e /var/log/clonezilla.log ]
					then
						if [ $(cat /var/log/clonezilla.log | grep -c "Ending /usr/sbin/ocs-sr at" ) = 1 ]
							then
								printf "[${m_pass}]"
							else
								printf "[${m_fail}]"
								error_counter=$((error_counter+1))
						fi
					else
						printf "[${m_fail}]"
						error_counter=$((error_counter+1))
				fi
				printf " Finalización del proceso Clonezilla.\n"
				sleep .1

				# validafion errores del proceso Clonezilla
				if [ -e /var/log/clonezilla.log ]
					then
						if [ $(tail -1 /var/log/clonezilla.log | cut -d'!' -f 1 | grep -c "Program terminated" ) = 0 ]
							then
								printf "[${m_pass}]"
							else
								printf "[${m_fail}]"
								error_counter=$((error_counter+1))
						fi
					else
						printf "[${m_fail}]"
						error_counter=$((error_counter+1))
				fi
				printf " Control de errores en proceso Clonezilla.\n"
				sleep .1
			
				# valida si hay un error y muestra el mensaje correspondiente
				printf "[${m_info}] Errores encontrados = ${error_counter}\n"
				if [ $error_counter != 0 ]
					then
						image_counter=$((image_counter+1))
						gnome-terminal --full-screen --hide-menubar --profile texto-error --wait -- ./sys/error-volcado.sh $image_counter
					else
						gnome-terminal --full-screen --hide-menubar --profile texto-ok --wait -- ./sys/volcado-ok.sh $systemDisk
						image_check=true
				fi

			done
	else
		printf "[${m_warn}] Faltan validaciones requeridas: hash_check=$hash_check bios_check=$bios_check\n"
fi
printf "[${m_fail}] \033[5;31mSi está viendo esto es porque algo NO sucedio según lo esperado. Intentando apagar el equipo...\n"

sleep 10
shutdown now