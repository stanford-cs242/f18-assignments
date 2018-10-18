(module
  (memory 1)
  (export "mem" (memory 0))

  ;; Stack-based Adler32 hash implementation.
  (func $adler32 (param $address i32) (param $len i32) (result i32)
    (local $a i32) (local $b i32) (local $i i32)

    ;; YOUR CODE GOES HERE
    (i32.const 0)
    )
  (export "adler32" (func $adler32))

  ;; Tree-based Adler32 hash implementation.
  (func $adler32v2 (param $address i32) (param $len i32) (result i32)
    (local $a i32) (local $b i32) (local $i i32)

    ;; YOUR CODE GOES HERE
    (i32.const 0)
    )

  (export "adler32v2" (func $adler32v2))

  ;; Initialize memory allocator. Creates the initial block assuming memory starts with
  ;; 1 page.
  (func $alloc_init
    (i32.store (i32.const 0) (i32.const 65528))
    (i32.store (i32.const 4) (i32.const 1)))
  (export "alloc_init" (func $alloc_init))

  ;; Frees a memory block by setting the free bit to 1.
  (func $free (param $address i32)
    (i32.store
      (i32.sub (get_local $address) (i32.const 4))
      (i32.const 1)))
  (export "free" (func $free))

  (func $alloc (param $len i32) (result i32)
    ;; YOUR CODE GOES HERE
    (unreachable)
    )
  (export "alloc" (func $alloc))

  )
