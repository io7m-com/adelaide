#!/bin/sh

if [ $# -ne 4 ]
then
  echo "usage: user password broker-name acceptor-name" 1>&2
  exit 1
fi

ARTEMIS_USER="$1"
shift
ARTEMIS_PASSWORD="$1"
shift
ARTEMIS_BROKER="$1"
shift
ARTEMIS_ACCEPTOR="$1"
shift

(cat <<EOF
{
  "type":      "exec",
  "mbean":     "org.apache.activemq.artemis:broker=\"${ARTEMIS_BROKER}\",component=acceptors,name=\"${ARTEMIS_ACCEPTOR}\"",
  "operation": "reload"
}
EOF
) | curl \
  -H "Origin: http://localhost" \
  --user "${ARTEMIS_USER}:${ARTEMIS_PASSWORD}" \
  --header "Content-Type: application/json" \
  --data @- \
  --request POST \
  http://localhost:8161/console/jolokia/exec
