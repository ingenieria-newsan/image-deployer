#! /bin/bash

# instalar dependencias
apt-get update
sudo apt-get install figlet
sudo apt-get install clonezilla
sudo apt-get install gnome-terminal
sudo apt-get install qrencode

# impotar perfiles de gnome-terminal
dconf load /org/gnome/terminal/legacy/profiles:/ < ./res/gnome-terminal-profiles.dconf
