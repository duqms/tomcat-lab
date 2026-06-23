#!/bin/bash

APP_HOME=/sw/APP
APP_LOG_DIR=/logs/APP
APP_APP_DIR=/apps/APP
APP_APP_NAME=FinnqGateWay-0.0.1-SNAPSHOT.jar
APP_PID_DIR=/sw/APP/temp
APP_PID_NAME=APP.pid
APP_NOHUP_DIR=/logs/APP/nohup

export UMASK="0022"

TODAY=`date +%y%m%d`
APP_NOHUP_FILE=$APP_NOHUP_DIR/nohup-$TODAY

#----------------------------------------------
# 기동환경에 맞춰 수정하세요
#----------------------------------------------
APP_INSTANCE_ID=dAPP11
APP_ACTIVE_ENV=dev

JAVA=/bin/java
JAVA_OPTS=""
#JAVA_OPTS="-javaagent:/sw/apm/apm-agent/apm-was-agent/jamm-0.2.5.jar -Dapm.config.file=apm-agent-dAPP11.conf" 
JAVA_OPTS="$JAVA_OPTS -Dinstance.id=$APP_INSTANCE_ID -Denv=$APP_ACTIVE_ENV -Dspring.profiles.active=$APP_ACTIVE_ENV"
JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true -Dfile.encoding=UTF-8"
JAVA_OPTS="$JAVA_OPTS -Xms1024M -Xmx1024M -XX:MaxMetaspaceSize=512m -XX:+UseG1GC -XX:G1ReservePercent=20 -XX:+DisableExplicitGC -XX:+UseStringDeduplication -XX:+PrintGCTimeStamps -XX:+PrintGCDetails -Xloggc:$APP_LOG_DIR/gclog/gc.log -XX:+IgnoreUnrecognizedVMOptions"



#----------------------------------------------

case "$1" in 
start)
	if [ -e "$APP_PID_DIR/$APP_PID_NAME" ]; then
		echo "PID file exist. Check the Process[`cat $APP_PID_DIR/$APP_PID_NAME`]."
		exit 1
	else
		nohup $JAVA -jar $JAVA_OPTS $APP_APP_DIR/$APP_APP_NAME > $APP_NOHUP_FILE &
		echo $!>$APP_PID_DIR/$APP_PID_NAME
		exit 0
	fi
   ;;
stop)
	if [ -e "$APP_PID_DIR/$APP_PID_NAME" ]; then
		kill -0 `cat $APP_PID_DIR/$APP_PID_NAME` >/dev/null 2>&1
		if [ $? -gt 0 ]; then
			echo "PID file exist. but Process[`cat $APP_PID_DIR/$APP_PID_NAME`] not found!!"
   			rm "$APP_PID_DIR/$APP_PID_NAME"

			exit 0
		else
   			kill `cat $APP_PID_DIR/$APP_PID_NAME`

			echo "Success to Stop Process[`cat $APP_PID_DIR/$APP_PID_NAME`]"

   			rm "$APP_PID_DIR/$APP_PID_NAME"

			exit 0
		fi
	else
		echo "$APP_PID_DIR/$APP_PID_NAME file not exist. Stop aborted."
		exit 0
	fi
   ;;
restart)
   $0 stop
   $0 start
   ;;
status)
   if [ -e $APP_PID_DIR/$APP_PID_NAME ]; then
      echo APP is running, pid=`cat $APP_PID_DIR/$APP_PID_NAME`
   else
      echo APP is NOT running
      exit 1
   fi
   ;;
clear)
	if [ -e "$APP_PID_DIR/$APP_PID_NAME" ]; then
		kill -0 `cat $APP_PID_DIR/$APP_PID_NAME` >/dev/null 2>&1
		if [ $? -gt 0 ]; then
   			rm "$APP_PID_DIR/$APP_PID_NAME"
			echo "Success remove PID file"
			exit 0
		else
			echo "Process[`cat $APP_PID_DIR/$APP_PID_NAME`] alive!! You MUST use stop command!!"
			exit 1
		fi
	else
		echo "$APP_PID_DIR/$APP_PID_NAME file not exist. Clear aborted."
		exit 1
	fi
	;;
*)
   echo "Usage: $0 {start|stop|status|restart|clear}"
esac

exit 0

-------------------------------------------------------------------------------------------------------------------------------------------------------
[실행 순서]
app.sh
│
├── start
│     ↓
│   java -jar FinnqGateWay.jar
│     ↓
│   백그라운드 실행(nohup)
│     ↓
│   PID 저장(APP.pid)
│
├── stop
│     ↓
│   kill PID
│
├── restart
│     ↓
│   stop → start
│
├── status
│     ↓
│   PID 확인
│
└── clear
      ↓
    죽은 PID 파일 삭제
