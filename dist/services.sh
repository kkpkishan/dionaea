#!/bin/bash

# Start the first process
sed -i -e 's/wazuh-user/'"$user"'/g' -e 's/wazuh-password/'"$password"'/g' -e 's/IP/'"$ip"'/g' /usr/bin/update.sh &
sed -i -e 's/wazuh-user/'"$user"'/g' -e 's/wazuh-password/'"$password"'/g' -e 's/IP/'"$ip"'/g' /etc/logstash/conf.d/logstash.conf &
##
/opt/dionaea/bin/dionaea  -u dionaea -g dionaea -c /opt/dionaea/etc/dionaea/dionaea.cfg & 
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start my_first_process: $status"
  exit $status
fi

# Start the second process
update.sh && exec /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf --config.reload.automatic --java-execution 
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start my_second_process: $status"
  exit $status
fi



while sleep 60; do
  ps aux |grep my_first_process |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep my_second_process |grep -q -v grep
  PROCESS_2_STATUS=$?
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
