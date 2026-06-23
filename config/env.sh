# tomcat 실행 시 환경변수 Shell script

#!/bin/bash
#************************ Warning **********************************
#*                                                                 *
#* This configuration is property of OPEN SOURCE CONSULTING, INC.  *
#* Don't distribute this to other project.                         *
#*                                                                 *
#*******************************************************************

# This is tomcat env.sh for iosp by Open Source Consulting, Inc

export DATE=`date +%Y%m%d_%H%M%S`

## Set Tomcat base env
export JAVA_HOME=/sw/java17
export SERVER_NAME=test-site
export CATALINA_HOME=/sw/apache-tomcat-10.1.23
export CATALINA_BASE=/sw/servers/$SERVER_NAME
export PORT_OFFSET=0
export COMP_USER=user

## Set Port Configuration
#########################################
#  Default Ports are as below           #
#  HTTP_PORT : 8080                     #
#  SSL_PORT : 8443                      #
#  SHUTDOWN_PORT : 8005                 #
#########################################

export HTTP_PORT=$(expr 8080 + $PORT_OFFSET)
export AJP_PORT=$(expr 8009 + $PORT_OFFSET)
export SSL_PORT=$(expr 8443 + $PORT_OFFSET)
export SHUTDOWN_PORT=$(expr 8005 + $PORT_OFFSET)
export JMX_PORT=$(expr 8555 + $PORT_OFFSET)

export LOG_HOME=/logs/java_logs/${SERVER_NAME}
export LOG_DIR=${LOG_HOME}/log
export GC_LOG_DIR=${LOG_HOME}/gclog
export HEAP_DUMP_DIR=${LOG_HOME}/heaplog
export LOG_LEVEL=DEBUG


if [ "x$JAVA_OPTS" = "x" ]; then
   JAVA_OPTS="-server"
   JAVA_OPTS="$JAVA_OPTS -Dserver=$SERVER_NAME"
   JAVA_OPTS="$JAVA_OPTS -Dhttp.port=$HTTP_PORT"
   JAVA_OPTS="$JAVA_OPTS -Dajp.port=$AJP_PORT"
   JAVA_OPTS="$JAVA_OPTS -Dssl.port=$SSL_PORT"
   JAVA_OPTS="$JAVA_OPTS -Dshutdown.port=$SHUTDOWN_PORT"
   JAVA_OPTS="$JAVA_OPTS -Djava.library.path=$CATALINA_HOME/lib/"

   # MC Application Properties
   JAVA_OPTS="$JAVA_OPTS -Dapp.name=$SERVER_NAME"

   # This is the configuration for scouter
   JAVA_OPTS="$JAVA_OPTS -javaagent:/sw/scouter/agent.java/scouter.agent.jar"
   JAVA_OPTS="$JAVA_OPTS -Dscouter.config=/sw/scouter/agent.java/conf/$SERVER_NAME.conf"

#   JAVA_OPTS="$JAVA_OPTS -noverify" # deprecated in JDK13
   JAVA_OPTS="$JAVA_OPTS -Xms1024m"
   JAVA_OPTS="$JAVA_OPTS -Xmx1024m"
   JAVA_OPTS="$JAVA_OPTS -XX:MetaspaceSize=512m"
   JAVA_OPTS="$JAVA_OPTS -XX:MaxMetaspaceSize=512m"
   JAVA_OPTS="$JAVA_OPTS -XX:+UseG1GC"

   # Application runtime mode
   JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=dev"

#   JAVA_OPTS="$JAVA_OPTS -verbose:gc"
   JAVA_OPTS="$JAVA_OPTS -Xlog:gc:${GC_LOG_DIR}/gc_$DATE.log:time,pid,tags:filecount=10,filesize=50m"
   JAVA_OPTS="$JAVA_OPTS -XX:+DisableExplicitGC"
   JAVA_OPTS="$JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError"
   JAVA_OPTS="$JAVA_OPTS -XX:HeapDumpPath=${HEAP_DUMP_DIR}/java_${SERVER_NAME}_pid_${DATE}.hprof"
   JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true"
   JAVA_OPTS="$JAVA_OPTS -Djava.security.egd=file:/dev/urandom"
   JAVA_OPTS="$JAVA_OPTS -XX:+UseStringDeduplication"
   JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8 -Dfile.client.encoding=UTF-8"

   # if use apache modjk
   JAVA_OPTS="$JAVA_OPTS -DjvmRoute=$SERVER_NAME"
   JAVA_OPTS="$JAVA_OPTS -Djdk.tls.rejectClientInitiatedRenegotiation=true"

## 사설 IP만 있는데 NAT 안되어 있는 경우 Proxy 설정
   JAVA_OPTS="$JAVA_OPTS -Djava.net.useSystemProxies=true"
   JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyHost=1.1.1.1"
   JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyPort=3128"
   JAVA_OPTS="$JAVA_OPTS -Dhttps.proxyHost=1.1.1.1"
   JAVA_OPTS="$JAVA_OPTS -Dhttps.proxyPort=3128"
   JAVA_OPTS="$JAVA_OPTS -Dhttp.nonProxyHosts='localhost|127.0.0.1'"

fi

export JAVA_OPTS

echo "================================================"
echo "CATALINA_HOME=$CATALINA_HOME"
echo "SERVER_HOME=$CATALINA_BASE"
echo "HTTP_PORT=$HTTP_PORT"
echo "SSL_PORT=$SSL_PORT"
echo "AJP_PORT=$AJP_PORT"
echo "SHUTDOWN_PORT=$SHUTDOWN_PORT"
echo "================================================"
