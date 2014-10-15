#!/bin/bash --login

copy_deployment_files() {

	echo "COPY DEPLOYMENT MANIFEST"
	/usr/bin/expect -c "
		set timeout -1

		spawn scp tempest@$OPS_MANAGER_HOST:/var/tempest/workspaces/default/deployments/*.yml $DEPLOYMENT_DIR

		expect "*password:"

		send $OPS_MGR_SSH_PASSWORD\r
	
		expect "success" { interact }
		
		exit
	"
	
	echo "COPY MICRO-BOSH DEPLOYMENT MANIFEST"
	/usr/bin/expect -c "
		set timeout -1

		spawn scp tempest@$OPS_MANAGER_HOST:/var/tempest/workspaces/default/deployments/micro/*.yml $DEPLOYMENT_DIR

		expect "*password:"

		send $OPS_MGR_SSH_PASSWORD\r
	
		expect "success" { interact }
		
		exit
	"
}

export_Encryption_key() {
	echo "EXPORT DB ENCRYPTION KEY"
	grep -E 'db_encryption_key' $DEPLOYMENT_DIR/cf-*.yml | cut -d ':' -f 2 | sort -u > $WORK_DIR/cc_db_encryption_key.txt
}

export_installation_settings() {
	CONNECTION_URL=https://$OPS_MANAGER_HOST/api/installation_settings
	
	echo "EXPORT INSTALLATION FILES FROM " $CONNECTION_URL
	
	curl "$CONNECTION_URL" -X GET -u $OPS_MGR_ADMIN_USERNAME:$OPS_MGR_ADMIN_PASSWORD --insecure -k -o $WORK_DIR/installation.yml
}

fetch_bosh_connection_parameters() {
	echo "GATHER BOSH DIRECTOR CONNECTION PARAMETERS"
	
	output=`sh appassembler/bin/app $WORK_DIR/installation.yml microbosh director director`
	
	export DIRECTOR_USERNAME=`echo $output | cut -d '|' -f 1`
	export DIRECTOR_PASSWORD=`echo $output | cut -d '|' -f 2`
	export BOSH_DIRECTOR_IP=`echo $output | cut -d '|' -f 3`

}

bosh_login() {
	echo "BOSH LOGIN"
	rn -rf ~/.bosh_config
	
	bosh target $BOSH_DIRECTOR_IP << EOF
	$DIRECTOR_USERNAME
	$DIRECTOR_PASSWORD
EOF

	bosh login $DIRECTOR_USERNAME $DIRECTOR_PASSWORD
}

verify_deployment_backedUp() {
	echo "VERIFY CF DEPLOYMENT MANIFEST"
	export CF_DEPLOYMENT_NAME=`bosh deployments | grep "cf-" | cut -d '|' -f 2 | tr -s ' ' | grep "cf-" | tr -d ' '`
	export CF_DEPLOYMENT_FILE_NAME=$CF_DEPLOYMENT_NAME.yml
	
	echo "FILES LOOKING FOR $CF_DEPLOYMENT_NAME $CF_DEPLOYMENT_FILE_NAME"
	
	if [ -f $WORK_DIR/$CF_DEPLOYMENT_FILE_NAME ]; then
		echo "file exists"
	else
		echo "file does not exist"
		bosh download manifest $CF_DEPLOYMENT_NAME $WORK_DIR/$CF_DEPLOYMENT_FILE_NAME
	fi	
}

bosh_status() {
	echo "EXECUTE BOSH STATUS"
	bosh status > $WORK_DIR/bosh_status.txt
	export BOSH_UUID=`grep UUID $WORK_DIR/bosh_status.txt | cut -d 'D' -f 2 | tr -d ' ' | sort -u`
	
	export UUID_EXISTS=`grep -Fxq $BOSH_UUID $WORK_DIR/$CF_DEPLOYMENT_FILE_NAME`
	if [[ -z $UUID_EXISTS ]]; then
		echo "UUID Matches"
	else
		echo "UUID Mismatch"
		exit 1
	fi	
	
	rm -rf $WORK_DIR/bosh_status.txt
}

set_bosh_deployment() {
    echo "SET THE BOSH DEPLOYMENT"
	bosh deployment $WORK_DIR/$CF_DEPLOYMENT_FILE_NAME
}

export_cc_db() {
	echo "EXPORT CCDB"
	
	export_db cf ccdb admin 2544 "ccdb" $DATABASE_DIR/ccdb.sql

}

export_uaadb() {
	echo "EXPORT UAA-DB"
	
	export_db cf uaadb root 2544 "uaa" $DATABASE_DIR/uaadb.sql
	
}

export_consoledb() {
	echo "EXPORT CONSOLE-DB"
	
	export_db cf consoledb root 2544 "console" $DATABASE_DIR/console.sql
}

export_db() {
	output=`sh appassembler/bin/app $WORK_DIR/installation.yml $1 $2 $3`
	
	export USERNAME=`echo $output | cut -d '|' -f 1`
	export PGPASSWORD=`echo $output | cut -d '|' -f 2`
	export IP=`echo $output | cut -d '|' -f 3`
	
	export PORT=$4
	export DB=$5
	export DB_FILE=$6

	pg_dump -h $IP -U $USERNAME -p $4 $5 > $6

}

export_nfs_server() {
	echo "EXPORT NFS-SERVER"
	
	output=`sh appassembler/bin/app $WORK_DIR/installation.yml cf nfs_server vcap`
	
	export NFS_SERVER_USER=`echo $output | cut -d '|' -f 1`
	export NFS_SERVER_PASSWORD=`echo $output | cut -d '|' -f 2`
	export NFS_IP=`echo $output | cut -d '|' -f 3`
	
	/usr/bin/expect -c "
		set timeout -1
	
		spawn scp -rp $NFS_SERVER_USER@$NFS_IP:/var/vcap/store/shared $NFS_DIR
	
		expect "*assword"
	
		send $NFS_SERVER_PASSWORD\r
	
		expect eof
	"
}

export_installation() {
	CONNECTION_URL=https://$OPS_MANAGER_HOST/api/installation_asset_collection
	
	echo "EXPORT INSTALLATION FILES FROM " $CONNECTION_URL
	
	curl "$CONNECTION_URL" -X GET -u $OPS_MGR_ADMIN_USERNAME:$OPS_MGR_ADMIN_PASSWORD --insecure -k -o $WORK_DIR/installation.zip
}

execute() {
	copy_deployment_files
	export_Encryption_key
	export_installation_settings
	fetch_bosh_connection_parameters
	bosh_login
	verify_deployment_backedUp
	bosh_status
	set_bosh_deployment
	export_cc_db
	export_uaadb
	export_consoledb
	export_nfs_server
	export_installation
}

if [ $# -ne 5 ]; then
	echo "Usage: ./backup_script.sh <OPS MGR HOST or IP> <SSH PASSWORD> <Admin USER> <ADMIN PASSWORD> <OUTPUT DIR>"
	exit 1
fi

export DATE=`date +%Y_%m_%d`
export OPS_MANAGER_HOST=$1
export OPS_MGR_SSH_PASSWORD=$2
export OPS_MGR_ADMIN_USERNAME=$3
export OPS_MGR_ADMIN_PASSWORD=$4

export WORK_DIR=$5/backup-$DATE
export NFS_DIR=$WORK_DIR/nfs_share
export DEPLOYMENT_DIR=$WORK_DIR/deployments
export DATABASE_DIR=$WORK_DIR/database

mkdir -p $WORK_DIR
mkdir -p $NFS_DIR
mkdir -p $DEPLOYMENT_DIR
mkdir -p $DATABASE_DIR

execute

echo "$DATE - BACKUP SUCCESSFUL"