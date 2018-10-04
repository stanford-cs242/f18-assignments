%{
  open Ast
  exception Unimplemented
%}

%token <string> VAR
%token EOF
%token ARROW
%token FATARROW
%token DOT
%token FN
%token LPAREN
%token RPAREN
%token COLON
%token PLUS
%token SUB
%token MUL
%token DIV
%token AS
%token INJECT
%token RIGHT
%token LEFT
%token RBRACE
%token LBRACE
%token COMMA
%token EQUAL
%token BAR
%token CASE
%token TY_INT
%token <int> INT

%left PLUS SUB
%left MUL DIV
%right ARROW

%start <Ast.Expr.t> main

%%

main:
| e = expr EOF { e }

expr:
| e1 = expr e2 = expr2 { Expr.App(e1, e2) }
| e = expr2 { e }

expr2:
| e1 = expr2 b = binop e2 = expr2 { Expr.Binop(b, e1, e2) }
| n = INT { Expr.Int(n) }
| FN LPAREN v = VAR COLON t = ty RPAREN DOT e = expr { Expr.Lam(v, t, e) }
| v = VAR { Expr.Var(v) }
| LPAREN e1 = expr2 COMMA e2 = expr2 RPAREN { Expr.Pair(e1, e2) }
| e = expr2 DOT d = dir { Expr.Project(e, d) }
| INJECT e = expr2 EQUAL d = dir AS t = ty { Expr.Inject(e, d, t) }
| CASE e = expr2 LBRACE LEFT LPAREN x1 = VAR RPAREN FATARROW e1 = expr2 BAR RIGHT LPAREN x2 = VAR RPAREN FATARROW e2 = expr2 RBRACE { Expr.Case(e, (x1, e1), (x2, e2)) }
| LPAREN e = expr RPAREN { e }

%inline binop:
| PLUS { Expr.Add }
| SUB { Expr.Sub }
| MUL { Expr.Mul }
| DIV { Expr.Div }

ty:
| TY_INT { Type.Int }
| t1 = ty ARROW t2 = ty { Type.Fn(t1, t2) }
| t1 = ty PLUS t2 = ty { Type.Sum(t1, t2) }
| t1 = ty MUL t2 = ty { Type.Product(t1, t2) }
| LPAREN t = ty RPAREN { t }

dir:
| LEFT {Expr.Left}
| RIGHT {Expr.Right}
