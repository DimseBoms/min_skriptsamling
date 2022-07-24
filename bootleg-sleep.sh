#!/bin/bash

# Skriptet ser etter endringer i batteristatus og setter datamaskinen i hvilemodus dersom
# batteriet havner under en bestemt prosent. (5%)

sleep_interval=30 # Antall sekunder skriptet skal vente mellom oppdateringer
battery_percentage_trigger=5 # Batteriprosent som skal trigge søvn

echo "Starting bootleg-sleep with sleep_interval=${sleep_interval} and battery_percentage_trigger=${battery_percentage_trigger}"

while true
do
    acpi_call=$(acpi -b) # Henter batteriinformasjon
    if [[ $acpi_call == *"Discharging"* ]]; then # Sjekker om batteriet utlader ved å lete etter substring
        battery_level=`echo $acpi_call | grep -P -o '[0-9]+(?=%)'` # Henter batteriprosent via regex substring
        if [ $battery_level -le $battery_percentage_trigger ]; then
            echo "Putting system to sleep"
            systemctl suspend # Setter system i hvilemodus
            sleep $sleep_interval
        else
            sleep $sleep_interval
        fi
    else
        sleep $sleep_interval
    fi
done
