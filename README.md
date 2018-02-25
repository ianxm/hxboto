# hxboto

this library provides a haxe interface to the native python aws sdk

docs here: http://boto3.readthedocs.io/en/latest/index.html

## what is available?

hxboto covers most of the dynamoDB interface, and some of lambda and
STS.

## examples

there are integration test classes with working examples that
excercise the library. the tests require boto3 is installed and
configured.

note: many of the input structures are made up of nested Dicts. they
can be built from anonymous structures using python.Lib.anonToDict()
at each level.

## alternatives?

an alternative is andyli's pyextern project
[https://github.com/andyli/pyextern]. pyextern generates externs for
any python library. it is awesome, and it works for boto3 but right
now the interfaces are all dynamic and there's a lot of reflection,
and I'm having trouble with error handling. I'll continue to watch it.
