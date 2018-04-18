#!/bin/bash

set -ex

function install_pgtap()
{
  # We have to do this, rather than the "make && make install" approach, as that requires
  # a build environment that matches the runtime environment; we need to cater for both
  # macOS and Linux so we do this instead.
  #
  # Should you need to upgrade pgtap --- you'll need to figure out these inputs manually
  # from the "make && make install". Sorry.

  local source="$1"
  local target="$2"

  /usr/bin/install -d "$target/share/postgresql/extension" "$target/doc/postgresql/extension"

  /usr/bin/install -c -m 644 \
    "$source/pgtap.control" \
    "$target/share/postgresql/extension/"

  /usr/bin/install -c -m 644 \
    "$source/sql/pgtap--0.90.0--0.91.0.sql" \
    "$source/sql/pgtap--0.91.0--0.92.0.sql" \
    "$source/sql/pgtap--0.92.0--0.93.0.sql" \
    "$source/sql/pgtap--0.93.0--0.94.0.sql" \
    "$source/sql/pgtap--0.94.0--0.95.0.sql" \
    "$source/sql/pgtap--0.95.0--0.96.0.sql" \
    "$source/sql/pgtap--0.96.0--0.97.0.sql" \
    "$source/sql/pgtap--0.97.0--0.98.0.sql" \
    "$source/sql/pgtap--0.98.0.sql" \
    "$source/sql/pgtap--unpackaged--0.91.0.sql" \
    "$source/sql/pgtap-core--0.98.0.sql" \
    "$source/sql/pgtap-core.sql" \
    "$source/sql/pgtap-schema--0.98.0.sql" \
    "$source/sql/pgtap-schema.sql" \
    "$source/sql/pgtap.sql" \
    "$source/sql/uninstall_pgtap.sql" \
    "$target/share/postgresql/extension/"

  /usr/bin/install -c -m 644 \
    "$source/doc/pgtap.mmd" \
    "$target/doc/postgresql/extension/"
}

POSTGRES_VERSION="9.6.2-1"
RSRC_DIR=$PWD/target/generated-resources
PGTAP_DIR=$PWD/src/main/pgtap

[ -e $RSRC_DIR/.repacked ] && echo "Already repacked, skipping..." && exit 0

cd `dirname $0`

PACKDIR=$(mktemp -d -t wat.XXXXXX)
LINUX_DIST=dist/postgresql-$POSTGRES_VERSION-linux-x64-binaries.tar.gz
OSX_DIST=dist/postgresql-$POSTGRES_VERSION-osx-binaries.zip

mkdir -p dist/ target/generated-resources/
[ -e $LINUX_DIST ] || wget -O $LINUX_DIST "https://get.enterprisedb.com/postgresql/postgresql-$POSTGRES_VERSION-linux-x64-binaries.tar.gz"
[ -e $OSX_DIST ] || wget -O $OSX_DIST "https://get.enterprisedb.com/postgresql/postgresql-$POSTGRES_VERSION-osx-binaries.zip"

tar zxf $LINUX_DIST -C $PACKDIR
install_pgtap "$PGTAP_DIR" "$PACKDIR/pgsql"
pushd $PACKDIR/pgsql
tar cJf $RSRC_DIR/postgresql-Linux-x86_64.txz \
  share/postgresql \
  lib \
  bin/initdb \
  bin/pg_ctl \
  bin/postgres
popd

rm -fr $PACKDIR && mkdir -p $PACKDIR

unzip -q -d $PACKDIR $OSX_DIST
install_pgtap "$PGTAP_DIR" "$PACKDIR/pgsql"
pushd $PACKDIR/pgsql
tar cJf $RSRC_DIR/postgresql-Darwin-x86_64.txz \
  share/postgresql \
  lib/libiconv.2.dylib \
  lib/libxml2.2.dylib \
  lib/libssl.1.0.0.dylib \
  lib/libcrypto.1.0.0.dylib \
  lib/libuuid.1.1.dylib \
  lib/postgresql/*.so \
  bin/initdb \
  bin/pg_ctl \
  bin/postgres
popd

rm -fr $PACKDIR && mkdir -p $PACKDIR

touch $RSRC_DIR/.repacked

exit 0
