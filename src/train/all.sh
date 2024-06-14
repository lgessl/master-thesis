#! /usr/bin/env bash

for file in src/train/*.R; do
    if [[ -f "$file" ]]; then
        Rscript "$file"
    fi
done