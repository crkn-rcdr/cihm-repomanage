#!/bin/sh

echo
echo "Building cihm-repomanage:latest"

docker build --pull -t cihm-repomanage:latest .

if [ "$?" -ne "0" ]; then
  exit $?
fi


docker login docker.c7a.ca

if [ "$?" -ne "0" ]; then
  echo 
  echo "Error logging into the c7a Docker registry."
  exit 1
fi

BRANCH=`git rev-parse --abbrev-ref HEAD`

if [ "${BRANCH}" = "main" ]; then
  IMAGEEXT="";
else
  IMAGEEXT="-${BRANCH}"
fi

TAG=`date -u +"%Y%m%d%H%M%S"`

DISTIMAGE="docker.c7a.ca/cihm-repomanage${IMAGEEXT}:$TAG"
DISTLATEST="docker.c7a.ca/cihm-repomanage${IMAGEEXT}:latest"

echo
echo "Tagging cihm-repomanage:latest as $DISTIMAGE"

docker tag cihm-repomanage:latest $DISTIMAGE

if [ "$?" -ne "0" ]; then
  exit $?
fi

echo
echo "Tagging cihm-repomanage:latest as $DISTLATEST"

docker tag cihm-repomanage:latest $DISTLATEST

if [ "$?" -ne "0" ]; then
  exit $?
fi

echo
echo "Pushing $DISTIMAGE"

docker push $DISTIMAGE

if [ "$?" -ne "0" ]; then
  exit $?
fi

echo
echo "Pushing $DISTLATEST"

docker push $DISTLATEST

if [ "$?" -ne "0" ]; then
  exit $?
fi

echo
echo "Push sucessful. Create a new issue at:"
echo
echo "https://github.com/crkn-rcdr/Systems-Administration/issues/new?title=New+Repository+Management+image:+%60$DISTIMAGE%60&body=Please+describe+the+changes+in+this+update%2e"
echo
echo "to alert the systems team. Don't forget to describe what's new!"
