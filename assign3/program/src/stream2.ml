open Core
open List2.MyList

exception Unimplemented

module type Stream2 = sig
  type 'a stream = Stream of (unit -> 'a * 'a stream)
  val head : 'a stream -> 'a
  val tail : 'a stream -> 'a stream
  val take : 'a stream -> int -> 'a list * 'a stream
  val zip : 'a stream -> 'b stream -> ('a * 'b) stream
  val enumerate : 'a stream -> (int * 'a) stream
  val windows : 'a stream -> int -> ('a list) stream
end

module MyStream : Stream2 = struct
  type 'a stream = Stream of (unit -> 'a * 'a stream)

  let head (Stream f) =
    raise Unimplemented

  let tail (Stream f) =
    raise Unimplemented

  let rec take s n =
    raise Unimplemented

  let rec zip (Stream a) (Stream b) =
    raise Unimplemented

  let enumerate s =
    raise Unimplemented

  let rec windows s n =
    raise Unimplemented
end

module StreamTests(S : Stream2) = struct
  open S ;;

  let rec repeat (n : int) : int stream =
    Stream (fun () -> (n, repeat (n)))
  ;;
  let s = enumerate (repeat 1) in 
  assert (head s = (0, 1));
  assert (head (tail s) = (1, 1));
  assert (head (tail (tail s)) = (2, 1));
  assert (head (tail (tail (tail s))) = (3, 1));

  let s = zip (repeat 1) (repeat 2) in
  assert (head s = (1, 2));
  assert (head (tail s) = (1, 2));
  assert (head (tail (tail s)) = (1, 2));

  let s = enumerate (repeat 5) in
  let (l, s) = take s 2 in
  assert (l = Cons((0, 5), Cons((1, 5), Nil)));
  assert (head s = (2, 5));

  let s = windows (repeat 4) 3 in
  assert (head s = (Cons(4, Cons(4, Cons(4, Nil)))));
  assert (head (tail s) = (Cons(4, Cons(4, Cons(4, Nil)))))
  ;;
  
  let rec upfrom (n : int) : int stream =
    raise Unimplemented
  ;;

  let s = upfrom 5 in
  assert (head s = 5);
  assert (head (tail s) = 6);

  let s = enumerate (upfrom 5) in
  let (l, s) = take s 2 in
  assert (l = Cons((0, 5), Cons((1, 6), Nil)));
  assert (head s = (2, 7));

  let s = windows (upfrom 4) 3 in
  assert (head s = (Cons(4, Cons(5, Cons(6, Nil)))));
  assert (head (tail s) = (Cons(5, Cons(6, Cons(7, Nil)))))
  ;;

  let fib () : int stream =
    raise Unimplemented
  ;;

  let s = fib () in
  assert (head s = 0);
  assert (head (tail s) = 1);
  assert (head (tail (tail s)) = 1);
  assert (head (tail (tail (tail s))) = 2);
 
  let s = zip (fib ()) (repeat 2) in
  assert (head s = (0, 2));
  assert (head (tail s) = (1, 2));
  assert (head (tail (tail s)) = (1, 2));
  assert (head (tail (tail (tail s))) = (2,2));

end

module MyStreamTests = StreamTests(MyStream)
