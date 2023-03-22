#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Append TODO
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☑
# @raycast.argument1 { "type": "text", "placeholder": "Text" }

# Documentation:
# @raycast.description Append a TODO to inbox.org
# @raycast.author Harry Robertson

printf "** TODO $1\n" >> "$HOME/Dropbox/notes/test_inbox.org"
