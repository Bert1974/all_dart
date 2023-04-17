#!/bin/bash

cLibVersion=0.18.0

SUPPORTED_PLATFORMS=(
"linux-x64"
"linux-armv6hf"
"linux-armv7hf"
"linux-aarch64"
"windows-x86"
"windows-x64"
"macos-universal")

for platform in "${SUPPORTED_PLATFORMS[@]}"
do
	echo $platform
	if [[ $platform = w* ]]
	then
		ext="zip"
	else
		ext="tar.gz"
	fi
   
	downloadUrl=https://github.com/objectbox/objectbox-c/releases/download/v${cLibVersion}/objectbox-${platform}.${ext}
	echo $downloadUrl
	curl -s --output "download/objectbox-${platform}.${ext}" $downloadUrl
done