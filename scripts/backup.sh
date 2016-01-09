#!/bin/bash --login

. common.sh

validate_software() {
	echo "VALIDATE MANDATORY TOOLS"

	INSTALLED_BOSH=`which bosh`
	if [ -z "$INSTALLED_BOSH" ]; then
		echo "BOSH CLI not installed"
		exit 1
	fi

	INSTALLED_PG_DUMP=`which pg_dump`
	if [ -z "$INSTALLED_PG_DUMP" ]; then
		echo "pg_dump utility not installed"
		exit 1
	fi

	INSTALLED_JAVA=`which java`
	if [ -z "$INSTALLED_JAVA" ]; then
		echo "Java JRE is missing"
		exit 1
	fi

	INSTALLED_MYSQL=`which mysqldump`
	if [ -z "$INSTALLED_MYSQL" ]; then
		echo "mysqldump utility is missing"
		exit 1
	fi
}

verify_deployment_backedUp() {
	echo "VERIFY CF DEPLOYMENT MANIFEST"
	export CF_DEPLOYMENT_NAME=`bosh deployments | grep "cf-" | cut -d '|' -f 2 | tr -s ' ' | grep "cf-" | tr -d ' ' | head -1`
	export CF_DEPLOYMENT_FILE_NAME=$CF_DEPLOYMENT_NAME.yml

	echo "FILES LOOKING FOR $CF_DEPLOYMENT_NAME $CF_DEPLOYMENT_FILE_NAME"

	if [ -f $WORK_DIR/$CF_DEPLOYMENT_FILE_NAME ]; then
		echo "file exists"
	else
		echo "file does not exist"
		bosh download manifest $CF_DEPLOYMENT_NAME $WORK_DIR/$CF_DEPLOYMENT_FILE_NAME
	fi
}

export_Encryption_key() {
	echo "EXPORT DB ENCRYPTION KEY"
	grep -E 'db_encryption_key' $WORK_DIR/$CF_DEPLOYMENT_FILE_NAME | cut -d ':' -f 2 | sort -u > $WORK_DIR/cc_db_encryption_key.txt
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

export_bosh_vms() {
    echo "EXPORT BOSH VMS"
	OUTPUT=`bosh vms | grep "cloud_controller-*" | cut -d '|' -f 2 | tr -d ' '`
	echo $OUTPUT > $WORK_DIR/bosh-vms.txt
}

stop_cloud_controller() {
	echo "STOPPING CLOUD CONTROLLER"
	OUTPUT=`cat $WORK_DIR/bosh-vms.txt`

	for word in $OUTPUT
	do
		JOB=`echo $word | cut -d '/' -f 1`
		INDEX=`echo $word | cut -d '/' -f 2`

		bosh -n stop $JOB $INDEX --force
	done
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

		expect {
			-re ".*Are.*.*yes.*no.*" {
				send yes\r ;
				exp_continue
			}

			"*?assword:*" {
				send $NFS_SERVER_PASSWORD\r
			}
		}
		expect {
			"*?assword:*" {
				send $NFS_SERVER_PASSWORD\r
				interact
			}
		}

		exit
	"
}

start_cloud_controller() {
	echo "STARTING CLOUD CONTROLLER"
	OUTPUT=`cat $WORK_DIR/bosh-vms.txt`

	for word in $OUTPUT
	do
		JOB=`echo $word | cut -d '/' -f 1`
		INDEX=`echo $word | cut -d '/' -f 2`

		bosh -n start $JOB $INDEX --force
	done

}

export_mysqldb() {
	output=`sh appassembler/bin/app $WORK_DIR/installation.yml cf mysql root`

	export USERNAME=`echo $output | cut -d '|' -f 1`
	export PASSWORD=`echo $output | cut -d '|' -f 2`
	export IP=`echo $output | cut -d '|' -f 3`

	DB_FILE=$DATABASE_DIR/user_databases.sql

	echo '[mysqldump]
user='$USERNAME'
password='$PASSWORD > ~/.my.cnf

	echo "EXPORT MySQL DB"

	mysqldump -u $USERNAME -h $IP --all-databases > $DB_FILE

}

export_installation() {
	if [[ "Y" = "$COMPLETE_BACKUP" || "y" = "$COMPLETE_BACKUP" ]]; then
		CONNECTION_URL=https://$OPS_MANAGER_HOST/api/installation_asset_collection

		echo "EXPORT INSTALLATION FILES FROM " $CONNECTION_URL

		curl "$CONNECTION_URL" -X GET -u $OPS_MGR_ADMIN_USERNAME:$OPS_MGR_ADMIN_PASSWORD --insecure -k -o $WORK_DIR/installation.zip
	fi
}

zip_all_together() {
	cd $WORK_DIR
	cd ..
	cmd=`tar -zcvf $BACKUP_DIR_NAME.tar.gz $BACKUP_DIR_NAME`
	echo "Compressed the backup into $BACKUP_DIR_NAME.tar.gz"
	cmd=`rm -rf $WORK_DIR`
}

execute() {
	validate_software
	copy_deployment_files
	export_installation_settings
	fetch_bosh_connection_parameters
	bosh_login
	verify_deployment_backedUp
	export_Encryption_key
	bosh_status
	set_bosh_deployment
	export_bosh_vms
	stop_cloud_controller
	export_cc_db
	export_uaadb
	export_consoledb
	export_nfs_server
	export_mysqldb
	start_cloud_controller
	export_installation
	zip_all_together
}

if [[ ! -f "./environment.sh" ]]; then

	if [ $# -lt 6 ]; then
		echo "Usage: ./backup_script.sh <OPS MGR HOST or IP> <SSH USER> <SSH PASSWORD> <OPS MGR ADMIN USER> <OPS MGR ADMIN PASSWORD> <OUTPUT DIR> <COMPLETE BACKUP>"
		printf "\t %s \t\t\t %s \n" "OPS MGR HOST or IP:" "OPS Manager Host or IP"
		printf "\t %s \t\t\t\t %s \n" "SSH USER:" "OPS Manager SSH Username"
		printf "\t %s \t\t\t\t %s \n" "SSH PASSWORD:" "OPS Manager SSH Password"
		printf "\t %s \t\t\t %s \n" "OPS MGR ADMIN USER:" "OPS Manager Admin Username"
		printf "\t %s \t\t %s \n" "OPS MGR ADMIN PASSWORD:" "OPS Manager Admin Password"
		printf "\t %s \t\t\t\t %s \n" "OUTPUT DIR:" "Backup Directory"
		printf "\t %s \t\t\t %s \n" "COMPLETE BACKUP:" "Specify 'Y' for complete backup"
		exit 1
	fi

	export DATE=`date +%Y_%m_%d`
	export OPS_MANAGER_HOST=$1
	export SSH_USER=$2
	export OPS_MGR_SSH_PASSWORD=$3
	export OPS_MGR_ADMIN_USERNAME=$4
	export OPS_MGR_ADMIN_PASSWORD=$5
	export BACKUP_DIR_NAME=Backup_$DATE
	export WORK_DIR=$6/$BACKUP_DIR_NAME
	export NFS_DIR=$WORK_DIR/nfs_share
	export DEPLOYMENT_DIR=$WORK_DIR/deployments
	export DATABASE_DIR=$WORK_DIR/database

	export COMPLETE_BACKUP=$7

else
	source "./environment.sh"
fi

mkdir -p $WORK_DIR
mkdir -p $NFS_DIR
mkdir -p $DEPLOYMENT_DIR
mkdir -p $DATABASE_DIR

execute

echo "$DATE - BACKUP SUCCESSFUL"
