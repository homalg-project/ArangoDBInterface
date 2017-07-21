all: doc test

doc: doc/manual.six

doc/manual.six: makedoc.g \
		PackageInfo.g \
		doc/Doc.autodoc \
		gap/*.gd gap/*.gi
	        gap makedoc.g

clean:
	(cd doc ; ./clean)

test:	doc
	gap maketest.g
