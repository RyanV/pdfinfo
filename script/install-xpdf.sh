#!/bin/sh

: ${XPDF_VERSION:= "3.04"}
xpdf_tar = "install/xpdf-$XPDF_VERSION"

set -ex
if [[ -f $xpdf_tar ]]; then
  tar -xzvf install/xpdf-3.04.tar.gz
  cd xpdf-3.04 && ./configure --prefix=/usr && make && sudo make install
else
  echo "xpdf install file not found '$xpdf_tar'" >&2
  exit 1
fi

