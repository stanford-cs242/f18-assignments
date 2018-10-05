open Core

exception Unimplemented

type binop = Add | Sub

type expr =
  | Int of int
  | Bool of bool
  | Binop of binop * expr * expr
  | Iszero of expr
  | If of expr * expr * expr

type typ =
  | IntT
  | BoolT

let rec typecheck (e : expr) : typ option =
  match e with
  | Int n -> Some(IntT)
  | Bool n -> Some(BoolT)
  | Binop (_, e1, e2) ->
    (match (typecheck e1, typecheck e2) with
     | (Some IntT, Some IntT) -> Some IntT
     | _ -> None)
  | Iszero e ->
    (match typecheck e with
     | Some IntT -> Some BoolT
     | _ -> None)
  | If (e1, e2, e3) ->
    (match (typecheck e1, typecheck e2, typecheck e3) with
     | (Some BoolT, Some t1, Some t2) when t1 = t2 -> Some t1
     | _ -> None)
;;

assert (typecheck (Int 0) = Some IntT);
assert (typecheck (Binop(Add, Int 0, Bool false)) = None);
assert (typecheck (Iszero (Int 0)) = Some BoolT);

type result =
  | Step of expr
  | Val

let rec trystep (e : expr) : result =
  match e with
  | Int _ -> Val
  | Bool _ -> Val
  | Binop (binop, e1, e2) ->
    (match trystep e1 with
     | Step e1' -> Step(Binop(binop, e1', e2))
     | Val ->
       (match trystep e2 with
        | Step e2' -> Step(Binop(binop, e1, e2'))
        | Val ->
          let (Int n1, Int n2) = (e1, e2) in
          Step(Int(match binop with
            | Add -> n1 + n2
            | Sub -> n1 - n2))))
  | Iszero e ->
    (match trystep e with
    | Step e' -> Step(Iszero(e'))
    | Val ->
      let Int n = e in
      Step(Bool(n = 0)))
  | If (e1, e2, e3) ->
    (match trystep e1 with
     | Step e1' -> Step(If(e1', e2, e3))
     | Val ->
       let Bool b = e1 in
       Step(if b then e2 else e3))

let rec eval (e : expr) : expr =
  match trystep e with
  | Step e' -> eval e'
  | Val -> e
;;

assert (eval (Int 0) = (Int 0));
assert (eval (Binop(Add, Int 1, Int 2)) = (Int 3));
