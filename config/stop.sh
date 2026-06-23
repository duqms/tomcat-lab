# tomcat 중지 shell script

#!/bin/bash
ABSOLUTE_PATH="$(cd $(dirname "$0") && pwd -P)"
. $ABSOLUTE_PATH/env.sh

$CATALINA_HOME/bin/stop.sh
