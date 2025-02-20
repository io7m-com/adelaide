#!/bin/sh

ARTEMIS_HOME="/artemis"
ARTEMIS_INSTANCE="/data"
ARTEMIS_INSTANCE_ETC="${ARTEMIS_INSTANCE}/etc"
ARTEMIS_INSTANCE_DATA="${ARTEMIS_INSTANCE}/data"
ARTEMIS_INSTANCE_TMP="${ARTEMIS_INSTANCE}/tmp"
ARTEMIS_LOGIN_CONFIG="${ARTEMIS_INSTANCE_ETC}/login.config"
ARTEMIS_CLASSPATH="$ARTEMIS_HOME/lib/artemis-boot.jar"
ARTEMIS_LIBRARY_PATH="${ARTEMIS_HOME}/bin/lib/linux-$(uname -m)"
ARTEMIS_JOLOKIA_POLICY="file:${ARTEMIS_INSTANCE_ETC}/jolokia-access.xml"

mkdir -p "${ARTEMIS_INSTANCE}/data"
mkdir -p "${ARTEMIS_INSTANCE}/etc"
mkdir -p "${ARTEMIS_INSTANCE}/lib"
mkdir -p "${ARTEMIS_INSTANCE}/log"
mkdir -p "${ARTEMIS_INSTANCE}/tmp"

cat <<EOF
ARTEMIS_CLASSPATH:      ${ARTEMIS_CLASSPATH}
ARTEMIS_HOME:           ${ARTEMIS_HOME}
ARTEMIS_INSTANCE:       ${ARTEMIS_INSTANCE}
ARTEMIS_INSTANCE_DATA:  ${ARTEMIS_INSTANCE_DATA}
ARTEMIS_INSTANCE_ETC:   ${ARTEMIS_INSTANCE_ETC}
ARTEMIS_JOLOKIA_POLICY: ${ARTEMIS_JOLOKIA_POLICY}
ARTEMIS_LIBRARY_PATH:   ${ARTEMIS_LIBRARY_PATH}
ARTEMIS_LOGIN_CONFIG:   ${ARTEMIS_LOGIN_CONFIG}
ARTEMIS_PROPERTIES:     ${ARTEMIS_PROPERTIES}
EOF

exec /opt/java/openjdk/bin/java \
  -Djava.security.manager=allow \
  -Djava.security.auth.login.config="${ARTEMIS_LOGIN_CONFIG}" \
  ${ARTEMIS_PROPERTIES} \
  -classpath "${ARTEMIS_CLASSPATH}" \
  -Dartemis.home="${ARTEMIS_HOME}" \
  -Dartemis.instance="${ARTEMIS_INSTANCE}" \
  -Djava.library.path="${ARTEMIS_LIBRARY_PATH}" \
  -Djava.io.tmpdir="${ARTEMIS_INSTANCE_TMP}" \
  -Ddata.dir="${ARTEMIS_INSTANCE_DATA}" \
  -Dhawtio.realm=activemq \
  -Dhawtio.offline=true \
  -Dhawtio.rolePrincipalClasses=org.apache.activemq.artemis.spi.core.security.jaas.RolePrincipal \
  -Djolokia.policyLocation="${ARTEMIS_JOLOKIA_POLICY}" \
  -Dartemis.instance.etc="${ARTEMIS_INSTANCE_ETC}" \
  org.apache.activemq.artemis.boot.Artemis run
