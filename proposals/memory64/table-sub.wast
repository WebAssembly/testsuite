(module
  (type $t (func))
  (table $t1 10 (ref null func))
  (table $t2 10 (ref null $t))
  (elem $el funcref)
  (func $f
    (table.init $t1 $el (i32.const 0) (i32.const 1) (i32.const 2))
    (table.copy $t1 $t2 (i32.const 0) (i32.const 1) (i32.const 2))
  )
)

(assert_invalid
  (module
    (table $t1 10 funcref)
    (table $t2 10 externref)
    (func $f
      (table.copy $t1 $t2 (i32.const 0) (i32.const 1) (i32.const 2))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (table $t 10 funcref)
    (elem $el externref)
    (func $f
      (table.init $t $el (i32.const 0) (i32.const 1) (i32.const 2))
    )
  )
  "type mismatch"
)
