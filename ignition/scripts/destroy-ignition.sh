#!/usr/bin/env bash

if [ -e ${INSTALL_PATH}/bootstrap.ign ] ; then
    rm ${INSTALL_PATH/bootstrap.ign}
fi

if [ -e ${INSTALL_PATH}/master.ign ] ; then
    rm ${INSTALL_PATH/master.ign}
fi

if [ -e ${INSTALL_PATH}/worker.ign ] ; then
    rm ${INSTALL_PATH/worker.ign}
fi