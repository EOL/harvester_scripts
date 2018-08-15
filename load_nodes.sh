#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "load_nodes.sh taxa.txt resource_id node_id_col scientific_name_col rank_col" >&2
  exit 1
fi

cypher-shell <<EOF
create index on :Node(node_id);

using periodic commit
load csv with headers from 'file:///$1' as line fieldterminator '\t'
merge (id:GlobalUniqueId) on create set id.count=1 on match set id.count=id.count+1
create (n:GNode:Node {node_id: line[$3], resource_id: $2, generated_auto_id: id.count, scientific_name: line[$4], rank: line[$5]});
EOF
