#!/bin/bash

CONFIG_FILE='/etc/sysctl.d/90-disable-rp_filter.conf'
INTERFACES=(all eth0 eth1 eth2)
readonly STATUS='0'

log () {
    local MESSAGE="${@}"
    logger -t "$(basename ${0})" "${MESSAGE}"
}

getstatus () {
    local INTERFACE_NAME="${1}"
    sysctl -a --ignore |& grep ${INTERFACE_NAME}.rp_filter | awk '{ print $3 }'
}

log 'Starting change status of rp_filter'
log 'Checking file if exists'
# Delete config file if already exists
if [[ -f "${CONFIG_FILE}" ]]
then
    log 'Delete config file'
    rm ${CONFIG_FILE}
fi

# Change parameter state
for INTERFACE_NAME in ${INTERFACES[@]}
do
    log "Interface: $INTERFACE_NAME"
    sysctl -a --ignore |& grep ${INTERFACE_NAME}.rp_filter &>/dev/null
    if [[ $? = 0 ]]
    then
        NET_CONFIG="$(sysctl -a --ignore |& grep \\${INTERFACE_NAME}.rp_filter | awk '{ print $1 }')"
        log "Print current state of ${INTERFACE_NAME}.rp_filter: $(getstatus ${INTERFACE_NAME})"
        sysctl -w "${NET_CONFIG}=${STATUS}" &>/dev/null
        echo "${NET_CONFIG}=${STATUS}" >> ${CONFIG_FILE}
        log "Print new state of ${INTERFACE_NAME}.rp_filter after changes: $(getstatus ${INTERFACE_NAME})"
    fi
done
log 'Updated states'
exit 0