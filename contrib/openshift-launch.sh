#!/bin/sh
# Openshift EAP launch script

CONFIG_FILE=$JBOSS_HOME/standalone/configuration/standalone-openshift.xml
LOGGING_FILE=$JBOSS_HOME/standalone/configuration/logging.properties

#For backward compatibility
ADMIN_USERNAME=${ADMIN_USERNAME:-${EAP_ADMIN_USERNAME:-eapadmin}}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-$EAP_ADMIN_PASSWORD}
NODE_NAME=${NODE_NAME:-$EAP_NODE_NAME}
HTTPS_NAME=${HTTPS_NAME:-$EAP_HTTPS_NAME}
HTTPS_PASSWORD=${HTTPS_PASSWORD:-$EAP_HTTPS_PASSWORD}
HTTPS_KEYSTORE_DIR=${HTTPS_KEYSTORE_DIR:-$EAP_HTTPS_KEYSTORE_DIR}
HTTPS_KEYSTORE=${HTTPS_KEYSTORE:-$EAP_HTTPS_KEYSTORE}
SECDOMAIN_USERS_PROPERTIES=${SECDOMAIN_USERS_PROPERTIES:-${EAP_SECDOMAIN_USERS_PROPERTIES:-users.properties}}
SECDOMAIN_ROLES_PROPERTIES=${SECDOMAIN_ROLES_PROPERTIES:-${EAP_SECDOMAIN_ROLES_PROPERTIES:-roles.properties}}
SECDOMAIN_NAME=${SECDOMAIN_NAME:-$EAP_SECDOMAIN_NAME}
SECDOMAIN_PASSWORD_STACKING=${SECDOMAIN_PASSWORD_STACKING:-$EAP_SECDOMAIN_PASSWORD_STACKING}




export BUILD_ID=${HOSTNAME%-*}
export PROJ_NAME=${BUILD_ID%-*}
export INS_ID_TEMP=${HOSTNAME#$PROJ_NAME}
export KHAN_INSTANCE_ID=${HOSTNAME:0:6}-${INS_ID_TEMP:1}

if [ -z "$KHAN_INSTANCE_ID" ]; then
    export KHAN_INSTANCE_ID=${HOSTNAME%-*}
    echo "Hostname unrecognized - using hostname" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_APPLICATION_NAME" ]; then
    export KHAN_APPLICATION_NAME=${HOSTNAME%-*}
    echo "KHAN [apm] Application Name not specified! using - ${KHAN_APPLICATION_NAME}" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_HOST" ]; then
    #export KHAN_HOST=192.168.23.117
    export KHAN_HOST=10.1.0.48
    echo "KHAN [apm] host ip not specified!; Wont work!" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_PORT" ]; then
    export KHAN_PORT=81
    echo "KHAN [apm] host port not specified; Wont work!" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_APDEX_THRESHOLD" ]; then
    export KHAN_APDEX_THRESHOLD=3.0
    echo "KHAN [apm] apdex threshold not specified! using default value - ${KHAN_APDEX_THRESHOLD}" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_TRANSACTION_TRACE_ENABLED" ]; then
    export KHAN_TRANSACTION_TRACE_ENABLED=true
    echo "KHAN [apm] transaction trace enabled not specified! using default value - ${KHAN_TRANSACTION_TRACE_ENABLED}" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_TRANSACTION_TRACE_THRESHOLD" ]; then
    export KHAN_TRANSACTION_TRACE_THRESHOLD=500
    echo "KHAN [apm] transaction trace threshold not specified; using default value - ${KHAN_TRANSACTION_TRACE_THRESHOLD}" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_SQL_CAPTURE_ENABLED" ]; then
    export KHAN_SQL_CAPTURE_ENABLED=true
    echo "KHAN [apm] transaction sql capture not specified; using default value - ${KHAN_SQL_CAPTURE_ENABLED}" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_TRANSACTION_SAMPLING_INTERVAL" ]; then
    export KHAN_TRANSACTION_SAMPLING_INTERVAL=1
    echo "KHAN [apm] transaction sampling interval not specified; using default value - ${KHAN_TRANSACTION_SAMPLING_INTERVAL}" >> /tmp/khan.sti.log
fi

if [ -z "$KHAN_DB_CONN_LEAK_WARNING" ]; then
    export KHAN_DB_CONN_LEAK_WARNING=false
    echo "KHAN [apm] db connection leak warning not specified; using default value - ${KHAN_DB_CONN_LEAK_WARNING}" >> /tmp/khan.sti.log
fi

export JBOSS_LOGMANAGER_DIR="/opt/eap/modules/system/layers/base/.overlays/layer-base-jboss-eap-6.4.13.CP/org/jboss/logmanager/main"
export JBOSS_LOGMANAGER_JAR=`cd "$JBOSS_LOGMANAGER_DIR" && ls -1 *.jar`
#export JBOSS_LOGMANAGER_DIR="/opt/eap/modules/system/layers/base/.overlays/layer-base-jboss-eap-6.4.11.CP/org/jboss/logmanager/main"
#export JBOSS_LOGMANAGER_JAR="jboss-logmanager-1.5.6.Final-redhat-1.jar"

# uncomment tO override memory settings
#export JAVA_OPTS_APPEND="-Xms2048m -Xmx2048m "
export JAVA_OPTS_APPEND=" -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -Xbootclasspath/p:$JBOSS_LOGMANAGER_DIR/$JBOSS_LOGMANAGER_JAR"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -noverify -javaagent:/opt/eap/khan-apm/khan-agent/khan-agent-$KHAN_AGENT_VERSION.jar"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -Djboss.modules.system.pkgs=org.jboss.byteman,com.opennaru.khan.agent,org.jboss.logmanager"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_INSTANCE_ID=$KHAN_INSTANCE_ID"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_APPLICATION_NAME=$KHAN_APPLICATION_NAME"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_HOST=$KHAN_HOST"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_PORT=$KHAN_PORT"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_APDEX_THRESHOLD=$KHAN_APDEX_THRESHOLD"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_TRANSACTION_TRACE_ENABLED=$KHAN_TRANSACTION_TRACE_ENABLED"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_TRANSACTION_TRACE_THRESHOLD=$KHAN_TRANSACTION_TRACE_THRESHOLD"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_SQL_CAPTURE_ENABLED=$KHAN_SQL_CAPTURE_ENABLED"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_TRANSACTION_SAMPLING_INTERVAL=$KHAN_TRANSACTION_SAMPLING_INTERVAL"
export JAVA_OPTS_APPEND="$JAVA_OPTS_APPEND -DKHAN_DB_CONN_LEAK_WARNING=$KHAN_DB_CONN_LEAK_WARNING"

echo JAVA_OPTS $JAVA_OPTS >> /tmp/myenv.env
echo env  >> /tmp/myenv.env
env >> /tmp/myenv.env





. $JBOSS_HOME/bin/launch/messaging.sh
inject_brokers
configure_hornetq

. $JBOSS_HOME/bin/launch/datasource.sh
inject_datasources

. $JBOSS_HOME/bin/launch/admin.sh
configure_administration

. $JBOSS_HOME/bin/launch/ha.sh
check_view_pods_permission
configure_ha
configure_jgroups_encryption

. $JBOSS_HOME/bin/launch/https.sh
configure_https

. $JBOSS_HOME/bin/launch/json_logging.sh
configure_json_logging

. $JBOSS_HOME/bin/launch/security-domains.sh
configure_security_domains

. $JBOSS_HOME/bin/launch/jboss_modules_system_pkgs.sh
configure_jboss_modules_system_pkgs

. $JBOSS_HOME/bin/launch/keycloak.sh
configure_keycloak

. $JBOSS_HOME/bin/launch/deploymentScanner.sh
configure_deployment_scanner

echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION-$JBOSS_IMAGE_RELEASE"

exec $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS ${JBOSS_MESSAGING_ARGS}
