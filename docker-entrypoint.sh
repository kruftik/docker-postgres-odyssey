#!/bin/bash

set -e -o pipefail

: ${ODYSSEY_CONF:="/opt/odyssey.conf"}

if [[ "${1}" == "odyssey" ]]; then
  if [[ -z "${ODYSSEY_CUSTOM_CONF}" ]]; then
    export ODYSSEY_POSTGRES_PASSWORD_MD5=$(echo "${ODYSSEY_POSTGRES_PASSWORD}" | md5sum | cut -d' ' -f1)

    if ! confd -onetime -backend env ; then
      echo "Incorrect odyssey.conf template"
      exit 2 
    fi

    cat ${ODYSSEY_CONF} | grep -v -E '^(#.*|)$' > ${ODYSSEY_CONF}.tmp && mv ${ODYSSEY_CONF}{.tmp,}
  else
    if [[ -f ${ODYSSEY_CUSTOM_CONF} ]]; then
      echo "Custom config path specified but ${ODYSSEY_CUSTOM_CONF} not found"
      exit 2 
    fi

    ODYSSEY_CONF="${ODYSSEY_CUSTOM_CONF}"
  fi
  
  exec odyssey ${ODYSSEY_CONF}
else
  exec ${@}
fi
