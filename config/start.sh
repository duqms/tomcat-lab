# tomcat 기동 shell script

#!/bin/bash
ABSOLUTE_PATH="$(cd $(dirname "$0") && pwd -P)"
. $ABSOLUTE_PATH/env.sh

DATE=`date +%Y%m%d_%H%M%S`

# ------------------------------------
PID=`ps -ef | grep java | grep "=$SERVER_NAME" | awk '{print $2}'`
echo $PID

if [ e$PID != "e" ]
then
echo "Tomcat ($SERVER_NAME) is already RUNNING..."
exit;
fi
# ------------------------------------
UNAME=`id -u -n`
if [ e$UNAME != "e$COMP_USER" ]
then
echo "$COMP_USER USER to start this SERVER! - $SERVER_NAME..."
exit;
fi
# ------------------------------------
#!/bin/bash

if [ ! -d $CATALINA_BASE/temp ]
then
echo "temp directory is not exist. create temp directory."
mkdir -p $CATALINA_BASE/temp
fi

if [ ! -d $CATALINA_BASE/logs ]
then
echo "logging directory is not exist. create logs directory."
mkdir -p $CATALINA_BASE/logs
fi

nohup $CATALINA_HOME/bin/catalina.sh run >>  $LOG_DIR/$SERVER_NAME.out 2>&1 &

# ------------------------------------
if [ e$1 = "enotail" ]
then
echo "Starting... $SERVER_NAME"
exit;
fi
# ------------------------------------

---------------------------------------------------------------------------------------------------------------
start.sh
   │
   ├─ env.sh 읽기
   │
   ├─ Tomcat 실행 여부 확인
   │      └─ 실행 중이면 종료
   │
   ├─ 실행 사용자 확인
   │      └─ 계정이 다르면 종료
   │
   ├─ temp 디렉터리 확인
   ├─ logs 디렉터리 확인
   │
   ├─ catalina.sh run 실행
   │
   └─ 로그를 xxx.out 파일에 기록
