(module
  (type $ft (func (result i32)))
  (type $st (struct (field i16)))
  (type $at (array i8))

  (table 10 anyref)

  (elem declare func $f)
  (func $f (result i32) (i32.const 9))

  (func (export "init") (param $x externref)
    (table.set (i32.const 0) (ref.null any))
    (table.set (i32.const 1) (i31.new (i32.const 7)))
    (table.set (i32.const 2) (struct.new $st (i32.const 6) (rtt.canon $st)))
    (table.set (i32.const 3) (array.new $at (i32.const 5) (i32.const 1) (rtt.canon $at)))
    (table.set (i32.const 4) (ref.func $f))
    (table.set (i32.const 5) (rtt.canon $ft))
    (table.set (i32.const 6) (local.get $x))
  )

  (func (export "br_on_non_null") (param $i i32) (result i32)
    (block $l (result (ref any))
      (br_on_non_null $l (table.get (local.get $i)))
      (return (i32.const 0))
    )
    (return (i32.const -1))
  )
  (func (export "br_on_non_i31") (param $i i32) (result i32)
    (block $l (result anyref)
      (br_on_non_i31 $l (table.get (local.get $i)))
      (return (i31.get_u))
    )
    (return (i32.const -1))
  )
  (func (export "br_on_non_data") (param $i i32) (result i32)
    (block $l (result anyref)
      (br_on_non_data $l (table.get (local.get $i)))
      (block $l2 (param dataref) (result (ref $st))
        (block $l3 (param dataref) (result (ref $at))
          (br_on_cast $l2 (rtt.canon $st))
          (br_on_cast $l3 (rtt.canon $at))
          (return (i32.const -2))
        )
        (return (array.get_u $at (i32.const 0)))
      )
      (return (struct.get_s $st 0))
    )
    (return (i32.const -1))
  )
  (func (export "br_on_non_func") (param $i i32) (result i32)
    (block $l (result anyref)
      (br_on_non_func $l (table.get (local.get $i)))
      (ref.cast (rtt.canon $ft))
      (return (call_ref))
    )
    (return (i32.const -1))
  )
)

(invoke "init" (ref.extern 0))

(assert_return (invoke "br_on_non_null" (i32.const 0)) (i32.const 0))
(assert_return (invoke "br_on_non_null" (i32.const 1)) (i32.const -1))
(assert_return (invoke "br_on_non_null" (i32.const 2)) (i32.const -1))
(assert_return (invoke "br_on_non_null" (i32.const 3)) (i32.const -1))
(assert_return (invoke "br_on_non_null" (i32.const 4)) (i32.const -1))
(assert_return (invoke "br_on_non_null" (i32.const 5)) (i32.const -1))
(assert_return (invoke "br_on_non_null" (i32.const 6)) (i32.const -1))

(assert_return (invoke "br_on_non_i31" (i32.const 0)) (i32.const -1))
(assert_return (invoke "br_on_non_i31" (i32.const 1)) (i32.const 7))
(assert_return (invoke "br_on_non_i31" (i32.const 2)) (i32.const -1))
(assert_return (invoke "br_on_non_i31" (i32.const 3)) (i32.const -1))
(assert_return (invoke "br_on_non_i31" (i32.const 4)) (i32.const -1))
(assert_return (invoke "br_on_non_i31" (i32.const 5)) (i32.const -1))
(assert_return (invoke "br_on_non_i31" (i32.const 6)) (i32.const -1))

(assert_return (invoke "br_on_non_data" (i32.const 0)) (i32.const -1))
(assert_return (invoke "br_on_non_data" (i32.const 1)) (i32.const -1))
(assert_return (invoke "br_on_non_data" (i32.const 2)) (i32.const 6))
(assert_return (invoke "br_on_non_data" (i32.const 3)) (i32.const 5))
(assert_return (invoke "br_on_non_data" (i32.const 4)) (i32.const -1))
(assert_return (invoke "br_on_non_data" (i32.const 5)) (i32.const -1))
(assert_return (invoke "br_on_non_data" (i32.const 6)) (i32.const -1))

(assert_return (invoke "br_on_non_func" (i32.const 0)) (i32.const -1))
(assert_return (invoke "br_on_non_func" (i32.const 1)) (i32.const -1))
(assert_return (invoke "br_on_non_func" (i32.const 2)) (i32.const -1))
(assert_return (invoke "br_on_non_func" (i32.const 3)) (i32.const -1))
(assert_return (invoke "br_on_non_func" (i32.const 4)) (i32.const 9))
(assert_return (invoke "br_on_non_func" (i32.const 5)) (i32.const -1))
(assert_return (invoke "br_on_non_func" (i32.const 6)) (i32.const -1))
