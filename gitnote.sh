#!/bin/bash

# Script invoked by harry.gitnote.plist via launchd

set -eu -o pipefail

cd /Users/harry/Dropbox/notes
git diff --quiet && git diff --staged --quiet || git commit -am 'Automated commit by gitnote'
