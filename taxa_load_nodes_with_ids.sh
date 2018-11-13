#!/bin/bash

if [ "$#" -ne 10 ]; then
  echo "load_nodes.sh taxa.txt resource_id node_id_col scientific_name_col rank_col generated_auto_id_col parent_id_col has_header page_id_col is_accepted_col" >&2
  exit 1
fi

if [ "$8" = "true" ]; then
if [ "$9" != "-1" ]; then
cypher-shell <<EOF
using periodic commit 10000
load csv from 'file:///$1' as line fieldterminator '\t' with line skip 1
OPTIONAL match (n:GlobalUniqueId) where n.page_id < toInt(line[$9]) set n.page_id=toInt(line[$9])
FOREACH(test IN CASE line [${10}] WHEN "0" THEN [1] ELSE [] END |
	create (n:GNode:Synonym {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
)
FOREACH(test IN CASE WHEN line [$7] IS NULL AND line [${10}]="1" THEN [1] ELSE [] END | 
	FOREACH(test IN CASE WHEN line [$9] IS NULL THEN [1] ELSE [] END |
		create (n:GNode:Node:Root {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
	)
	FOREACH(test IN CASE WHEN line [$9] IS NOT NULL THEN [1] ELSE [] END |
		create (n:GNode:Node:Root:Has_Page {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], page_id: toInt(line[$9]), created_at: timestamp(), updated_at: timestamp()})
	)
)
FOREACH(test IN CASE WHEN line [$7] IS NOT NULL AND line [${10}]="1" THEN [1] ELSE [] END | 
	FOREACH(test IN CASE WHEN line [$9] IS NULL THEN [1] ELSE [] END |
		create (n:GNode:Node {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
	)
	FOREACH(test IN CASE WHEN line [$9] IS NOT NULL THEN [1] ELSE [] END |
		create (n:GNode:Node:Has_Page {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], page_id: toInt(line[$9]), created_at: timestamp(), updated_at: timestamp()})
	)
);
EOF
else
cypher-shell <<EOF
using periodic commit 10000
load csv from 'file:///$1' as line fieldterminator '\t' with line skip 1
FOREACH(test IN CASE line [${10}] WHEN "0" THEN [1] ELSE [] END |
	create (n:GNode:Synonym {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
)
FOREACH(test IN CASE WHEN line [$7] IS NULL AND line [${10}]="1" THEN [1] ELSE [] END | 
	create (n:GNode:Node:Root {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
)
FOREACH(test IN CASE WHEN line [$7] IS NOT NULL AND line [${10}]="1" THEN [1] ELSE [] END | 
	create (n:GNode:Node {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()})
);
EOF
fi
else
cypher-shell <<EOF
using periodic commit 10000
load csv from 'file:///$1' as line fieldterminator '\t' 
create (n:GNode:Node {node_id: line[$3], resource_id: $2, generated_auto_id: toInt(line[$6]), scientific_name: line[$4], rank: line[$5], created_at: timestamp(), updated_at: timestamp()});
EOF
fi
