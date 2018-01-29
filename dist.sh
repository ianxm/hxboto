#!/bin/bash

if [ -e hxboto.zip ]; then
    rm hxboto.zip
fi

zip hxboto.zip haxelib.json LICENSE README boto3/*.hx test.hxml
