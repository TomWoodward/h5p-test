#!/usr/bin/env bash
set -euo pipefail; if [ -n "${DEBUG-}" ]; then set -x; fi

project_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

rm "$project_directory"/h5p-test/activities/activities.txt
for file in "$project_directory"/h5p-test/activities/*; do
  basename "$file" >> "$project_directory"/h5p-test/activities/activities.txt
done
