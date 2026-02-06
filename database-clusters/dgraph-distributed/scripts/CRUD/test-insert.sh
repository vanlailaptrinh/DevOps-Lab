#!/bin/bash

# Define Dgraph endpoint variable
DGRAPH_URL="http://dgraph-http.app.com"

echo "Seeding sample data to Dgraph at: $DGRAPH_URL..."

# Send mutation request (create 1 simple record)
curl -s -X POST "$DGRAPH_URL/mutate?commitNow=true" \
 -H "Content-Type: application/json" \
 -d '{
   "set": [
     {
       "name": "VanTran",
       "age": 22,
       "dgraph.type": "Person"
     }
   ]
 }' | jq .

echo "--- DONE ---"