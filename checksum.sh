#!/bin/bash

set -e

function main() {
    echo -e "Start package checksum"

    # Init file
    echo -e "PACKAGE, VERSION, BIN, SHA1, DATE" > ./report_checksum.csv
    if [[ -f ./tmp_checksum ]]; then
        rm ./tmp_checksum
    fi

    DATE="$(date '+%Y/%m/%d')"
    # List packages
    local LINE_NUMBER="$(dpkg -s | sed -nEe '/^Package/p' | cut -d " " -f 2 | wc -l)"
    for i in $(seq 1 ${LINE_NUMBER}); do
        local PACKAGE_NAME="$(dpkg -s | sed -nEe '/^Package/p' | cut -d " " -f 2 | sed -n ${i}p)"
        local PACKAGE_VERSION="$(dpkg -s | sed -nEe '/^Version/p' | cut -d " " -f 2 | sed -n ${i}p)"
        local BIN_FIND="$(whereis ${PACKAGE_NAME} |cut -d " " -f 2)"
        local CHECKSUM="$(sha1sum ${BIN_FIND} 2>/dev/null | cut -d ' ' -f 1)"
        
        if [[ -z ${CHECKSUM} ]]; then
            echo -e "${PACKAGE_NAME} lib package [ \e[34mSKIP\e[39m ]"
        else
            echo "${PACKAGE_NAME}, ${PACKAGE_VERSION}, ${BIN_FIND}, ${CHECKSUM}, ${DATE}" >> report_checksum.csv
            echo -e "${BIN_FIND} [ \e[92mOK\e[39m ]"
        fi
    done
}

main