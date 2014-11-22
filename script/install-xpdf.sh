#!/bin/sh
set -ex
: ${XPDF_VERSION:= "3.04"}
tar -xzvf install/xpdf-$XPDF_VERSION.tar.gz
cd xpdf-$XPDF_VERSION && ./configure --prefix=/usr && make && sudo make install