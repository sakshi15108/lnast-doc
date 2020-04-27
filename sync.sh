#!/bin/sh

if [ $# -ne 1 ]; then
  echo "synchronize the generated slate with a given directory:"
  echo "  sync.sh <directory>"
  exit 2
fi

dest=$1

NODE=$(which yarn)
if [ -x $(which yarnpkg) ]; then
  NODE=$(which yarnpkg)
fi

if [ -x $NODE ]; then
  echo "re-running yarn"
  ${NODE} "run" "update"
else
  if [ -f index.html ]; then
    echo "yarn is not installed, reusing index.html"
  else
    echo "ERROR: yarn is not installed, and index.html is missing"
    exit 3
  fi
fi

echo "node:"$NODE
echo "dest:"$dest
rsync index.html $dest
rsync -r pub $dest
rsync -r source $dest
