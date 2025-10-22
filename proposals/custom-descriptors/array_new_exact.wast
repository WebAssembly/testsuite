(module
  (type $a1 (array i8))
  (type $a2 (array (mut (ref null func))))

  (data "abc")
  (elem funcref)


  (func (result (ref (exact $a1)))
    (array.new $a1 (i32.const 0) (i32.const 0))
  )
  (func (result (ref (exact $a1)))
    (array.new_default $a1 (i32.const 0))
  )
  (func (result (ref (exact $a1)))
    (array.new_fixed $a1 3 (i32.const 0) (i32.const 1) (i32.const 2))
  )
  (func (result (ref (exact $a1)))
    (array.new_data $a1 0 (i32.const 0) (i32.const 0))
  )
  (func (result (ref (exact $a2)))
    (array.new_elem $a2 0 (i32.const 0) (i32.const 0))
  )
)
