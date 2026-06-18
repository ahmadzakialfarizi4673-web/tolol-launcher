#!/bin/sh

#
# Copyright © 2015-2021 the original authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

app_path="$0"

while [ -h "$app_path" ] ; do
    ls=$( ls -ld "$app_path" )
    link=$( expr "$ls" : '.*-> \(.*\)$' )
    if expr "$link" : '/.*' > /dev/null; then
        app_path="$link"
    else
        app_path=$( cd "$(dirname "$app_path")" && pwd -P )/$( basename "$app_path" )
    fi
done

APP_HOME=$( cd "$(dirname "$app_path")" && pwd -P )
APP_NAME="Gradle"
APP_BASE_NAME=${0##*/}
export CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

# Use the maximum available, or set MAX_FD != -1 to use that value.
MAX_FD=maximum

warn () {
    echo "$*"
} >&2

die () {
    echo
    echo "$*"
    echo
    exit 1
} >&2

# OS specific support (must be 'true' or 'false').
darwin=false
msys=false
cygwin=false
native=false
case "$( uname )" in
  Darwin* )
    darwin=true
    ;;
  MSYS* )
    msys=true
    ;;
  CYGWIN* )
    cygwin=true
    ;;
  NativeImage* )
    native=true
    ;;
esac

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD=$JAVA_HOME/jre/sh/java
    else
        JAVACMD=$JAVA_HOME/bin/java
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACMD=java
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

# Increase the maximum file descriptors if we can.
if ! "$cygwin" && ! "$darwin" && ! "$msys" && ! "$native" ; then
    case $( ulimit -S -n ) in
      'unlimited'|*'\t'*)
        ulimit -S -n 200000 ||
            warn "Could not set maximum file descriptor limit to 200000"
        ;;
    esac
fi

# Collect all arguments for the java command, stacking in reverse order:
for arg in "$@" ;
do
    case $arg in
      -*.java)    ;;
      ?*)         set -- "$arg" "$@" ;;
    esac
done

if "$cygwin" || "$msys" ; then
    APP_HOME=$( cygpath --path --mixed "$APP_HOME" )
    CLASSPATH=$( cygpath --path --mixed "$CLASSPATH" )

    JAVACMD=$( cygpath --unix "$JAVACMD" )

    # Now convert the arguments - kludge to limit ourselves to /bin/sh
    for arg do
        if
            case $arg in
              -*)   false ;;
              /)    false ;;
              */*) true ;;
              *) false ;;
            esac;
        then
            arg=$( cygpath --unix "$arg" )
        fi
        arg=$( printf %s\\n "$arg" | sed -e 's/[^()\'\t ]/\\\\&/g;1s/^/"/;$s/$/"/' ) ;;
            set -- "$set" "$arg"
    done
fi

set -- "$@" "-Dorg.gradle.appname=$APP_BASE_NAME" "-Dorg.gradle.appname=gradlew" "-Dorg.gradle.daemon=false" "-Dorg.gradle.worker.org.gradle.daemon=false"

exec "$JAVACMD" "${JVM_OPTS[@]}" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
