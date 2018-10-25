(module
  (func (result i32) (local i32)
    (i32.const 0)
    (set_local 0)
    (loop
      (get_local 0)
      (i32.const 1)
      (i32.add)
      (set_local 0)

      (get_local 0)
      (i32.const 5)
      (i32.lt_s)
      (br_if 0))
    (get_local 0)))
