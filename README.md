# tacitus
Tacit array-based programming (alpha)

This code does almost nothing. It's woefully incomplete. Be thee warned.

I've been fascinated by [tacit programming](https://en.wikipedia.org/wiki/Tacit_programming), and not just for the compact and terse style. I wonder if tacit programming could be a vehicle for a kind of "smart compilation": the user chains together a large number of transformations or functions that are easy to understand--say, neural network layers, or matrices that are to be multiplied--and the language rearranges the sequence of operations in such a way that the final result is the same, but optimizations have been automatically carried out. This is usually described in Haskell circles as [equational reasoning](http://www-cs-students.stanford.edu/~blynn/haskell/eqreason.html), and I wonder if the tacit style in the [J language](https://www.jsoftware.com/#/), or in general any APL language, would lend itself to a sort of automated reasoning.

I'm nowhere near there yet, though. It barely works!

## How to use
Oh, you actually want to try it? Tacitus is written in OCaml, a superb language for implementing languages. It's built with the package manager [opam](https://opam.ocaml.org/) and [dune](https://dune.build/), and relies on [`ocamllex`](https://dev.realworldocaml.org/parsing-with-ocamllex-and-menhir.html) for lexing and [`menhir`](https://gallium.inria.fr/~fpottier/menhir/) for parsing. Right now, what little that does work is in the command line interpreter. From the top-level directory, run the following command to build the interpreter:

```
$ dune utop src
```
At this point, you need to understand a little bit about J.  It's an unusual computer language in that it explictly names its keywords "nouns", which includes things like arrays, and "verbs", serving as functions and transformations on those arrays. Then you have "adverbs" which modify those verbs, analogous to higher-order functions. Keep in mind that this is only the tip of the iceberg. If this gets you a [little interested in APL languages](https://news.ycombinator.com/item?id=22831931), I'll be satisfied. Imagine a programmable mathematical notation!

Verbs can be _monadic_ (taking one argument) or _dyadic_ (taking two). As an example, take `%`. In a monadic context, it's the "Reciprocal" verb. So `% 2.0 <--> 0.5`:

```
utop # Interp.Main.tacitus "% 2.0";;
- : Interp.Ast.expr = Interp.Ast.LiteralNoun (Interp.Ast.FArray [0.5])
```

However, in a _dyadic_ context, it can mean "Divison":
```
utop # Interp.Main.tacitus "7.0 % 2.0";;
- : Interp.Ast.expr = Interp.Ast.LiteralNoun (Interp.Ast.FArray [3.5])
```
Verbs can work on space-separated lists of values too:
```
utop # Interp.Main.tacitus "% 1 2 3";;
- : Interp.Ast.expr =
Interp.Ast.LiteralNoun (Interp.Ast.FArray [1.; 0.5; 0.333333333333333315])
```
So far this seems like a simple Lisp-esque applicative order for execution. But J supports a wonderful concept called _forks_ which encourage the tacit "point-free" style. For example, here's how to compute the average of a list of numbers (the "Hello, world" of APLs):

```
utop # Interp.Main.tacitus "[+/ % #] 1 2 3 4 5";;
- : Interp.Ast.expr = Interp.Ast.LiteralNoun (Interp.Ast.IArray [3])
```
How does this work? Well, first let's look at the individual verbs in this expression. `#` means "Tally" and gives you the length of an array. `+` means "Add" as you may guess, but we have `+/`. That `/` is an adverb that means "(functional language) Reduce". so that `+/ 1 2 3 --> 1 + 2 + 3 = 6`. So `+/` means "Sum".

Back to the fork. When you see three verbs chained together like `V1 V2 V3 N` applied to some noun `N`, that really means `(V1 N) V2 (V3 N)`. `V2` has to be a dyadic verb. So in words, `+/ % #` means "take the sum of a list, and take the length of a list, and divide the sum by the length to get the average". This is a _monadic fork_. And there dyadic forks, and verb trains of higher valence.

I haven't made any progress on the "optimization" part of this. Imagine that the verbs here were layers in a neural network, and that we could build optimizations or validations into the language itself! Perhaps someday.
