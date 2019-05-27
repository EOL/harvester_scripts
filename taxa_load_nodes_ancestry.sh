#!/bin/bash

if [ "$#" -ne 12 ]; then
  echo "load_nodes.sh taxa.txt resource_id ancestors ranks node_id_col generated_auto_id_col scientific_name_col rank_col page_id_col is_accepted_col accepted_parent_col has_header" >&2
  exit 1
fi
if [ "${12}" = "true" ]; then
cypher-shell <<EOF
using periodic commit 10000
load csv from 'file:///$1' as line fieldterminator '\t' with line, $3 as ancestors, $4 as ranks skip 1
merge(g:GlobalUniqueId)
merge(v:Variable)

foreach(test in case when true then [1] else [] end |
	set v.last_generated_partent_id=0
	FOREACH (idx in range(0, size(ancestors)-1)| 
		FOREACH(test IN CASE WHEN line[ancestors[idx]] IS NOT NULL and line [${10}]="1" THEN [1] ELSE [] END |
			FOREACH(test IN CASE WHEN v.last_generated_partent_id<>0 THEN [1] ELSE [] END |
				merge (p:GNode:Node {resource_id: $2, generated_auto_id: v.last_generated_partent_id})
				merge (n:GNode:Node {resource_id: $2, scientific_name: line[ancestors[idx]], rank: ranks[idx]})<-[r:IS_PARENT_OF]-(p)
 				on create set n.node_id="placeholder", n.created_at=timestamp(), n.updated_at=timestamp(), g.count=g.count+1, n.generated_auto_id=g.count
				set v.last_generated_partent_id=n.generated_auto_id)
			FOREACH(test IN CASE WHEN v.last_generated_partent_id=0 THEN [1] ELSE [] END |
				merge(n:GNode:Node:Root {resource_id: $2, node_id: "placeholder", scientific_name: line[ancestors[idx]], rank: ranks[idx]}) on create set n.created_at=timestamp(), 
				n.updated_at=timestamp(), g.count=g.count+1, n.generated_auto_id=g.count, v.last_generated_partent_id= g.count
				on match set v.last_generated_partent_id=n.generated_auto_id)))

	FOREACH(test IN CASE WHEN v.last_generated_partent_id<>0 THEN [1] ELSE [] END |
		merge (p:GNode:Node {resource_id: $2, generated_auto_id: v.last_generated_partent_id})
		merge (n:GNode:Node {resource_id: $2, scientific_name: line[$7]})<-[r:IS_PARENT_OF]-(p) on create set n.created_at=timestamp(), n.updated_at=timestamp(), n.node_id=line[$5], n.generated_auto_id=toInt(line[$6]), n.rank=line[$8] on match set n.node_id=line[$5], n.generated_auto_id=toInt(line[$6])

		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}]>"" THEN [1] ELSE [] END |remove n:Node set n:Synonym)
		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}] is null THEN [1] ELSE [] END |detach delete n)
		FOREACH(test IN CASE WHEN $9 > -1 AND line [$9] IS NOT NULL and line[${10}]="1" THEN [1] ELSE [] END | set n:Has_Page, n.page_id=line[$9])
	)

	FOREACH(test IN CASE WHEN v.last_generated_partent_id=0 THEN [1] ELSE [] END |
		create (n:GNode:Node:Root {resource_id: $2, node_id: line[$5], generated_auto_id: toInt(line[$6]), scientific_name: line[$7], rank: line[$8], created_at: timestamp(), updated_at: timestamp()})
		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}]>"" THEN [1] ELSE [] END |remove n:Node:Root set n:Synonym)
		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}] is null THEN [1] ELSE [] END |delete n)
		FOREACH(test IN CASE WHEN $9 > -1 AND line [$9] IS NOT NULL and line[${10}]="1" THEN [1] ELSE [] END | set n:Has_Page, n.page_id=line[$9])	
	)
);

load csv from 'file:///$1' as line fieldterminator '\t'
match (n:GNode {node_id: line[$5], resource_id: $2})
match (b:GNode {node_id: line[${11}], resource_id: $2})
merge (n)-[:IS_SYNONYM_OF]->(b);
EOF
else
cypher-shell <<EOF
using periodic commit 10000
load csv from 'file:///$1' as line fieldterminator '\t' with line, $3 as ancestors, $4 as ranks
merge(g:GlobalUniqueId)
merge(v:Variable)

foreach(test in case when true then [1] else [] end |
	set v.last_generated_partent_id=0
	FOREACH (idx in range(0, size(ancestors)-1)| 
		FOREACH(test IN CASE WHEN line[ancestors[idx]] IS NOT NULL and line [${10}]="1" THEN [1] ELSE [] END |
			FOREACH(test IN CASE WHEN v.last_generated_partent_id<>0 THEN [1] ELSE [] END |
				merge (p:GNode:Node {resource_id: $2, generated_auto_id: v.last_generated_partent_id})
				merge (n:GNode:Node {resource_id: $2, scientific_name: line[ancestors[idx]], rank: ranks[idx]})<-[r:IS_PARENT_OF]-(p)
 				on create set n.node_id="placeholder", n.created_at=timestamp(), n.updated_at=timestamp(), g.count=g.count+1, n.generated_auto_id=g.count
				set v.last_generated_partent_id=n.generated_auto_id)
			FOREACH(test IN CASE WHEN v.last_generated_partent_id=0 THEN [1] ELSE [] END |
				merge(n:GNode:Node:Root {resource_id: $2, node_id: "placeholder", scientific_name: line[ancestors[idx]], rank: ranks[idx]}) on create set n.created_at=timestamp(), 
				n.updated_at=timestamp(), g.count=g.count+1, n.generated_auto_id=g.count, v.last_generated_partent_id= g.count
				on match set v.last_generated_partent_id=n.generated_auto_id)))

	FOREACH(test IN CASE WHEN v.last_generated_partent_id<>0 THEN [1] ELSE [] END |
		merge (p:GNode:Node {resource_id: $2, generated_auto_id: v.last_generated_partent_id})
		merge (n:GNode:Node {resource_id: $2, scientific_name: line[$7]})<-[r:IS_PARENT_OF]-(p) on create set n.created_at=timestamp(), n.updated_at=timestamp(), n.node_id=line[$5], n.generated_auto_id=toInt(line[$6]), n.rank=line[$8] on match set n.node_id=line[$5], n.generated_auto_id=toInt(line[$6])

		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}]>"" THEN [1] ELSE [] END |remove n:Node set n:Synonym)
		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}] is null THEN [1] ELSE [] END |detach delete n)
		FOREACH(test IN CASE WHEN $9 > -1 AND line [$9] IS NOT NULL and line[${10}]="1" THEN [1] ELSE [] END | set n:Has_Page, n.page_id=line[$9])
	)

	FOREACH(test IN CASE WHEN v.last_generated_partent_id=0 THEN [1] ELSE [] END |
		create (n:GNode:Node:Root {resource_id: $2, node_id: line[$5], generated_auto_id: toInt(line[$6]), scientific_name: line[$7], rank: line[$8], created_at: timestamp(), updated_at: timestamp()})
		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}]>"" THEN [1] ELSE [] END |remove n:Node:Root set n:Synonym)
		FOREACH(test IN CASE WHEN line [${10}]="0" and line[${11}] is null THEN [1] ELSE [] END |delete n)
		FOREACH(test IN CASE WHEN $9 > -1 AND line [$9] IS NOT NULL and line[${10}]="1" THEN [1] ELSE [] END | set n:Has_Page, n.page_id=line[$9])	
	)
);

load csv from 'file:///$1' as line fieldterminator '\t'
match (n:GNode {node_id: line[$5], resource_id: $2})
match (b:GNode {node_id: line[${11}], resource_id: $2})
merge (n)-[:IS_SYNONYM_OF]->(b);
EOF
fi
