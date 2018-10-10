open Core

exception Unimplemented

module type List2 = sig
  type 'a list = Cons of 'a * 'a list | Nil

  val foldr : ('a -> 'b -> 'b) -> 'b -> 'a list -> 'b
  val map : ('a -> 'b) -> 'a list -> 'b list
  val filter : ('a -> bool) -> 'a list -> 'a list
  val reduce : ('a -> 'a -> 'a) -> 'a list -> 'a option
  val combine_keys : ('a * 'b) list -> ('a * ('b list)) list
  val to_string : ('a -> string) -> 'a list -> string
end

module MyList : List2 = struct
  type 'a list = Cons of 'a * 'a list | Nil

  let rec foldr f base l =
    (* BEGIN STARTER *)
    raise Unimplemented
    (* END STARTER *)

  let to_string f l =
    (* BEGIN STARTER *)
    raise Unimplemented
    (* END STARTER *)

  let map f l =
    (* BEGIN STARTER *)
    raise Unimplemented
    (* END STARTER *)

  let rec filter f l =
    (* BEGIN STARTER *)
    raise Unimplemented
    (* END STARTER *)

  let reduce f l =
    (* BEGIN STARTER *)
    raise Unimplemented
    (* END STARTER *)

  let combine_keys l =
    (* BEGIN STARTER *)
    raise Unimplemented
    (* END STARTER *)
end

module ListTests(L : List2) = struct
  open L ;;

  let l = Cons(("b", 3), Cons(("a", 2), Cons(("a", 1), Nil))) in
  assert(
    (to_string (fun (s, n) -> Printf.sprintf "(%s, %s)" s (string_of_int n)) l)
    = "(b, 3) (a, 2) (a, 1) ");

  let l = combine_keys l in
  assert(
    l = Cons(("a", Cons(2, Cons(1, Nil))), Cons(("b", Cons(3, Nil)), Nil))
    || 
    l = Cons(("b", Cons(3, Nil)),  Cons(("a", Cons(2, Cons(1, Nil))), Nil))
  );

  let m = map (fun x -> x+1) (Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))))) in
  assert (m = Cons(2, Cons(3, Cons(4, Cons(5, Cons(6, Nil))))));

  let m = map (fun x -> x*2) (Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))))) in
  assert (m = Cons(2, Cons(4, Cons(6, Cons(8, Cons(10, Nil))))));

  let m = foldr (max) 0 (Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))))) in
  assert (m = 5);

  let m = foldr (+) 0 (Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))))) in
  assert (m = 15);

  let m = reduce (+) (Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))))) in
  assert (m = Some 15);

  let m = reduce (max) (Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))))) in
  assert (m = Some 5);

  let m = filter (fun x -> (x mod 2) = 0) (Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))))) in
  assert (m = Cons(2, Cons(4, Nil)));

  let m = filter (fun x -> (x < 0)) (Cons(-1, Cons(2, Cons(100, Cons(0, Cons(-5, Nil)))))) in
  assert (m = Cons(-1, Cons(-5, Nil)));

end

module MyListTests = ListTests(MyList)