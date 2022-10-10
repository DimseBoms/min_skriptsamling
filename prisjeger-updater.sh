#!/bin/bash
 
# Ser etter oppdateringer på GitHub for så å oppdatere prosjektet automatisk
# dersom oppdateringer blir funnet


GIT_REPO="https://github.com/DimseBoms/prisjeger"
GIT_DIRECTORY="$HOME/prisjeger"
BACKUP_DIRECTORY="$HOME/backup"
UPDATE_INTERVAL=10


function oppdaterProsjekt() {
    systemctl stop prisjeger-backend.service
    echo "$GIT_DIRECTORY finnes. Henter nyeste oppdateringer"
    rm -rf $BACKUP_DIRECTORY
    cp -rf $GIT_DIRECTORY $BACKUP_DIRECTORY
    cd $GIT_DIRECTORY
    git stash --include-untracked
    git reset --hard
    git clean -fd
    git config pull.rebase true
    git pull
    systemctl start prisjeger-backend.service
}


# Sjekker etter nye Git oppdateringer
while true
do
    if [ -d "$GIT_DIRECTORY" ]; then
        cd $GIT_DIRECTORY
        git fetch origin
            reslog=$(git log HEAD..origin/main --oneline)
            if [[ "${reslog}" != "" ]] ; then
                    echo "Git oppdatering funnet."
                    oppdaterProsjekt
            else
                    date=`date`
                    echo "Ingen Git oppdateringer funnet. Sist sjekket: ${date}"
            fi
    else
        echo "$GIT_DIRECTORY finnes ikke. Kloner nytt prosjekt"
        mkdir -p $GIT_DIRECTORY
        cd $HOME
        git clone $GIT_REPO
        cd $GIT_DIRECTORY
        systemctl restart prisjeger-backend.service
    fi
    sleep $UPDATE_INTERVAL
done
