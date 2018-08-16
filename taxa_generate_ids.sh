#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "generate_ids.sh taxa.txt" >&2
  exit 1
fi

add=$(tail -n+2 "$1" | wc -l)

count=$(cypher-shell <<EOF | tail -n+2
match (id:GlobalUniqueId) return id.count;
EOF
)

cypher-shell <<EOF
match (id:GlobalUniqueId) set id.count=id.count+$add;
EOF

awk -F'\t' -v OFS='\t' -v count="$count" 'NR==1{print $0,"generated_auto_id"}NR>1{print $0,count+NR}' "$1"
