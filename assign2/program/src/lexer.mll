{
  open Parser
  exception Error of string
}

rule token = parse
| "(*" _* "*)" { token lexbuf }
| [' ' '\t' '\n'] { token lexbuf }
| '.' { DOT }
| '(' { LPAREN }
| ')' { RPAREN }
| "fn" { FN }
| "int" { TY_INT }
| "->" { ARROW }
| "=>" { FATARROW }
| ":" { COLON }
| '+' { PLUS }
| '-' { SUB }
| ',' { COMMA }
| "as" { AS }
| "inj" { INJECT }
| '*' { MUL }
| '/' { DIV }
| 'R' { RIGHT }
| 'L' { LEFT }
| '|' { BAR }
| '{' { LBRACE }
| '}' { RBRACE }
| '=' { EQUAL }
| "case" { CASE }
| ['a'-'z''A'-'Z']['a'-'z''A'-'Z''0'-'9']* as v { VAR v }
| ['0'-'9']+ as i { INT (int_of_string i) }
| '-'['0'-'9']+ as i { INT (int_of_string i) }
| eof { EOF }
| _ { raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }
