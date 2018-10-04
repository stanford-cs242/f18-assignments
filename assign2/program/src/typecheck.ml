open Core
open Result.Monad_infix
open Ast

exception Unimplemented

(* You need to implement the statics for the three remaining cases below,
 * Var, Lam, and App. We have provided you with an implementation for Int
 * and Binop that you may refer to. See code_examples.ml for more info
 * on the >>= operator. *)
let rec typecheck_term (env : Type.t String.Map.t) (e : Expr.t) : (Type.t, string) Result.t =
  match e with
  | Expr.Int _ -> Ok Type.Int
  | Expr.Binop (_, e1, e2) ->
    typecheck_term env e1
    >>= fun tau1 ->
    typecheck_term env e2
    >>= fun tau2 ->
    (match (tau1, tau2) with
     | (Type.Int, Type.Int) -> Ok Type.Int
     | _ -> Error ("One of the binop operands is not an int"))
  | Expr.Var x -> raise Unimplemented
  | Expr.Lam(x, arg_tau, e') -> raise Unimplemented
  | Expr.App (fn, arg) -> raise Unimplemented

let typecheck t = typecheck_term String.Map.empty t

let inline_tests () =
  let e1 = Expr.Lam ("x", Type.Int, Expr.Var "x") in
  assert (typecheck e1 = Ok(Type.Fn(Type.Int, Type.Int)));

  let e2 = Expr.Lam ("x", Type.Int, Expr.Var "y") in
  assert (Result.is_error (typecheck e2));

  let t3 = Expr.App (e1, Expr.Int 3) in
  assert (typecheck t3 = Ok(Type.Int));

  let t4 = Expr.App (t3, Expr.Int 3) in
  assert (Result.is_error (typecheck t4));

  let t5 = Expr.Binop (Expr.Add, Expr.Int 0, e1) in
  assert (Result.is_error (typecheck t5))

(* Uncomment the line below when you want to run the inline tests. *)
(* let () = inline_tests () *)
