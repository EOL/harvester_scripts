#!/bin/bash

if [ "$#" -ne 8 ]; then
  echo "load_nodes.sh taxa.txt resource_id node_id_col scientific_name_col rank_col generated_auto_id_col parent_id_col has_header" >&2
  exit 1
fi

if [ "$8" = "true" ]; then
cypher-shell <<EOF
using periodic commit 10000
load csv from 'file:///$1' as line fieldterminator '\t' with line skip 1
FOREACH(test IN CASE WHEN line [$7] IS NULL THEN [1] ELSE [] END | 
	create (n:GNode:Node:Root {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
)
FOREACH(test IN CASE WHEN line [$7] IS NOT NULL THEN [1] ELSE [] END | 
	create (n:GNode:Node {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
);
EOF
else
cypher-shell <<EOF
using periodic commit 10000
load csv from 'file:///$1' as line fieldterminator '\t' 
create (n:GNode:Node {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()});
EOF
fi
