#!/bin/bash

# Script invoked by harry.gitnote.plist via launchd

set -eu -o pipefail

# Timestamp everything written to stderr (launchd appends it to
# ~/gitnote-stderr.log), so errors can be matched to a run.
exec 2> >(while IFS= read -r line; do echo $(date -u) "$line"; done >&2)

echo $(date -u) "Running gitnote..."

cd /Users/hrobertson/Dropbox/notes
if [ -n "$(git status --porcelain)" ]; then
  git add . && git commit -am 'Automated commit by gitnote'
fi

echo $(date -u) "gitnote finished."
