#!/bin/sh

JAVA_ARGS="-Djava.net.preferIPv4Stack=true -Dsun.java2d.xrender=false"

cd /app/share/io.github.applejuicenetz.javagui/

exec java $JAVA_ARGS -jar /app/share/io.github.applejuicenetz.javagui/AJCoreGUI.jar "$@"
