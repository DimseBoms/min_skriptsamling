#!/bin/bash

# Et skript som oppdaterer pcloud-cli og starter den hvis ønskelig.
#
# Dmitriy Safiullin

while true; do

read -p "Ønsker du å oppdatere pCloud-Klienten? (j/n) " jn

case $jn in
	[jJ] ) echo ok, oppdaterer klienten...;
	       killall pcloudcc
           cd /home/dmitriy/Applikasjoner/pcloud-cli/
           git pull
           cd ./console-client/pCloudCC/
           cd lib/pclsync/
           make clean
           make fs
           cd ../mbedtls/
           cmake .
           make clean
           make
           cd ../..
           cmake .
           make
           sudo make install
           sudo ldconfig
		break;;
	[nN] ) echo ok, oppdaterer ikke klienten...;
		break;;
	* ) echo uforventet svar;;
esac

done

while true; do

read -p "Ønsker du å starte pCloud-Klienten? (j/n) " jn

case $jn in
	[jJ] ) echo ok, starter klienten;
	       killall pcloudcc
           pcloudcc -u dmisaf@outlook.com -p -d
		break;;
	[nN] ) echo avslutter...;
		exit;;
	* ) echo uforventet svar;;
esac

done
