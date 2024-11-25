(lang dune 3.13)
(using menhir 3.0)

(name tacitus)

(generate_opam_files true)

(source
 (github "diffeo-christopher/tacitus"))

(authors "Chris Jones")

(license LICENSE)

(package
 (name tacitus)
 (synopsis "Tacit array-based programming")
 (description "Inspired by J, an exploration of tacit programming")
 (depends ocaml dune))
