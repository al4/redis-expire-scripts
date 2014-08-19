#!/bin/bash

if [ $# -ne 3 ]
then
  echo "Expire keys from Redis matching a pattern using SCAN & EXPIRE"
  echo "Usage: $0 <host> <port> <pattern>"
  exit 1
fi

cursor=-1
keys=""

while [[ $cursor -ne 0 ]]; do
  if [[ $cursor -eq -1 ]]
  then
    cursor=0
  fi

  reply=$(redis-cli -h $1 -p $2 SCAN $cursor MATCH $3 COUNT 100)
  cursor=$(expr "$reply" : '\([0-9]*[0-9 ]\)')
  echo "Cursor: $cursor"

  keys=$(echo $reply | awk '{for (i=2; i<NF; i++) print $i}')
  [ -z "$keys" ] && continue

  keya=( $keys )
  count=$(echo ${#keya[@]})
  redis-cli -h $1 -p $2 EVAL "$(cat expire.lua)" $count $keys
done
