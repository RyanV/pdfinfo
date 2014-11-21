#!/bin/sh
set -ex
tar -xzvf install/xpdf-3.04.tar.gz
cd xpdf-3.04 && ./configure --prefix=/usr && make && sudo make install
