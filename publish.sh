#!/bin/sh

npm publish
cd ./bin

if [ -d ./haxe-classnames ]; then
	rm -rf ./haxe-classnames
fi

git clone git@github.com:kLabz/haxe-classnames.git
zip -r haxe-classnames-$1.zip ./haxe-classnames/*
rm -rf ./haxe-classnames

cd ..
haxelib submit bin/haxe-classnames-$1.zip
