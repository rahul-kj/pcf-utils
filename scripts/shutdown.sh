#!/bin/bash

export BOSH_DIRECTOR_IP=$1
export DIRECTOR_USERNAME=$2
export DIRECTOR_PASSWORD=$3

bosh target $BOSH_DIRECTOR_IP << EOF
$DIRECTOR_USERNAME
$DIRECTOR_PASSWORD
EOF

bosh login $DIRECTOR_USERNAME $DIRECTOR_PASSWORD

bosh vms --details >> vms.txt

bosh deployments >> deployments.txt
