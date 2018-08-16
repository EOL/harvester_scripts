#!/bin/bash

# One-time initializations for the Neo4j graph database

cypher-shell <<EOF
create index on :Node(node_id);
create (:GlobalUniqueId {count: 0});
EOF
