#!/bin/sh

if [ -e /tmp/ajcollector.lock ] && kill -0 "$(cat /tmp/ajcollector.lock)" 2>/dev/null; then
  exit 0
fi

if [ x$DISPLAY = x ] ; then
  echo "No DISPLAY set, cannot start appleJuice JavaGUI"
  exit 1
fi

JAVA_ARGS="-Djava.net.preferIPv4Stack=true -Dsun.java2d.xrender=false"

cd /app/share/io.github.applejuicenetz.javagui/

exec java $JAVA_ARGS -jar /app/share/io.github.applejuicenetz.javagui/AJCoreGUI.jar "$@"
