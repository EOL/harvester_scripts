#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "load_relationships.sh taxa.txt resource_id node_id_col parent_id_col accepted_parent_col" >&2
  exit 1
fi

cypher-shell <<EOF
using periodic commit
load csv from 'file:///$1' as line fieldterminator '\t'
match (n:Node {node_id: line[$3], resource_id: $2})
match (p:Node {node_id: line[$4], resource_id: $2})
merge (p)-[:IS_PARENT_OF]->(n);
using periodic commit
load csv from 'file:///$1' as line fieldterminator '\t'
match (n:GNode {node_id: line[$3], resource_id: $2})
match (b:GNode {node_id: line[$5], resource_id: $2})
merge (n)-[:IS_SYNONYM_OF]->(b);
EOF
