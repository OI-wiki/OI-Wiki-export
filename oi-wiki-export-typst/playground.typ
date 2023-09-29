= Sparse matrix

$ P_(i j) eq mat(delim: "(", I_(i minus 1), , , , ; #none, 0, , 1, ; #none, , I_(j minus i minus 1), , ; #none, 1, , 0, ; #none, , , , I_(n minus j); ) $

$ P_(i j) eq mat(delim: "(", I_(i minus 1), , , , ; #none, 0, , 1, ; #none, , I_(j minus i minus 1), , ; #none, 1, , 0, ; #none, , , , I_(n minus j); ) $

= Upright text table

In display math:

$ 1 & bold("Input. ") upright("The edges of the graph ") e comma upright(" where each element in ") e upright(" is ") lr((u comma v comma w))\
 & upright(" denoting that there is an edge between ") u upright(" and ") v upright(" weighted ") w dot.basic\
2 & bold("Output. ") upright("The edges of the MST of the input graph") dot.basic\
3 & bold("Method. ")\
4 & r e s u l t arrow.l diameter\
5 & upright("sort ") e upright(" into nondecreasing order by weight ") w\
6 & bold("for") upright(" each ") lr((u comma v comma w)) upright(" in the sorted ") e\
7 & #h(2em) bold("if ") u upright(" and ") v upright(" are not connected in the union-find set ")\
8 & #h(2em) #h(2em) upright("connect ") u upright(" and ") v upright(" in the union-find set")\
9 & #h(2em) #h(2em) r e s u l t arrow.l r e s u l t #h(0em) union.big med brace.l lr((u comma v comma w)) brace.r\
10 & bold("return ") r e s u l t $

In inline math:

$1 & bold("Input. ") upright("The edges of the graph ") e comma upright(" where each element in ") e upright(" is ") lr((u comma v comma w))\
 & upright(" denoting that there is an edge between ") u upright(" and ") v upright(" weighted ") w dot.basic\
2 & bold("Output. ") upright("The edges of the MST of the input graph") dot.basic\
3 & bold("Method. ")\
4 & r e s u l t arrow.l diameter\
5 & upright("sort ") e upright(" into nondecreasing order by weight ") w\
6 & bold("for") upright(" each ") lr((u comma v comma w)) upright(" in the sorted ") e\
7 & #h(2em) bold("if ") u upright(" and ") v upright(" are not connected in the union-find set ")\
8 & #h(2em) #h(2em) upright("connect ") u upright(" and ") v upright(" in the union-find set")\
9 & #h(2em) #h(2em) r e s u l t arrow.l r e s u l t #h(0em) union.big med brace.l lr((u comma v comma w)) brace.r\
10 & bold("return ") r e s u l t$

#set heading(numbering: "1.1")

= Heading with a label <h1>

From @h1, we can...
And with @h2...

== Heading with another label <h2>

= `#scale()` function in equation
a.k.a. nested equation

Wrong:

$ #scale(x: 180%, y: 180%)[paren.l] 1 / 8 #scale(x: 180%, y: 180%)[paren.r] $

Right (but probably a lil hacky):

$ #scale(x: 180%, y: 180%)[$paren.l$] 1 / 8 #scale(x: 180%, y: 180%)[$paren.r$] $

= Color in equation

Wrong:
$ #text(fill: red)[$x y z$] / 2 $

Right:
$ #text(fill: red)[$x y z$] / 2 $

Wrong (i think it might be a bug...):
$ mat(delim: "(", #text(fill: blue)[$0$], #text(fill: red)[$0$]; 1, 0) $

Right:
$ mat(delim: "(", #text(fill: blue)[$0$], #text(fill: red)[$0$] ; 1, 0) $

= Augmented matrix

$ lr((2 & 0 & 5 & 6\
0 & 0 & 1 & 1\
0 & 0 & 2 & 2 | 9\
minus 4\
minus 8)) $

$ lr(paren.l mat(delim: #none, 2, 0, 5, 6;
0, 0, 1, 1;
0, 0, 2, 2;)
thick bar.v)
lr(mat(delim: #none, 9; -4; -8) paren.r) $

$ lr((mat(delim: #none, 2, 0, 5, 6;
0, 0, 1, 1;
0, 0, 2, 2;) bar.v mat(delim: #none, 9; -4; -8))) $

$ lr((mat(delim: #none, 2, 0, 5, 6;
0, 0, 1, 1;
0, 0, 2, 2;) lr(bar mat(delim: #none, 9; -4; -8)))) $

$ mat(delim: "(", 2, 0, 5, 6, 9; 0, 0, 1, 1, -4; 0, 0, 2, 2, -8; augment: #4) $

= Cases without cases (what?)

$ cases(x_1 = x_2 + x_3, x_2 = x_3 + x_4) $

= Cases gap

$ cases(x_1 = x_2 + x_3 & x < 0, x_2 = x_3 + x_4 & x > 0) $

$ cases(x_1 = x_2 + x_3 &quad x < 0, x_2 = x_3 + x_4 &quad x > 0) $
