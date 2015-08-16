#!/bin/bash
[[ -z "$INFO_LEVEL" ]] && source ./bits/bootstrap/logging

CP_OUTPUT=/tmp/cp.log
OWNER=${OWNER-$USER}

SCRIPT_OUTPUT=$(cp $1 $2 > $CP_OUTPUT 2>&1)
ERROR="Unable to copy $1 to $2 due to ..." ./bits/bootstrap/failonerrors $? $CP_OUTPUT
[ $? -ne 0 ] && exit 1
notify "  -- Copied $1 to $2"
OWNER=$OWNER ./bits/bootstrap/chownif $2
