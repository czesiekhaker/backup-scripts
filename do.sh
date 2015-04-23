#!/bin/bash

CURRENT_HOST=`hostname -s`
REMOTE_HOST="backup-storage"
REMOTE_PATH="/mnt/store/panoptykon"
TIMESTAMP=`date '+%Y%m%d%H%M%S'`
RSYNC_OPTS="-a --delete"

MYSQL_USER="root"
MYSQL_PASS="topsecret"

# dump MySQL DBs
mysqldump --all-databases -u ${MYSQL_USER} -p${MYSQL_PASS} | bzip2 > /var/backups/mysql/${TIMESTAMP}.sql.bz2
rsync -a /var/backups/mysql/ ${REMOTE_HOST}:${REMOTE_PATH}/${CURRENT_HOST}_mysql/

# rsync /home (w/out versioning - much data, wow)
rsync ${RSYNC_OPTS} /home/ ${REMOTE_HOST}:${REMOTE_PATH}/${CURRENT_HOST}_home/

# fs sync
listDirPaths="/etc /var/www /opt/openproject /home/openproject"
for DIR_PATH in $listDirPaths
do
	ssh backup-storage mkdir -p ${REMOTE_PATH}/${CURRENT_HOST}_fs/current${DIR_PATH}
	rsync ${RSYNC_OPTS} ${DIR_PATH}/ ${REMOTE_HOST}:${REMOTE_PATH}/${CURRENT_HOST}_fs/current${DIR_PATH}/
done
ssh backup-storage "cp -rl ${REMOTE_PATH}/${CURRENT_HOST}_fs/current ${REMOTE_PATH}/${CURRENT_HOST}_fs/${TIMESTAMP}"

# df
echo "== DF =="
df -h / /home /var/www

echo
echo " / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \_"
echo "/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \__"
echo "\ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / _"
echo " \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ / "
echo " / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \_"
echo "/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \__"
echo "\ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / __ \ \__/ / _"
echo " \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ /  \ \____/ / "
