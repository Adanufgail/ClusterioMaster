#!/bin/sh
if [ ! -f databases/users.json ]
then
	sed -i '14d' config-master.json
	npx clusteriomaster bootstrap create-admin $ADMIN
	npx clusteriomaster bootstrap generate-user-token $ADMIN > $ADMIN.txt

fi
#./mod_updater.py -u $ADMIN -t $TOKEN -m sharedMods/ --fact-path ./factorio/bin/x64/factorio --update
./run-master.sh
