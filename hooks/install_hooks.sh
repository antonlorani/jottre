#!/bin/bash

set -e

hooks=("pre-commit")

top_level_dir=$(git rev-parse --show-toplevel)
source_hooks_dir="$top_level_dir/hooks"
destination_hooks_dir="$top_level_dir/.git/hooks"

if [ ! -d "$destination_hooks_dir" ]; then
    echo "Creating missing '$destination_hooks_dir' directory."
    mkdir -p "$destination_hooks_dir"
fi

for hook in "${hooks[@]}"; do
    ln -sf "$source_hooks_dir/$hook" "$destination_hooks_dir/$hook"
    echo "Creating symbolic link for '$hook'."
done
