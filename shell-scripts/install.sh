#!/usr/bin/env bash

mkdir -p /project/bin
cabal v2-install hpack --jobs --constraint='hpack == 0.34.2' --installdir=/project/bin --install-method=copy
