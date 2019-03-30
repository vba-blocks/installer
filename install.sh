#!/bin/sh

# Based heavily on the approach used in https://github.com/denoland/deno_install
# Copyright 2018 the Deno authors. All rights reserved. MIT license.

set -e

if [ $# -eq 0 ]; then
	release_path=$(curl -sSf https://github.com/vba-blocks/vba-blocks/releases |
		grep -o "/vba-blocks/vba-blocks/releases/download/.*/vba-blocks-mac\\.tar\\.gz" |
		head -n 1)
	if [ ! "$release_path" ]; then exit 1; fi
	release_uri="https://github.com${release_path}"
else
	release_uri="https://github.com/vba-blocks/vba-blocks/releases/download/${1}/vba-blocks-mac.tar.gz"
fi

lib_dir="$HOME/Library/Application Support/vba-blocks"
bin_dir="$lib_dir/bin"
zip_file="$lib_dir/vba-blocks-mac.tar.gz"

if [ ! -d "$lib_dir" ]; then
	mkdir -p "$lib_dir"
fi

curl -fL# -o "$zip_file" "$release_uri"
tar -xzf "$zip_file"
chmod +x "$bin_dir/vba-blocks"
chmod +x "$bin_dir/vba"

echo "vba-blocks was installed successfully to $lib_dir"
if command -v vba-blocks >/dev/null; then
	echo "Run 'vba --help' to get started"
else
	# TODO Automate this similar to rustup
	# https://github.com/rust-lang/rustup.rs/blob/fa154f67d773c44e8fba07db4ec8f5ef97db54cb/src/cli/self_update.rs#L1186

	echo "Manually add the directory to your \$HOME/.bash_profile (or similar)"
	echo "  export PATH=\"$bin_dir:\$PATH\""
	echo "Run '$bin_dir/vba --help' to get started"
fi

# TODO Create "$HOME/vba-blocks Addins" symlink to "$lib_dir/addins"
