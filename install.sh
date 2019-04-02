#!/bin/sh

# Based heavily on the approach used in https://github.com/denoland/deno_install
# Copyright 2018 the Deno authors. All rights reserved. MIT license.

set -e

lib_dir="$HOME/Library/Application Support/vba-blocks"
bin_dir="$lib_dir/bin"
addins_dir="$lib_dir/addins/build"
addins_link="$HOME/vba-blocks Add-ins"
zip_file="$lib_dir/vba-blocks-mac.tar.gz"
export_bin="export PATH=\"\$PATH:$bin_dir\""
profile="$HOME/.profile"
bash_profile="$HOME/.bash_profile"

if [ $# -eq 0 ]; then
	release_path=$(curl -sSf https://github.com/vba-blocks/vba-blocks/releases |
		grep -o "/vba-blocks/vba-blocks/releases/download/.*/vba-blocks-mac\\.tar\\.gz" |
		head -n 1)
	if [ ! "$release_path" ]; then exit 1; fi
	release_uri="https://github.com${release_path}"
else
	release_uri="https://github.com/vba-blocks/vba-blocks/releases/download/${1}/vba-blocks-mac.tar.gz"
fi

if [ ! -d "$lib_dir" ]; then
  echo "Creating lib directory $lib_dir"
	mkdir -p "$lib_dir"
fi

echo "[1/4] Downloading vba-blocks..."
curl -fL# -o "$zip_file" "$release_uri"

echo "[2/4] Extracting vba-blocks..."
tar -xzf "$zip_file" --directory "$lib_dir"
chmod +x "$bin_dir/vba-blocks"
chmod +x "$bin_dir/vba"
chmod +x "$lib_dir/vendor/node"

# Add bin to .profile / .bash_profile
echo "[3/4] Adding vba-blocks to PATH"
if ! [ -a $profile ] || ! grep -q "$bin_dir" $profile; then
  echo $export_bin >> "$profile"
fi
if [ -a $bash_profile ] && ! grep -q "$bin_dir" $bash_profile; then
  echo $export_bin >> "$bash_profile"
fi

# Create accessible add-ins folder
echo "[4/4] Creating link to add-ins at \"$addins_link\"..."
ln -sf "$addins_dir" "$addins_link"

echo ""
echo "\033[32mSuccess!\033[m vba-blocks was installed successfully."
echo "Open a new Terminal window and run 'vba --help' to get started"
echo ""
echo "[Additional Instructions]"
echo ""
echo "For more recent versions of Office for Mac, you will need to"
echo "trust access to the VBA project object model"
echo "for vba-blocks to work correctly."
echo ""
echo "1. Open Excel"
echo "2. Click \"Excel\" in the menu bar"
echo "3. Select \"Preferences\" in the menu"
echo "4. Click \"Security\" in the Preferences dialog"
echo "5. Check \"Trust access to the VBA project object model\""
echo "   in the Security dialog"
