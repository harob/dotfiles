#!/bin/bash

# Script invoked by harry.gitnote.plist via launchd

set -eu -o pipefail

echo $(date -u) "Running gitnote..."

cd /Users/hrobertson/Documents/notes
git diff --quiet && git diff --staged --quiet || git add . && git commit -am 'Automated commit by gitnote'

echo $(date -u) "gitnote finished."
