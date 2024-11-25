{
open Parser
open Printf
}

let white = [' ' '\t']+
let digit = ['0'-'9']
let intval = digit+
let negval = '_' intval
let floatval = digit+ '.' digit*
let negfloatval = '_' floatval
let ints = (negval | intval)+
let floats = (negfloatval | floatval)+
let letter = ['a'-'z' 'A'-'Z']
let identifier = letter+

rule read = 
        parse
        | white { read lexbuf }
        | "=" { EQUAL }
        | "|" { PIPE }
        | "!" { BANG }
        | ":" { COLON }
        | ";" { SEMICOLON }
        | "^" { CARET }
        | "^." { CARET1 }
        | "<" { LT }
        | "<." { LT1 }
        | "<:" { LT2 }
        | ">" { GT }
        | ">." { GT1 }
        | ">:" { GT2 }
        | "$" { DOLLAR }
        | "*" { STAR }
        | "*." { STAR1 }
        | "*:" { STAR2 }
        | "#" { POUND }
        | "+" { PLUS }
        | "+." { PLUS1 }
        | "+:" { PLUS2 }
        | "-" { MINUS }
        | "-." { MINUS1 }
        | "-:" { MINUS2 }
        | "%" { PERCENT }
        | "%." { PERCENT1 }
        | "%:" { PERCENT2 }
        | "," { COMMA }
        | '\\' { BACKSLASH }
        | "/" { SLASH }
        | "~" { TILDE }
        | "&" { AMP }
        | "@" { AT }
        | "@:" { AT2 }
        | "(" { LPAREN }
        | ")" { RPAREN }
        | "[" { LBRACE }
        | "{" { LBRACK }
        | "]" { RBRACE }
        | "}" { RBRACK }
        | identifier { IDENT (Lexing.lexeme lexbuf) }
        | intval { INT (int_of_string (Lexing.lexeme lexbuf)) }
        | floatval { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
        | negfloatval { FLOAT (-1.0 *. (float_of_string(String.sub (Lexing.lexeme lexbuf) 1 (String.length (Lexing.lexeme lexbuf) - 1))))  }
        | negval { INT (-1*int_of_string(String.sub (Lexing.lexeme lexbuf) 1 (String.length (Lexing.lexeme lexbuf) - 1)))  }
        | _ as c {printf "Unknown! %c\n" c; read lexbuf}
        | eof { EOF }
