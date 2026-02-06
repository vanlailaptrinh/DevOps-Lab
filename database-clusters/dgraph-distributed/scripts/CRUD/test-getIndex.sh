#!/bin/bash

# Define Dgraph endpoint variable
DGRAPH_URL="http://dgraph-http.app.com"
TARGET_UID="0x4e21"  # Change this UID to whatever you want to find

echo "Querying Dgraph for UID: $TARGET_UID..."

# Send query request
curl -s -X POST "$DGRAPH_URL/query" \
  -H "Content-Type: application/json" \
  -d "{
     \"query\": \"{ result(func: uid($TARGET_UID)) { uid name age dgraph.type } }\"
  }" | jq .

echo "--- DONE ---"