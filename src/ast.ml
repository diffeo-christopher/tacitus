type adverb = 
        | Adverb of string

type conjunction =
        | Conjunction of string

type nounexpr =
        | Id of string
        | IArray of int list
        | FArray of float list

type verb = 
        | SimpleVerb of string
        | ModVerb of verb * adverb
        | Hook of verb * verb
        | Fork of verb * verb * verb
        | VerbalNounSuffix of nounexpr * conjunction * verb
        | VerbalNounPrefix of verb * conjunction * nounexpr
        | Conj of verb * conjunction * verb

type expr =
        | Assign of string * expr * expr
        | LiteralNoun of nounexpr
        | Monadic of verb * expr
        | Dyadic of expr * verb * expr
