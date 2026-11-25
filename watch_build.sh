#!/bin/bash
# Watches BSlocalmax/*.lean and rebuilds changed files automatically.
# Result per file: buildlog/<Name>.log (last line: "DONE exit=<code>").
cd "$(dirname "$0")" || exit 1
export PATH="$HOME/.elan/bin:$PATH"
mkdir -p buildlog
echo "watch_build running in $(pwd). Stop with Ctrl-C."
# initial full build of the library
echo "building BSlocalmax $(date)" > buildlog/ALL.log
lake build BSlocalmax >> buildlog/ALL.log 2>&1
echo "DONE exit=$?" >> buildlog/ALL.log
tail -2 buildlog/ALL.log
# remember current state without building
for f in BSlocalmax/*.lean; do
  name=$(basename "$f" .lean)
  stat -f %m "$f" > "buildlog/$name.mtime"
done
while true; do
  for f in BSlocalmax/*.lean; do
    name=$(basename "$f" .lean)
    m=$(stat -f %m "$f")
    old=$(cat "buildlog/$name.mtime" 2>/dev/null)
    if [ "$m" != "$old" ]; then
      echo "$m" > "buildlog/$name.mtime"
      sleep 5   # wait until the file is completely written
      echo "building $name $(date)" > "buildlog/$name.log"
      lake build "BSlocalmax.$name" >> "buildlog/$name.log" 2>&1
      code=$?
      echo "DONE exit=$code" >> "buildlog/$name.log"
      echo "$name: exit=$code"
    fi
  done
  sleep 3
done
