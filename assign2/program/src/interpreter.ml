open Core
open Ast

type outcome =
  | Step of Expr.t
  | Val

exception RuntimeError of string
exception Unimplemented

(* You will implement the App, Binop, Pair, Project, Inject, and Case cases
   below. See the dynamics section for a specification on how the small step
   semantics should work. *)
let rec trystep e =
  match e with
  | Expr.Var _ -> raise (RuntimeError "Unreachable")
  | (Expr.Lam _ | Expr.Int _) -> Val
  | Expr.App (fn, arg) -> raise Unimplemented
  | Expr.Binop (binop, left, right) -> raise Unimplemented
  | Expr.Pair (e1, e2) -> raise Unimplemented
  | Expr.Project (e, dir) -> raise Unimplemented
  | Expr.Inject (e, dir, tau) -> raise Unimplemented
  | Expr.Case (e, (x1, e1), (x2, e2)) -> raise Unimplemented

let rec eval e =
  match trystep e with
  | Step e' -> eval e'
  | Val -> Ok e

let inline_tests () =
  let e1 = Expr.Binop(Expr.Add, Expr.Int 2, Expr.Int 3) in
  assert (trystep e1 = Step(Expr.Int 5));

  let e2 = Expr.App(Expr.Lam("x", Type.Int, Expr.Var "x"), Expr.Int 3) in
  assert (trystep e2 = Step(Expr.Int 3))

(* Uncomment the line below when you want to run the inline tests. *)
(* let () = inline_tests () *)
