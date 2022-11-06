#!/bin/bash

# Ser etter oppdateringer på GitHub for så å oppdatere prosjektet automatisk
# dersom oppdateringer blir funnet


GIT_REPO="https://github.com/DimseBoms/prisjeger"
USER_HOME="/home/dmitriy"
GIT_DIRECTORY="${USER_HOME}/prisjeger"
BACKUP_DIRECTORY="${USER_HOME}/backup"
UPDATE_INTERVAL=10


function oppdaterProsjekt() {
    sudo systemctl stop prisjeger-backend.service
    echo "Henter nyeste oppdateringer"
    rm -rf $BACKUP_DIRECTORY
    cp -rf $GIT_DIRECTORY $BACKUP_DIRECTORY
    cd $GIT_DIRECTORY
    git stash --include-untracked
    git reset --hard
    git clean -fd
    git config pull.rebase true
    git pull
    cd "${GIT_DIRECTORY}/backend"
    npm i
    # cd "${GIT_DIRECTORY}/frontend"
    # npm i
    sudo systemctl restart prisjeger-backend.service
    sudo chown -R dmitriy:dmitriy $GIT_DIRECTORY
}


# Sjekker etter nye Git oppdateringer
while true
do
    if [ -d "${GIT_DIRECTORY}" ]; then
        # echo "${GIT_DIRECTORY} finnes"
        cd $GIT_DIRECTORY
        git fetch origin
            reslog=$(git log HEAD..origin/main --oneline)
            if [[ "${reslog}" != "" ]] ; then
                    echo "Git oppdatering funnet."
                    oppdaterProsjekt
            fi
    else
        echo "${GIT_DIRECTORY} finnes ikke. Kloner nytt prosjekt"
        cd $USER_HOME
        git clone $GIT_REPO
        cd "${GIT_DIRECTORY}/backend"
        npm i
        # cd "${GIT_DIRECTORY}/frontend"
        # npm i
        sudo chown -R dmitriy:dmitriy $GIT_DIRECTORY
        systemctl restart prisjeger-backend.service
    fi
    sleep $UPDATE_INTERVAL
d
