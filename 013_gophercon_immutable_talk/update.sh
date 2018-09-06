#!/usr/bin/env bash

set -e

go install ../cmd/mdreplace
mdreplace -long -online source.md | sed -e :a -re 's/<!--.*?-->//g;/<!--/N;//ba' > ~/gostuff/src/github.com/myitcv/talks/2018-08-15-glug-modules/main.slide
rsync -i -a /home/myitcv/MacHomeDir/Desktop/london_gophers_modules/modules/ /home/myitcv/gostuff/src/github.com/myitcv/talks/2018-08-15-glug-modules/images/
