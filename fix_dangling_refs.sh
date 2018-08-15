#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "fix_dangling_refs.sh taxa.txt" >&2
  exit 1
fi

join -t\t -v2 <(tail -n+2 "$1"|awk -F'\t' '{print $1}'|sort) <(tail -n+2 "$1"|awk -F'\t' -v OFS='\t' '{print $3,"","","placeholder","placeholder"}'|sort -k1,1)|sed '/^$/d'|cat "$1" -
