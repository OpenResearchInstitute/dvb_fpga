#!/usr/bin/env bash

set -e
USERNAME="${USERNAME:-user}"

addgroup "$USERNAME" --gid "$GROUP_ID" > /dev/null 2>&1

adduser --disabled-password            \
  --gid "$GROUP_ID"                    \
  --uid "$USER_ID"                     \
  --home "/home/$USERNAME" "$USERNAME" > /dev/null 2>&1

su -l "$USERNAME" -c "     \
  cd /project           && \
  ./run.py ${VUNIT_ARGS[*]}"

