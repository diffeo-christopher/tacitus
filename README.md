# tacitus
Tacit array-based programming (alpha)

This code does almost nothing. It's woefully incomplete. Be thee warned.

I've been fascinated by [tacit programming](https://en.wikipedia.org/wiki/Tacit_programming), and not just for the compact and terse style. I wonder if tacit programming could be a vehicle for a kind of "smart compilation": the user chains together a large number of transformations or functions that are easy to understand--say, neural network layers, or matrices that are to be multiplied--and the language rearranges the sequence of operations in such a way that the final result is the same, but optimizations have been automatically carried out. This is usually described in Haskell circles as [equational reasoning](http://www-cs-students.stanford.edu/~blynn/haskell/eqreason.html), and I wonder if the tacit style in the [J language](https://www.jsoftware.com/#/), or in general any APL language, would lend itself to a sort of automated reasoning.

I'm nowhere near there yet, though. It barely works!

## How to use
Oh, you actually want to try it? Tacitus is written in OCaml and is built with the package manager [opam](https://opam.ocaml.org/) and [dune](https://dune.build/). Right now, what little that does work is in the command line interpreter. From the top-level directory:

```
$ dune utop src
──────────────────────────────────┬─────────────────────────────────────────────────────────────┬───────────────────────────────────
                                  │ Welcome to utop version 2.13.1 (using OCaml version 5.1.1)! │
                                  └─────────────────────────────────────────────────────────────┘

Type #utop_help for help about using utop.

─( 00:58:54 )─< command 0 >──────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # Interp.Main.tacitus "[+/ % #] 1 2 3 4 5";;
```

This should give you
```
- : Interp.Ast.expr = Interp.Ast.LiteralNoun (Interp.Ast.IArray [3])
─( 00:58:54 )─< command 1 >──────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop #
```
