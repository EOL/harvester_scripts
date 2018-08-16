#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "load_nodes.sh taxa.txt resource_id node_id_col scientific_name_col rank_col" >&2
  exit 1
fi

cypher-shell <<EOF
using periodic commit
load csv with headers from 'file:///$1' as line fieldterminator '\t'
create (n:GNode:Node {node_id: line[$3], resource_id: $2, generated_auto_id: line.generated_auto_id, scientific_name: line[$4], rank: line[$5]});
EOF
