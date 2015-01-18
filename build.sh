#!/bin/sh

if [ ! -d ./out/compile ]; then
    mkdir ./out/compile
fi

if [ ! -d ./application ]; then
    mkdir application
fi

rm -rf ./application/*

mkdir ./application/ebin
mkdir ./application/src
mkdir ./application/include
mkdir ./application/priv
mkdir ./application/bin


JAVA_PROJECT_DIR="/home/yorg/Projekty/Java/java-2-erl"
CURRENT_DIR=`pwd`
OUTPUT_DIR=`readlink -f ./application`

JAR_NAME="java-2-erl.jar"

erlc -o ./application/ebin src/*.erl

cd ${JAVA_PROJECT_DIR}
mvn clean compile assembly:single
cp ./target/$JAR_NAME $CURRENT_DIR/application/priv
cd $CURRENT_DIR