#!/usr/bin/env bash

if [ -d $INSTALL_PATH/manifests ] ; then
    rm -rf $INSTALL_PATH/manifests
fi

if [ -d $INSTALL_PATH/openshift ] ; then
    rm -rf $INSTALL_PATH/openshift
fi