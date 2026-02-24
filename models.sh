#!/bin/bash

for f in *.agent.md; do
    model=$(awk '/^---/{f++} f==1 && /^model:/{sub(/^model: */,""); print; exit}' "$f")
    printf "%-45s %s\n" "$f" "${model:-(not set)}"
done
