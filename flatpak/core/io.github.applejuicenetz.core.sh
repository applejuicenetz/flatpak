#!/bin/sh

if [ -e /tmp/AJCore.lock ]; then
  exit 0
fi

echo $$ > /tmp/AJCore.lock

DISABLE_SPLASH=0
for arg in "$@"; do
  case "$arg" in
    --nogui|--nosplash)
      DISABLE_SPLASH=1
      ;;
  esac
done

if [ "$DISABLE_SPLASH" -eq 1 ]; then
  SPLASH_ARG=""
else
  SPLASH_ARG="-splash:splash.png"
fi

JAVA_ARGS="-Duser.language=de -Duser.country=DE -Djava.net.preferIPv4Stack=true $SPLASH_ARG $JAVA_ARGS"

if [ x$DISPLAY != x ] ; then
  GUI_ARGS="--withgui"
else
  GUI_ARGS=""
fi

cd /app/share/io.github.applejuicenetz.core/

exec java $JAVA_ARGS -jar /app/share/io.github.applejuicenetz.core/ajcore.jar $GUI_ARGS "$@"
