#!/bin/bash

RELEASE=$1
NEXT=$2
HADOOP_VERSION=$3

mvn -B release:prepare -DreleaseVersion=$RELEASE -DdevelopmentVersion=$NEXT
mkdir -p ${HOME}/tmp
tar zxf distribution/target/druid-${RELEASE}-bin.tar.gz -C ~/tmp
# Pull deps for druid parquet
pushd ${HOME}/tmp
echo "java -classpath \"${HOME}/tmp/druid-${RELEASE}/lib/*\" io.druid.cli.Main tools pull-deps --defaultVersion ${RELEASE} --clean -c io.druid.extensions.contrib:druid-parquet-extensions -h org.apache.hadoop:hadoop-client:${HADOOP_VERSION}"
java -classpath "${HOME}/tmp/druid-${RELEASE}/lib/*" io.druid.cli.Main tools pull-deps --defaultVersion ${RELEASE} --clean -c io.druid.extensions.contrib:druid-parquet-extensions -h org.apache.hadoop:hadoop-client:${HADOOP_VERSION}
pushd extensions
tar zcf druid-parquet-extensions.tar.gz druid-parquet-extensions/*
md5sum druid-parquet-extensions.tar.gz > druid-parquet-extensions.tar.gz.md5
aws s3 cp druid-parquet-extensions.tar.gz s3://branch-builds/druid/${RELEASE}/druid-parquet-extensions.tar.gz
aws s3 cp druid-parquet-extensions.tar.gz.md5 s3://branch-builds/druid/${RELEASE}/druid-parquet-extensions.tar.gz.md5
# Pop ~/tmp
popd
# Pop extensions
popd
# Upload the release file
pushd distribution/target
md5sum druid-${RELEASE}-bin.tar.gz > druid-${RELEASE}-bin.tar.gz.md5
aws s3 cp druid-${RELEASE}-bin.tar.gz s3://branch-builds/druid/${RELEASE}/druid-${RELEASE}-bin.tar.gz
aws s3 cp druid-${RELEASE}-bin.tar.gz.md5 s3://branch-builds/druid/${RELEASE}/druid-${RELEASE}-bin.tar.gz.md5
popd
# Done
