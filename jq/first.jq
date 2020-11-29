#!/bin/bash

OUT=./out

# jq < example.json > $OUT/default.example.json
# jq < $OUT/slurp.example.json

# jq --seq < example.json
###############################################################################
# ignoring parse error: Unfinished abandoned text at EOF at line 23, column 0 #
###############################################################################

# jq --stream < example.json > $OUT/stream.example.json
# jq < $OUT/stream.example.json

# jq --slurp < example.json > $OUT/slurp.example.json
# jq < $OUT/slurp.example.json

jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | [.id, .principalOrFirstMaker] | @csv' < example.json
