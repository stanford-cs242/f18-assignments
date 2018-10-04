open Core

module Type : sig
  type t =
    | Int
    | Fn of t * t
    | Product of t * t
    | Sum of t * t
  [@@deriving sexp_of, sexp, compare]

  val to_string : t -> string
end

module Expr : sig
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

  val to_string : t -> string

  val substitute : string -> t -> t -> t
end
