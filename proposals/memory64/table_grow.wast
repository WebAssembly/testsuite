(module
  (table $t 0 externref)

  (func (export "get") (param $i i32) (result externref) (table.get $t (local.get $i)))
  (func (export "set") (param $i i32) (param $r externref) (table.set $t (local.get $i) (local.get $r)))

  (func (export "grow") (param $sz i32) (param $init externref) (result i32)
    (table.grow $t (local.get $init) (local.get $sz))
  )
  (func (export "grow-abbrev") (param $sz i32) (param $init externref) (result i32)
    (table.grow (local.get $init) (local.get $sz))
  )
  (func (export "size") (result i32) (table.size $t))

  (table $t64 i64 0 externref)

  (func (export "get-t64") (param $i i64) (result externref) (table.get $t64 (local.get $i)))
  (func (export "set-t64") (param $i i64) (param $r externref) (table.set $t64 (local.get $i) (local.get $r)))
  (func (export "grow-t64") (param $sz i64) (param $init externref) (result i64)
    (table.grow $t64 (local.get $init) (local.get $sz))
  )
  (func (export "size-t64") (result i64) (table.size $t64))
)

(assert_return (invoke "size") (i32.const 0))
(assert_trap (invoke "set" (i32.const 0) (ref.extern 2)) "out of bounds table access")
(assert_trap (invoke "get" (i32.const 0)) "out of bounds table access")

(assert_return (invoke "grow" (i32.const 1) (ref.null extern)) (i32.const 0))
(assert_return (invoke "size") (i32.const 1))
(assert_return (invoke "get" (i32.const 0)) (ref.null extern))
(assert_return (invoke "set" (i32.const 0) (ref.extern 2)))
(assert_return (invoke "get" (i32.const 0)) (ref.extern 2))
(assert_trap (invoke "set" (i32.const 1) (ref.extern 2)) "out of bounds table access")
(assert_trap (invoke "get" (i32.const 1)) "out of bounds table access")

(assert_return (invoke "grow-abbrev" (i32.const 4) (ref.extern 3)) (i32.const 1))
(assert_return (invoke "size") (i32.const 5))
(assert_return (invoke "get" (i32.const 0)) (ref.extern 2))
(assert_return (invoke "set" (i32.const 0) (ref.extern 2)))
(assert_return (invoke "get" (i32.const 0)) (ref.extern 2))
(assert_return (invoke "get" (i32.const 1)) (ref.extern 3))
(assert_return (invoke "get" (i32.const 4)) (ref.extern 3))
(assert_return (invoke "set" (i32.const 4) (ref.extern 4)))
(assert_return (invoke "get" (i32.const 4)) (ref.extern 4))
(assert_trap (invoke "set" (i32.const 5) (ref.extern 2)) "out of bounds table access")
(assert_trap (invoke "get" (i32.const 5)) "out of bounds table access")

;; Similar to above but for t64
(assert_return (invoke "size-t64") (i64.const 0))
(assert_trap (invoke "set-t64" (i64.const 0) (ref.extern 2)) "out of bounds table access")
(assert_trap (invoke "get-t64" (i64.const 0)) "out of bounds table access")

(assert_return (invoke "grow-t64" (i64.const 1) (ref.null extern)) (i64.const 0))
(assert_return (invoke "size-t64") (i64.const 1))
(assert_return (invoke "get-t64" (i64.const 0)) (ref.null extern))
(assert_return (invoke "set-t64" (i64.const 0) (ref.extern 2)))
(assert_return (invoke "get-t64" (i64.const 0)) (ref.extern 2))
(assert_trap (invoke "set-t64" (i64.const 1) (ref.extern 2)) "out of bounds table access")
(assert_trap (invoke "get-t64" (i64.const 1)) "out of bounds table access")

(assert_return (invoke "grow-t64" (i64.const 4) (ref.extern 3)) (i64.const 1))
(assert_return (invoke "size-t64") (i64.const 5))
(assert_return (invoke "get-t64" (i64.const 0)) (ref.extern 2))
(assert_return (invoke "set-t64" (i64.const 0) (ref.extern 2)))
(assert_return (invoke "get-t64" (i64.const 0)) (ref.extern 2))
(assert_return (invoke "get-t64" (i64.const 1)) (ref.extern 3))
(assert_return (invoke "get-t64" (i64.const 4)) (ref.extern 3))
(assert_return (invoke "set-t64" (i64.const 4) (ref.extern 4)))
(assert_return (invoke "get-t64" (i64.const 4)) (ref.extern 4))
(assert_trap (invoke "set-t64" (i64.const 5) (ref.extern 2)) "out of bounds table access")
(assert_trap (invoke "get-t64" (i64.const 5)) "out of bounds table access")

;; Reject growing to size outside i32 value range
(module
  (table $t 0x10 funcref)
  (elem declare func $f)
  (func $f (export "grow") (result i32)
    (table.grow $t (ref.func $f) (i32.const 0xffff_fff0))
  )
)

(assert_return (invoke "grow") (i32.const -1))


(module
  (table $t 0 externref)
  (func (export "grow") (param i32) (result i32)
    (table.grow $t (ref.null extern) (local.get 0))
  )
)

(assert_return (invoke "grow" (i32.const 0)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 1)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 0)) (i32.const 1))
(assert_return (invoke "grow" (i32.const 2)) (i32.const 1))
(assert_return (invoke "grow" (i32.const 800)) (i32.const 3))


(module
  (table $t 0 10 externref)
  (func (export "grow") (param i32) (result i32)
    (table.grow $t (ref.null extern) (local.get 0))
  )
)

(assert_return (invoke "grow" (i32.const 0)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 1)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 1)) (i32.const 1))
(assert_return (invoke "grow" (i32.const 2)) (i32.const 2))
(assert_return (invoke "grow" (i32.const 6)) (i32.const 4))
(assert_return (invoke "grow" (i32.const 0)) (i32.const 10))
(assert_return (invoke "grow" (i32.const 1)) (i32.const -1))
(assert_return (invoke "grow" (i32.const 0x10000)) (i32.const -1))


(module
  (table $t 10 funcref)
  (func (export "grow") (param i32) (result i32)
    (table.grow $t (ref.null func) (local.get 0))
  )
  (elem declare func 1)
  (func (export "check-table-null") (param i32 i32) (result funcref)
    (local funcref)
    (local.set 2 (ref.func 1))
    (block
      (loop
        (local.set 2 (table.get $t (local.get 0)))
        (br_if 1 (i32.eqz (ref.is_null (local.get 2))))
        (br_if 1 (i32.ge_u (local.get 0) (local.get 1)))
        (local.set 0 (i32.add (local.get 0) (i32.const 1)))
        (br_if 0 (i32.le_u (local.get 0) (local.get 1)))
      )
    )
    (local.get 2)
  )
)

(assert_return (invoke "check-table-null" (i32.const 0) (i32.const 9)) (ref.null func))
(assert_return (invoke "grow" (i32.const 10)) (i32.const 10))
(assert_return (invoke "check-table-null" (i32.const 0) (i32.const 19)) (ref.null func))


(module $Tgt
  (table (export "table") 1 funcref) ;; initial size is 1
  (func (export "grow") (result i32) (table.grow (ref.null func) (i32.const 1)))
)
(register "grown-table" $Tgt)
(assert_return (invoke $Tgt "grow") (i32.const 1)) ;; now size is 2
(module $Tgit1
  ;; imported table limits should match, because external table size is 2 now
  (table (export "table") (import "grown-table" "table") 2 funcref)
  (func (export "grow") (result i32) (table.grow (ref.null func) (i32.const 1)))
)
(register "grown-imported-table" $Tgit1)
(assert_return (invoke $Tgit1 "grow") (i32.const 2)) ;; now size is 3
(module $Tgit2
  ;; imported table limits should match, because external table size is 3 now
  (import "grown-imported-table" "table" (table 3 funcref))
  (func (export "size") (result i32) (table.size))
)
(assert_return (invoke $Tgit2 "size") (i32.const 3))


;; Type errors

(assert_invalid
  (module
    (table $t 0 externref)
    (func $type-init-size-empty-vs-i32-externref (result i32)
      (table.grow $t)
    )
  )
  "type mismatch"
)
(assert_invalid
  (module
    (table $t 0 externref)
    (func $type-size-empty-vs-i32 (result i32)
      (table.grow $t (ref.null extern))
    )
  )
  "type mismatch"
)
(assert_invalid
  (module
    (table $t 0 externref)
    (func $type-init-empty-vs-externref (result i32)
      (table.grow $t (i32.const 1))
    )
  )
  "type mismatch"
)
(assert_invalid
  (module
    (table $t 0 externref)
    (func $type-size-f32-vs-i32 (result i32)
      (table.grow $t (ref.null extern) (f32.const 1))
    )
  )
  "type mismatch"
)
(assert_invalid
  (module
    (table $t 0 funcref)
    (func $type-init-externref-vs-funcref (param $r externref) (result i32)
      (table.grow $t (local.get $r) (i32.const 1))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (table $t 1 externref)
    (func $type-result-i32-vs-empty
      (table.grow $t (ref.null extern) (i32.const 0))
    )
  )
  "type mismatch"
)
(assert_invalid
  (module
    (table $t 1 externref)
    (func $type-result-i32-vs-f32 (result f32)
      (table.grow $t (ref.null extern) (i32.const 0))
    )
  )
  "type mismatch"
)
