(module
  (func (result i32)
    (loop
        (i32.const 1)
        (i32.const 3)
        (i32.add)
        (unreachable)))
)