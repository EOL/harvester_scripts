#!/bin/bash

# One-time initializations for the Neo4j graph database

cypher-shell <<EOF
create index on :GNode(node_id);
create (:GlobalUniqueId {count: 0, page_id: 0});
EOF
