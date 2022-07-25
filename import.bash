#!/usr/bin/env bash
set -euo pipefail; if [ -n "${DEBUG-}" ]; then set -x; fi

project_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

tmpdir=$(mktemp -d);

filename=$(basename "$1")
name="${filename%.*}"

unzip "$1" -d "$tmpdir"

activitydir="$project_directory"/h5p-test/activities/"$name"
libdir="$project_directory"/h5p-test/libraries

mkdir "$activitydir"

mv "$tmpdir"/content "$tmpdir"/h5p.json "$activitydir"

function libversion() {
  jq -r .patchVersion < "$1"/library.json
}

echo "Processing libraries"
for lib in "$tmpdir"/*; do
  libname=$(basename "$lib")

  if [ -d "$lib" ] && [ ! -d "$libdir"/"$libname" ]; then
    echo "$libname not found, adding"
    mv "$lib" "$libdir"/
  elif [ -d "$lib" ] && [ -d "$libdir"/"$libname" ] && [ "$(libversion "$lib")" -gt "$(libversion "$libdir"/"$libname")" ]; then
    echo "$libname has a newer version ($(libversion "$lib")) than existing ($(libversion "$libdir"/"$libname")). upgrading."
    rm -r "$libdir"/"${libname:?}"
    mv "$lib" "$libdir"/
  elif [ -d "$lib" ] && [ -d "$libdir"/"$libname" ] && [ "$(libversion "$lib")" -lt "$(libversion "$libdir"/"$libname")" ]; then
    echo "$libname has an older version ($(libversion "$lib")) than existing ($(libversion "$libdir"/"$libname")). skipping."
  elif [ -d "$lib" ] && [ -d "$libdir"/"$libname" ] && [ "$(libversion "$lib")" -eq "$(libversion "$libdir"/"$libname")" ]; then
    echo "$libname has same version ($(libversion "$lib")) as existing ($(libversion "$libdir"/"$libname")). skipping."
  fi
done
