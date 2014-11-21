#!/bin/sh
set -ex
wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.04.tar.gz
tar -xzvf xpdf-3.04.tar.gz
cd xpdf-3.04 && ./configure --prefix=/usr && make && sudo make install
