(module
  (memory 1)
  (func (result i32)
    (i32.const 4)
    (i32.const 8)
    (i32.store)
    (i32.const 4)
    (i32.load))
)