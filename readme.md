[![Generic badge](https://img.shields.io/badge/STATE-ALPHA-54AEFF.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/UPDATED-10/10/2021-54AEFF.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/CURRENT_VERSION-V0.0-54AEFF.svg)](https://shields.io/)

# Sistema Automatico de Volvado de Imagen
Realiza el volcado de imagen automaticamente.

## Compativilidad asegurada
- ASUS X515EA

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

- `./congig/image.target` establece el nombre del dispositivo de destino para la imagen.
- `./congig/image.sku` establece el SKU que debe conincidir con el indicado en `image.sku` en el raiz del disco de destino.
- `./congig/image.folder` establece el nombre de la imagen que se grabará.
