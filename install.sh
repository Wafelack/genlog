#!/usr/bin/env bash
set -euo pipefail

latest=$(curl --silent "https://api.github.com/repos/wafelack/genlog/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
link="https://raw.githubusercontent.com/wafelack/genlog/${latest}/genlog.sh"
wget $link
cp ./genlog.sh /usr/bin/
