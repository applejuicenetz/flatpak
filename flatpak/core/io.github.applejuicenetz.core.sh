#!/bin/sh

if [ -e /tmp/AJCore.lock ]; then
  exit 0
fi

echo $$ > /tmp/AJCore.lock

JAVA_ARGS="-Djava.net.preferIPv4Stack=true -Dsun.java2d.xrender=false -splash:splash.png $JAVA_ARGS"
#  flatpak override --user --env=JAVA_ARGS="-Xmx1024M" io.github.applejuicenetz.core

if [ x$DISPLAY != x ] ; then
  GUI_ARGS="--withgui"
else
  GUI_ARGS=""
fi

cd /app/share/io.github.applejuicenetz.core/

exec java $JAVA_ARGS -jar /app/share/io.github.applejuicenetz.core/ajcore.jar $GUI_ARGS "$@"


