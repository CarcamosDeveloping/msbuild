#!/usr/bin/env bash
#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source "$DIR/../common/_common.sh"

# Use a repo-local install directory (but not the artifacts directory because that gets cleaned a lot
[ -d $DOTNET_INSTALL_DIR ] || mkdir -p $DOTNET_INSTALL_DIR

# Ensure the latest stage0 is installed
header "Installing dotnet stage 0"
$REPOROOT/scripts/obtain/install.sh

# Now patch the runtime in stage 0
# HACK(anurse): BIG HACK. This is just to dodge the current broken Linux stage0. We'll remove it as soon as we've got a new stage 0
(
    export PATH="$DOTNET_INSTALL_DIR/bin:$PATH"
    cd $REPOROOT/src/Microsoft.DotNet.Runtime
    dotnet restore
    dotnet publish -o "$DOTNET_INSTALL_DIR/share/dotnet/cli/runtime"
    cp $DOTNET_INSTALL_DIR/share/dotnet/cli/runtime/coreclr/* $DOTNET_INSTALL_DIR/share/dotnet/cli/bin
)
