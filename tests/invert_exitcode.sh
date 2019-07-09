#!/bin/bash
echo "$0: Inverting return code on exit"
$@
if [[ $? == 0 ]]; then
  exit 1
else
  exit 0
fi
