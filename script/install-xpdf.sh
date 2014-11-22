#!/bin/sh

: ${XPDF_VERSION:= "3.04"}

xpdftar="install/xpdf-$XPDF_VERSION.tar.gz"

set -ex

if [[ -f $xpdftar ]]; then
  tar -xzvf $xpdftar
  cd xpdf-$XPDF_VERSION && ./configure --prefix=/usr && make && sudo make install
else
  echo "xpdf install file not found '$xpdf_tar'" >&2
  exit 1
fi

