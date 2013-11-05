#!/bin/sh
#
# This script installs and configures the Serf agent that runs on
# every node. As with the other scripts, this should probably be done with
# formal configuration management, but a shell script is simple as well.
#
# The SERF_ROLE environmental variable must be passed into this script
# in order to set the role of the machine. This should be either "manage" or
# "web" or "db".
#
set -e

if [ "${SERF_ROLE}" == "" ]; then
  echo "please set \$SERF_ROLE (example: export SERF_ROLE=manage)"
  exit 0
fi

sudo yum install -y unzip facter

ETH1_ADDR=`facter ipaddress_eth1` 

# Download and install Serf
until wget -O serf.zip https://dl.bintray.com/mitchellh/serf/0.2.0_linux_amd64.zip; do
  sleep 1
done
unzip serf.zip
sudo mv serf /usr/local/bin/serf
rm serf.zip

# Setup serf-munin.sh
if [ ! -d /etc/munin/conf.d/ ];then
  mkdir -p /etc/munin/conf.d/
fi

chmod 755 serf-munin.sh
cp serf-munin.sh /usr/local/bin/serf-munin.sh

# Configure the agent
cat <<EOF >/tmp/agent.conf
description "Serf agent"

start on runlevel [2345]
stop on runlevel [!2345]

exec /usr/local/bin/serf agent \\
  -event-handler="/usr/local/bin/serf-munin.sh" \\
  -bind=${ETH1_ADDR} \\
  -role=${SERF_ROLE} >>/var/log/serf.log 2>&1
EOF
sudo mv /tmp/agent.conf /etc/init/serf.conf

# Start the agent!
sudo start serf
