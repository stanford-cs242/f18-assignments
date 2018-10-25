(module
  (func (result i32) (local i32)
    (i32.const 3)
    (call 1))

  (func (result i32) (param i32)
    (get_local 0)
    (i32.const 5)
    (i32.add))
)