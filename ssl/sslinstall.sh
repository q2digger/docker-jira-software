#!/bin/sh

if [ "$(ls -A /ssl/root)" ]; then
  for cert in /ssl/root/*
    do
      $JAVA_HOME/bin/keytool -keystore $JAVA_HOME/jre/lib/security/cacerts -importcert -storepass changeit -noprompt -file $cert
      if [ "$?" -ne "0" ];
        then
          printf "something wrong\n"
        else
          printf "All ok, $file added to rootcas\n"
      fi
  done
fi

if [ ! -f /ssl/insecure_ssl ]
  then
    exit 0
  else
    path=`dirname $0`
    cd $path
    if [ ! -f SSLPoke.class ] ; then javac SSLPoke.java; fi
    if [ ! -f InstallCert.class ]; then javac InstallCert.java; fi
    for i in `cat /ssl/insecure_ssl`; do
      printf "1\n" | java InstallCert $i > /dev/null 2>&1
      sleep 1
      printf "Added certificate for $i to the keystore\n"
    done
    sleep 1
    cp jssecacerts $JAVA_HOME/jre/lib/security/jssecacerts
fi
