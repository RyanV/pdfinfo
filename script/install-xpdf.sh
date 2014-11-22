#!/bin/sh
set -ex
tar -xzvf install/xpdf-$XPDF_VERSION.tar.gz
cd xpdf-$XPDF_VERSION && ./configure --prefix=/usr && make && sudo make install