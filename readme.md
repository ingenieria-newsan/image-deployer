[![Generic badge](https://img.shields.io/badge/STATE-BETA-54AEFF.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/UPDATED-10/10/2021-54AEFF.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/CURRENT_VERSION-V1.0-54AEFF.svg)](https://shields.io/)

# Sistema Automatico de Volvado de Imagen
Realiza el volcado de imagen automaticamente.

## Compativilidad asegurada
- ASUS X515EA
- NOBLEX SF20GM7
- SEMMAX C116EP-G4S-01

## Dependencias
- gnome-terminal
- clonezilla
- figlet

## Instalación
Siga los siguientes pasos para instalar el sistema:

1. Clone el repositorio en `/home`.
2. Asigne permiso de ejecución: `sudo chmod +x /home/image-deployer/install.sh`.
3. Ejecute `sudo /home/image-deployer/install.sh`.

## Configuración
Modifique los siguiente archivos para configurar la herramienta:

- `/home/partimag/image.target.cfg` establece el nombre del dispositivo de destino para la imagen.
- `/home/partimag/congig/image.sku.cfg` establece el SKU que debe conincidir con el indicado en `C:\image.sku.cfg` en el raiz del disco de destino.
- `/home/partimag/congig/image.folder.cfg` establece el nombre de la imagen que se grabará.
- Cree el archivo `/home/partimag/image.sku.force.cfg` para forzar el despliegue de la imagen aunque no se pueda validad el SKU.
