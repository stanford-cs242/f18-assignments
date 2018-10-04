open Core

exception Unimplemented

module Type = struct
  type t =
    | Int
    | Fn of t * t
    | Product of t * t
    | Sum of t * t
  [@@deriving sexp_of, sexp, compare]

  let to_string ty = Sexp.to_string_hum (sexp_of_t ty)
end

module Expr = struct
  type binop = Add | Sub | Mul | Div
  [@@deriving sexp_of, sexp, compare]

  type direction = Left | Right
  [@@deriving sexp_of, sexp, compare]

  type t =
    | Var of string
    | Int of int
    | Binop of binop * t * t
    | Lam of string * Type.t * t
    | App of t * t
    | Pair of t * t
    | Project of t * direction
    | Inject of t * direction * Type.t
    | Case of t * (string * t) * (string * t)
  [@@deriving sexp_of, sexp, compare]

  (* substitute has the following mapping to the logic discussed in lecture:
   * substitute x e' e = [x -> e'] e
   *
   * You will need to implement substitution by defining a case for each
   * possible form of a term. For each line, delete the raise and add your
   * implementation. *)
  let rec substitute (x : string) (e' : t) (e : t) : t =
    match e with
    | Int n -> raise Unimplemented
    | Var x' -> raise Unimplemented
    | Binop (b, t1, t2) -> raise Unimplemented
    | Lam (x', tau, body) -> raise Unimplemented
    | App (t1, t2) -> raise Unimplemented
    | Pair (e1, e2) -> raise Unimplemented
    | Project (e, d) -> raise Unimplemented
    | Inject (e, d, tau) -> raise Unimplemented
    | Case (e, (x1, e1), (x2, e2)) -> raise Unimplemented

  let inline_tests () =
    let t1 = App(Lam("x", Type.Int, Var "x"), Var "y") in
    assert (substitute "x" (Int 0) t1 = t1);
    assert (substitute "y" (Int 0) t1 =
            App(Lam("x", Type.Int, Var "x"), Int 0));

    let t2 = Binop(Add, Var "x", Lam("x", Type.Int, Var "y")) in
    assert (substitute "x" (Int 0) t2 =
            Binop(Add, Int 0, Lam("x", Type.Int, Var "y")));
    assert (substitute "y" (Int 0) t2 =
            Binop(Add, Var "x", Lam("x", Type.Int, Int 0)))

  (* Uncomment the line below when you want to run the inline tests. *)
  (* let () = inline_tests () *)


  let to_string e = Sexp.to_string_hum (sexp_of_t e)
end
