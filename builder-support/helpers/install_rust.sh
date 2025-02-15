#!/bin/sh

set -e

ARCH=$(arch)

# Default version
RUST_VERSION=rust-1.72.0-$ARCH-unknown-linux-gnu

if [ $# -ge 1 ]; then
    RUST_VERSION=$1
    shift
fi

SITE=https://downloads.powerdns.com/rust
RUST_TARBALL=$RUST_VERSION.tar.gz

SHA256SUM_x86_64=f2bbe23e685852104fd48d0e34ac981b0917e76c62cfcd6d0ac5283e4710c7b9

NAME=SHA256SUM_$ARCH
eval VALUE=\$$NAME
if [ -z "$VALUE" ]; then
    echo "$0: No SHA256 defined for $ARCH" > /dev/stderr
    exit 1
fi

# Procedure to update the Rust tarball:
# 1. Download tarball and signature (.asc) file from
#    https://forge.rust-lang.org/infra/other-installation-methods.html "Standalone installers" section
# 2. Import Rust signing key into your gpg if not already done so
# 3. Run gpg --verify $RUST_TARBALL.asc and make sure it is OK
# 4. Run sha256sum $RUST_TARBALL and set SHA256SUM above, don't forget to update RUST_VERSION as well
# 5. Make $RUST_TARBALL available from https://downloads.powerdns.com/rust
#
cd /tmp
echo $0: Downloading $RUST_TARBALL

curl -o $RUST_TARBALL $SITE/$RUST_TARBALL
# Line below should echo two spaces between digest and name
echo $VALUE"  "$RUST_TARBALL | sha256sum -c -
tar -zxf $RUST_TARBALL
cd $RUST_VERSION
./install.sh --prefix=/usr
cd ..
rm -rf $RUST_TARBALL $RUST_VERSION
