#!/bin/bash

# - Add missing parents with placeholder scientific name and rank
# - Escape double-quotes

if [ "$#" -ne 5 ]; then
  echo "preproc.sh taxa.txt node_id_col parent_id_col scientific_name_col rank_col" >&2
  exit 1
fi

tmpfile=$(mktemp)
join -t$'\t' -j1 -v2 <(tail -n+2 "$1"|awk -F'\t' "{print \$$2}"|sort) <(tail -n+2 "$1"|awk -F'\t' -v OFS='\t' "BEGIN{a[$4]=a[$5]=\"placeholder\"} \$$3!=\"\"{a[$2]=\$$3; o=a[1]; for(i=2;i<=NF;i++){o=o OFS a[i]} print o}"|sort -t$'\t' -k1b,1)|cat "$1" -|sed 's/"/\\"/g' >"$tmpfile" && mv "$tmpfile" "$1"
