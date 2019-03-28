#!/bin/sh

# Based heavily on the approach used in https://github.com/denoland/deno_install
# Copyright 2018 the Deno authors. All rights reserved. MIT license.

set -e

case $(uname -s) in
Darwin) os="osx" ;;
*) os="linux" ;;
esac

if [ $# -eq 0 ]; then
	vbablocks_asset_path=$(curl -sSf https://github.com/vba-blocks/vba-blocks/releases |
		grep -o "/vba-blocks/vba-blocks/releases/download/.*/vba-blocks_${os}_x64\\.gz" |
		head -n 1)
	if [ ! "$vbablocks_asset_path" ]; then exit 1; fi
	vbablocks_uri="https://github.com${vbablocks_asset_path}"
else
	vbablocks_uri="https://github.com/vba-blocks/vba-blocks/releases/download/${1}/vba-blocks_${os}_x64.gz"
fi

bin_dir="$HOME/.vba-blocks/bin"
exe="$bin_dir/vba-blocks"

if [ ! -d "$bin_dir" ]; then
	mkdir -p "$bin_dir"
fi

curl -fL# -o "$exe.gz" "$vbablocks_uri"
gunzip -df "$exe.gz"
chmod +x "$exe"

echo "vba-blocks was installed successfully to $exe"
if command -v vba-blocks >/dev/null; then
	echo "Run 'vba-blocks --help' to get started"
else
	echo "Manually add the directory to your \$HOME/.bash_profile (or similar)"
	echo "  export PATH=\"$bin_dir:\$PATH\""
	echo "Run '$exe --help' to get started"
fi
