#!/bin/bash --login

add_user() {
  echo "ADDING USER"
  CONNECTION_URL=https://$OPS_MANAGER_HOST/api/users

  set -e
  curl "$CONNECTION_URL" -d 'user[user_name]=$USERNAME&user[password]=$PASSWORD&user[password_confirmation]=$PASSWORD' -X POST --insecure -k -u $OPS_MGR_ADMIN_USERNAME:$OPS_MGR_ADMIN_PASSWORD --write-out '%{http_code}\n'

}

execute() {
  add_user
}

if [ $# -lt 5 ]; then
  echo "Usage: ./add_users.sh <OPS MGR HOST or IP> <OPS MGR ADMIN USER> <OPS MGR ADMIN PASSWORD> <USERNAME> <PASSWORD>"
  printf "\t %s \t\t\t %s \n" "OPS MGR HOST or IP:" "OPS Manager Host or IP"
  printf "\t %s \t\t\t %s \n" "OPS MGR ADMIN USER:" "OPS Manager Admin Username"
  printf "\t %s \t\t %s \n" "OPS MGR ADMIN PASSWORD:" "OPS Manager Admin Password"
  printf "\t %s \t\t\t\t %s \n" "USERNAME:" "User to be Added"
  printf "\t %s \t\t\t\t %s \n" "PASSWORD:" "Users password"
  exit 1
fi

export DATE=`date +%Y_%m_%d`
export OPS_MANAGER_HOST=$1
export OPS_MGR_ADMIN_USERNAME=$2
export OPS_MGR_ADMIN_PASSWORD=$3
export USERNAME=$4
export PASSWORD=$5

execute
