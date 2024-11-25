%{
open Ast
%}

%token <int> INT
%token <string> IDENT
%token <float> FLOAT
%token PLUS PLUS1 PLUS2 
%token MINUS MINUS1 MINUS2 POUND
%token STAR SLASH BACKSLASH
%token STAR1 STAR2 BANG COLON
%token LT LT1 LT2 GT GT1 GT2 PERCENT
%token PERCENT1 PERCENT2
%token CARET CARET1 PIPE DOLLAR
%token EQUAL COMMA TILDE AMP AT AT2
%token LPAREN RPAREN LBRACE RBRACE
%token LBRACK RBRACK SEMICOLON
%token EOF

%right STAR2 STAR1 STAR POUND PLUS2 PLUS1 PLUS PIPE 
%right PERCENT2 PERCENT1 PERCENT
%right MINUS2 MINUS1 MINUS LT2 LT1 LT LBRACK LBRACE 
%right GT2 GT1 GT DOLLAR COMMA COLON CARET1 CARET BANG

%nonassoc high

%start <Ast.expr> sentence

%%

%inline simpleverb:
        | PIPE {SimpleVerb "Pipe"}
        | CARET {SimpleVerb "Caret"}
        | CARET1 {SimpleVerb "Ln"}
        | LT {SimpleVerb "Lessthan"}
        | LT1 {SimpleVerb "Floor"}
        | LT2 {SimpleVerb "Decrement"}
        | GT {SimpleVerb "Greaterthan"}
        | GT1 {SimpleVerb "Ceiling"}
        | GT2 {SimpleVerb "Increment"}
        | DOLLAR {SimpleVerb "Shape"}
        | STAR {SimpleVerb "Star"}
        | STAR1 {SimpleVerb "ToPolar"}
        | STAR2 {SimpleVerb "Square"}
        | PERCENT {SimpleVerb "Divide"}
        | PERCENT1 {SimpleVerb "MatrixInverse"}
        | PERCENT2 {SimpleVerb "Sqrt"}
        | POUND {SimpleVerb "Tally"}
        | PLUS {SimpleVerb "Add"}
        | PLUS1 {SimpleVerb "GetRealImag"}
        | PLUS2 {SimpleVerb "Double"}
        | MINUS {SimpleVerb "Minus"}
        | MINUS1 {SimpleVerb "Not"}
        | MINUS2 {SimpleVerb "Halve"}
        | COMMA {SimpleVerb "Comma"}
        ;

%inline adverb:
        | SLASH {Adverb "Insert"}
        | TILDE {Adverb "Reflex"}
        | BACKSLASH {Adverb "Prefix"}
        ;

%inline conjunction:
        | AT {Conjunction "Atop"}
        | AT2 {Conjunction "TacitCompose"}
        | AMP {Conjunction "Compose"}
        ;

sentence:
        | e = expr EOF { e }
        ;

nounexpr:
        | xs = nonempty_list(INT) {IArray xs}
        | fs = nonempty_list(FLOAT) {FArray fs}
        | var = IDENT {Id var}
        ;

dyadicexpr:
        | left = expr; dv = verb; right = expr %prec high {Dyadic(left, dv, right)}
        ;

monadicexpr:
        | mv = verb; n = expr %prec high {Monadic(mv, n)}
        ;

verb:
        | v = simpleverb {v}
        | v = simpleverb; adv = adverb {ModVerb(v, adv)}
        | LBRACK; f = verb; g = verb; RBRACK {Hook(f, g)}
        | LBRACE; f = verb; g = verb; h = verb; RBRACE; {Fork(f, g, h)}
        | BANG; e = nounexpr; c = conjunction; v = simpleverb; BANG {VerbalNounSuffix(e,c,v)}
        | BANG; v = simpleverb; c = conjunction; e = nounexpr; BANG {VerbalNounPrefix(v,c,e)}
        | COLON; e1 = verb; c = conjunction; e2 = verb; COLON {Conj(e1, c, e2)}
        ;

(*  
        | e1 = expr; COLON; c = conjunction; COLON; e2 = expr; FEED; n = nounexpr {Conj(e1, c, e2, n)}
        | BANG; u = simpleverb; c = conjunction; v = simpleverb; BANG {SimpleConj(u, c, v)}
        | v = verb {Verb v}
*)
expr:
        | name = IDENT; EQUAL; e1 = expr; SEMICOLON; e2 = expr; SEMICOLON {Assign(name, e1, e2)}
        | m = monadicexpr {m}
        | d = dyadicexpr {d}
        | id = nounexpr {LiteralNoun id}
        | LPAREN; e = expr; RPAREN { e }
        ;
