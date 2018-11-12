#!/bin/bash

if [ "$#" -ne 7 ]; then
# acceptedNameUsageIdCol accepted column number, -1 if column does not exist
# taxStatusCol the status column number, -1 if column does not exist
# parentCol the parent column number, -1 if column does not exist
  echo "generate_ids.sh taxa.txt acceptedNameUsageIdCol taxStatusCol parentCol nodeIdCol hasHeader separator" >&2
  exit 1
fi

add=""
if [ "$6" = "true" ]; then
    add=$(tail -n+2 "$1" | wc -l)
else
    add=$(tail -n+1 "$1" | wc -l)
fi

count=$(cypher-shell <<EOF | tail -n+2
match (id:GlobalUniqueId) return id.count;
EOF
)


cypher-shell <<EOF
match (id:GlobalUniqueId) set id.count=id.count+$add;
EOF

tmpfile=$(mktemp)
acceptedNameUsageIdCol=$2
taxStatusCol=$3
parentCol=$4
nodeIdCol=$5
hasHeader=$6

awk -F$7 -v OFS=$7 -v count="$count" -v isAccepted="" -v acceptedParent="" -v acceptedNameUsageIdCol=$acceptedNameUsageIdCol -v  taxStatusCol=$taxStatusCol -v parentCol=$parentCol -v nodeIdCol=$nodeIdCol -v hasHeader=$hasHeader  'BEGIN{ split("accepted_accepted name_preffered_preffered name_provisionally accepted_provisionally accepted name_valid_valid name",parts,"_"); for (i in parts) vals[parts[i]]=""}
{
    if(NR==1 && hasHeader=="true"){
    	print $0,"generated_auto_id","syn","accepted parent"
    }
    else{
    	if(acceptedNameUsageIdCol>"-1") {
    	    if($acceptedNameUsageIdCol=="" || $acceptedNameUsageIdCol==$nodeIdCol) {isAccepted="1";acceptedParent=""}#accepted
    	    else {isAccepted="0";acceptedParent=$acceptedNameUsageIdCol}        
    	}
    	else{
    	    if(taxStatusCol==-1){isAccepted="1";acceptedParent=""}#accepted
    	    else{
            	if($taxStatusCol=="") {isAccepted="1";acceptedParent=""}
            	else if($taxStatusCol in vals) {isAccepted="1";acceptedParent=""}
            	else{
                	#check parent exist
                	if($parentCol!=""){isAccepted="0";acceptedParent=$parentCol}
                	else{isAccepted="0";acceptedParent=""} #parent not exist
        	}
    	    }
       }
       if(hasHeader=="true"){print $0,count+NR-1,isAccepted,acceptedParent}
       else{print $0,count+NR,isAccepted,acceptedParent}
    }
}' "$1" >"$tmpfile" && mv "$tmpfile" "$1"
chmod 777 "$1"
