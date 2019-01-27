#!/bin/bash

set -ex

if [[ "${1}" == "odyssey" ]]; then
  if confd -onetime -backend env ; then
    exec odyssey /opt/odyssey.conf
  else
    echo "Incorrect odyssey.conf template"
    exit 2
  fi
else
  exec ${@}
fi
