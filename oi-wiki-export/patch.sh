#!/bin/sh
sed -i -e 's/sqrt()/sqrt(#none)/g' ./typ/OIwikidocsintrosymbolmd.typ
sed -i -e 's/root(n, )/root(n, #none)/g' ./typ/OIwikidocsintrosymbolmd.typ
sed -i -e 's/r^(⃗)/vec(r)/g' ./typ/OIwikidocsmathnumbertheorycontinuedfractionmd.typ
sed -i -e 's/delim: "\[", ,/delim: "\[", #none,/g' ./typ/OIwikidocsmathpolylinearrecurrencemd.typ
sed -i -e 's/; ,/; #none,/g' ./typ/OIwikidocsmathpoly*
sed -i -e 's/; ,/; #none,/g' ./typ/OIwikidocsmathsimplexmd.typ
sed -i -e 's/; ,/; #none,/g' ./typ/OIwikidocsmathlinearalgebra*
sed -i -e 's/"None"/\\"None\\"/g' ./typ/OIwikidocsgraphmstmd.typ

