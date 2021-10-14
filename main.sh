#! /bin/bash

clear
m_pass='\033[1;32m PASS \033[0m' # ${m_pass}
m_fail='\033[1;31m FAIL \033[0m' # ${m_fail}
m_warn='\033[1;33m WARN \033[0m' # ${m_warn}
m_info='\033[1;37m INFO \033[0m' # ${m_info}

# presentación
printf "\033[1;36m" && figlet -f small IMAGE - DEPLOYER && printf "\033[0m \n"

# directorio de trabajo
SCRIPT=$(readlink -f $0);
dir_base=`dirname $SCRIPT`;

# muestra la version de la herramienta
version=$(cat $dir_base/.git/refs/heads/master)
printf "[${m_info}] tool_version=${version}\n"

# monta /home/partimag
printf "[${m_info}] Montando particiones de origen.\n"
systemDisk=$(lsblk -no pkname $(findmnt -n / | awk '{ print $2 }'))
sudo umount /dev/${systemDisk}3 > /dev/null 2>&1
sudo mount /dev/${systemDisk}3 /home/partimag

sleep .5

# chequea que nombre tiene el disco targetDisk
targetDisk=$(cat /home/partimag/image.target.cfg)

printf "[${m_info}] systemDisk=${systemDisk} targetDisk=${targetDisk}.\n"
printf "[${m_warn}] Validación configuración de discos"

if [ $systemDisk = $targetDisk ]
	then
		printf "${m_fail}\n"
        printf "[${m_info}] Image deploy canceled due SKU unmatching. Press any key to system shutdown.\n"
        read -s -n 1 -p "" null
        shutdown now
    else
		printf "${m_pass}\n"
fi

sleep .5

# correccion de nombre para discos nvme
if [ $targetDisk == "nvme0n1" ]
    then
        targetDiskPartition1=nvme0n1p1
    else
        targetDiskPartition1="$targetDisk"1
fi
printf "[${m_info}] Se aplicó corrección de nombre a la partición $targetDiskPartition3.\n"

sleep .5

# monta particiones de destino
printf "[${m_info}] Montando particiones de destino.\n"
sudo umount /home/targetDisk > /dev/null 2>&1
sudo mkdir /home/targetDisk > /dev/null 2>&1
sudo mount /dev/${targetDiskPartition1} /home/targetDisk

sleep .5

# chequea que el sku indicado en el disco target coincida con el configurado
if [ -e /home/partimag/image.sku.cfg ]
    then
        imageSkuConfig=$(cat /home/partimag/image.sku.cfg) > /dev/null 2>&1
    else
        imageSkuConfig=config-file-not-found
fi

if [ -e /home/targetDisk/image.sku.cfg ]
    then
        imageSkuDisk=$(cat /home/targetDisk/image.sku.cfg) > /dev/null 2>&1
    else
        imageSkuDisk=disk-file-not-found
fi

printf "[${m_info}] imageSkuConfig=${imageSkuConfig} imageSkuDisk=${imageSkuDisk}.\n"
printf "[${m_warn}] Validación de SKU "
sku_check=false

if [ $imageSkuConfig = $imageSkuDisk ]
	then
		printf "${m_pass}\n"
		sku_check=true
	else
        printf "${m_fail}\n"
        if [ -e /home/partimag/image.sku.force.cfg ]
            then
                printf "[${m_warn}] FORCE SKU PASS OPTION FOUND ALL DATA IN TARGET DISK WILL BE DELETED.\n"
                sleep 10
                sku_check=true
            else
                printf "[${m_info}] Image deploy canceled due SKU unmatching. Press any key to system shutdown.\n"
                read -s -n 1 -p "" null
                shutdown now
        fi
fi

sleep .5

# desmonta el disco donde se encuentra el flag del running
sudo umount /home/targetDisk > /dev/null 2>&1

sleep .5

# valida que la bateria esté conectada
printf "[${m_warn}] Validación alimentación eléctrica"
power_supply_dir=$(cat $dir_base/config/power.folder.cfg)
power_supply=$(cat $power_supply_dir) 
if [ $power_supply != 1 ]
    then
        printf "${m_fail}\n"
        printf "\033[5;31m" && figlet -f small FALTA CARGADOR && printf "\033[0m \n"
        while [ $bateria != 1 ]
        do
            sleep 1
            bateria=$(cat /sys/class/power_supply/ADP1/online)
        done
    else
        printf "${m_pass}\n"
fi

# main process
if [ $sku_check == "true" ]
	then
			
		# mensaje volcado de imagen
		printf "[${m_info}] Iniciando volcado de imagen...\n"

        # elimina registro de volcado anterior si existe
        if [ -e /var/log/clonezilla.log ]
            then
                sudo rm -f /var/log/clonezilla.log
                printf "[${m_info}] Se limpio el registro de clonados anteriores.\n"
        fi

        # volcado de imagen
        image_name=$(cat /home/partimag/image.folder.cfg)
        gnome-terminal --full-screen --hide-menubar --profile Default --wait -- $dir_base/makeclone.sh $image_name $targetDisk
        printf "[${m_info}] Volcado de imágen finalizado.\n"

        #validaciones
        printf "[${m_info}] Iniciando validaciones...\n"
        error_counter=3

            # validación de particiones
            printf "[${m_warn}] Particiones en disco de destino"
            if [ $(grep -c $targetDisk /proc/partitions) = 6 ]
                then
                    printf "${m_pass}\n"
                    error_counter=$((error_counter-1))
                else
                    printf "${m_fail}]\n"
                    error_counter=$((error_counter+1))
            fi
            
            sleep .5

            # validafion finalizacion del proceso Clonezilla
            printf "[${m_warn}] Finalización del proceso Clonezilla"
            if [ -e /var/log/clonezilla.log ]
                then
                    if [ $(cat /var/log/clonezilla.log | grep -c "Ending /usr/sbin/ocs-sr at" ) = 1 ]
                        then
                            printf "${m_pass}\n"
                            error_counter=$((error_counter-1))
                        else
                            printf "${m_fail}\n"
                            error_counter=$((error_counter+1))
                    fi
                else
                    printf "[${m_fail}]"
                    error_counter=$((error_counter+1))
            fi
            
            sleep .5

            # validafion errores del proceso Clonezilla
            printf "[${m_warn}] Control de errores en proceso Clonezilla"
            if [ -e /var/log/clonezilla.log ]
                then
                    if [ $(tail -1 /var/log/clonezilla.log | cut -d'!' -f 1 | grep -c "Program terminated" ) = 0 ]
                        then
                            printf "${m_pass}\n"
                            error_counter=$((error_counter-1))
                        else
                            printf "${m_fail}\n"
                            error_counter=$((error_counter+1))
                    fi
                else
                    printf "[${m_fail}]"
                    error_counter=$((error_counter+1))
            fi
            
            sleep .5
    
        # valida si hay un error y muestra el mensaje correspondiente
        printf "[${m_info}] Validaciones no superadas = ${error_counter}.\n"
        if [ $error_counter != 0 ]
            then
                printf "\n\033[5;31m" && figlet -f big F A I L && printf "\033[0m \n"
            else
                printf "\n\033[5;32m" && figlet -f big P A S S && printf "\033[0m \n"
        fi

        #apagado
        printf "[${m_info}] Presione una tecla para apagar el equipo...\n"
        read -s -n 1 -p "" null
        shutdown now

	else
		printf "[${m_warn}] Faltan validaciones requeridas.\n"
fi

printf "[${m_warn}] Si está viendo esto. Presione una tecla para apagar el equipo...\n"

#apagado
read -s -n 1 -p "" null
shutdown now
