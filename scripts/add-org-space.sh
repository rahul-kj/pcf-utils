#!/bin/bash

if [ $# -lt 4 ]; then
  echo "Usage: ./add-org-spaces.sh <api url> <admin username> <admin password> <environment>"
  exit 1
fi

if [[ $4 = "dev" || $4 = "devdmz" ]]; then
  cf api --skip-ssl-validation $1
  cf login -u $2 -p $3

  cf co DEVELOPMENT
  cf co INTEGRATION
  cf target DEVELOPMENT
  cf create-space development -o DEVELOPMENT
  cf create-space integration -o INTEGRATION

  cf logout
elif [[ $4 = "test" || $4 = "testdmz" ]]; then
  cf api --skip-ssl-validation $1
  cf login -u $2 -p $3

  cf co TEST
  cf create-space test -o TEST

  cf logout
else
  echo "Unsupported platform"
  exit 1
fi
