;; Validation

(module
  (rec
    (type $empty (descriptor $empty.desc) (struct))
    (type $one (descriptor $one.desc) (struct (field i32)))
    (type $pair (descriptor $pair.desc) (struct (field i32 i64)))
    (type $empty.desc (describes $empty) (struct))
    (type $one.desc (describes $one) (struct))
    (type $pair.desc (describes $pair) (struct))
  )

  (func (param (ref null (exact $empty.desc))) (result (ref (exact $empty)))
    (struct.new $empty (local.get 0))
  )
  (func (param (ref null (exact $empty.desc))) (result (ref (exact $empty)))
    (struct.new_default $empty (local.get 0))
  )
  (func (param (ref (exact $empty.desc))) (result (ref (exact $empty)))
    (struct.new $empty (local.get 0))
  )
  (func (param (ref (exact $empty.desc))) (result (ref (exact $empty)))
    (struct.new_default $empty (local.get 0))
  )
  (func (result (ref (exact $empty)))
    (struct.new $empty (ref.null none))
  )
  (func (result (ref (exact $empty)))
    (struct.new_default $empty (ref.null none))
  )
  (func (result (ref (exact $empty)))
    (struct.new $empty (unreachable))
  )
  (func (result (ref (exact $empty)))
    (struct.new_default $empty (unreachable))
  )

  (func (param (ref null (exact $one.desc))) (result (ref (exact $one)))
    (struct.new $one (i32.const 0) (local.get 0))
  )
  (func (param (ref null (exact $one.desc))) (result (ref (exact $one)))
    (struct.new_default $one (local.get 0))
  )
  (func (param (ref (exact $one.desc))) (result (ref (exact $one)))
    (struct.new $one (i32.const 0) (local.get 0))
  )
  (func (param (ref (exact $one.desc))) (result (ref (exact $one)))
    (struct.new_default $one (local.get 0))
  )
  (func (result (ref (exact $one)))
    (struct.new $one (i32.const 0) (ref.null none))
  )
  (func (result (ref (exact $one)))
    (struct.new_default $one (ref.null none))
  )
  (func (result (ref (exact $one)))
    (struct.new $one (i32.const 0) (unreachable))
  )
  (func (result (ref (exact $one)))
    (struct.new_default $one (unreachable))
  )

  (func (param (ref null (exact $pair.desc))) (result (ref (exact $pair)))
    (struct.new $pair (i32.const 1) (i64.const 2) (local.get 0))
  )
  (func (param (ref null (exact $pair.desc))) (result (ref (exact $pair)))
    (struct.new_default $pair (local.get 0))
  )
  (func (param (ref (exact $pair.desc))) (result (ref (exact $pair)))
    (struct.new $pair (i32.const 1) (i64.const 2) (local.get 0))
  )
  (func (param (ref (exact $pair.desc))) (result (ref (exact $pair)))
    (struct.new_default $pair (local.get 0))
  )
  (func (result (ref (exact $pair)))
    (struct.new $pair (i32.const 1) (i64.const 2) (ref.null none))
  )
  (func (result (ref (exact $pair)))
    (struct.new_default $pair (ref.null none))
  )
  (func (result (ref (exact $pair)))
    (struct.new $pair (i32.const 1) (i64.const 2) (unreachable))
  )
  (func (result (ref (exact $pair)))
    (struct.new_default $pair (unreachable))
  )
)

(module
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (descriptor $c) (struct))
    (type $c (describes $b) (descriptor $d) (struct))
    (type $d (describes $c) (struct))
  )

  (global $d (ref (exact $d)) (struct.new $d))
  (global $c (ref (exact $c)) (struct.new $c (global.get $d)))
  (global $b (ref (exact $b)) (struct.new $b (global.get $c)))
  (global $a (ref (exact $a)) (struct.new $a (global.get $b)))

  (func (result (ref (exact $a)))
    (struct.new $a
      (struct.new $b
        (struct.new $c
          (struct.new $d)
        )
      )
    )
  )
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct (field i32)))
      (type $b (describes $a) (struct))
    )
    ;; Missing descriptor.
    (func (result anyref)
      (struct.new $a (i32.const 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $struct (struct (field i32)))
      (type $a (descriptor $b) (struct (field i32)))
      (type $b (describes $a) (struct))
    )
    ;; Descriptor provided when allocating a type without a descriptor.
    (func (result anyref)
      (struct.new $struct (i32.const 0) (struct.new $b))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct (field i32)))
      (type $b (describes $a) (struct))
    )
    ;; Descriptor does not have expected type.
    (func (param (ref struct)) (result anyref)
      (struct.new $a (i32.const 0) (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct (field i32)))
      (type $b (describes $a) (struct))
    )
    ;; Descriptor must be exact.
    (func (param (ref $b)) (result anyref)
      (struct.new $a (i32.const 0) (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct (field i32)))
      (type $b (describes $a) (struct))
    )
    ;; Allocated type cannot be used as descriptor.
    (func (param (ref (exact $a))) (result anyref)
      (struct.new $a (i32.const 0) (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct (field i32)))
      (type $b (describes $a) (struct))
      (type $c (descriptor $d) (struct))
      (type $d (describes $c) (struct))
    )
    ;; Unrelated descriptor cannot be used as desciptor.
    (func (param (ref (exact $d))) (result anyref)
      (struct.new $a (i32.const 0) (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (sub (descriptor $b) (struct (field i32))))
      (type $b (sub (describes $a) (struct)))
      (type $c (sub $a (descriptor $d) (struct (field i32))))
      (type $d (sub $b (describes $c) (struct)))
    )
    ;; Subtype descriptor cannot be used as desciptor.
    (func (param (ref (exact $d))) (result anyref)
      (struct.new $a (i32.const 0) (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (sub (descriptor $b) (struct (field i32))))
      (type $b (sub (describes $a) (struct)))
      (type $c (sub $a (descriptor $d) (struct (field i32))))
      (type $d (sub $b (describes $c) (struct)))
    )
    ;; Supertype descriptor cannot be used as desciptor.
    (func (param (ref (exact $b))) (result anyref)
      (struct.new $c (i32.const 0) (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct (field i32)))
      (type $b (describes $a) (struct))
    )
    ;; The correct descriptor is supplied, but the fields are missing.
    (func (result anyref)
      (struct.new $a (struct.new $b))
    )
  )
  "type mismatch"
)

;; Execution

(module
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct))
  )
  (rec
    (type $pair (descriptor $pair.desc) (struct (field i32 i64)))
    (type $pair.desc (describes $pair) (struct (field f32)))
  )
  (rec
    (type $one (descriptor $two) (struct))
    (type $two (describes $one) (descriptor $three) (struct))
    (type $three (describes $two) (struct))
  )

  (global $b (export "b") (ref null (exact $b)) (struct.new $b))
  (global $a (export "a") (ref (exact $a)) (struct.new $a (global.get $b)))

  (global $null-b (ref null (exact $b)) (ref.null none))

  (func (export "new-new") (result (ref (exact $a)))
    (struct.new $a (struct.new $b))
  )

  (func (export "new-global") (result (ref (exact $a)))
    (struct.new $a (global.get $b))
  )

  (func (export "new-call") (result (ref (exact $a)))
    (struct.new $a (call $new-b))
  )

  (func $new-b (result (ref null (exact $b)))
    (struct.new $b)
  )

  (func (export "new-pair") (result (ref (exact $pair)))
    (struct.new $pair
      (i32.const 0)
      (i64.const 1)
      (struct.new $pair.desc
        (f32.const 2)
      )
    )
  )

  (func (export "new-chain") (result (ref (exact $one)))
    (struct.new $one
      (struct.new $two
        (struct.new $three)
      )
    )
  )

  (func (export "new-null") (result (ref (exact $a)))
    (struct.new $a (ref.null none))
  )

  (func (export "new-null-global") (result (ref (exact $a)))
    (struct.new $a (global.get $null-b))
  )

  (func (export "new-null-call") (result (ref (exact $a)))
    (struct.new $a (call $null))
  )

  (func $null (result (ref null (exact $b)))
    (ref.null none)
  )

  (func (export "new-null-pair") (result (ref (exact $pair)))
    (struct.new $pair
      (i32.const 0)
      (i64.const 1)
      (ref.null (exact $pair.desc))
    )
  )

  (func (export "new-null-chain-1") (result (ref (exact $one)))
    (struct.new $one
      (ref.null (exact $two))
    )
  )

  (func (export "new-null-chain-2") (result (ref (exact $one)))
    (struct.new $one
      (struct.new $two
        (ref.null (exact $three))
      )
    )
  )
)

(assert_return (get "b") (ref.struct))
(assert_return (invoke "new-new") (ref.struct))
(assert_return (invoke "new-global") (ref.struct))
(assert_return (invoke "new-call") (ref.struct))
(assert_return (invoke "new-pair") (ref.struct))
(assert_return (invoke "new-chain") (ref.struct))
(assert_trap (invoke "new-null") "null descriptor reference")
(assert_trap (invoke "new-null-global") "null descriptor reference")
(assert_trap (invoke "new-null-call") "null descriptor reference")
(assert_trap (invoke "new-null-pair") "null descriptor reference")
(assert_trap (invoke "new-null-chain-1") "null descriptor reference")
(assert_trap (invoke "new-null-chain-2") "null descriptor reference")

(assert_trap
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    (global (ref (exact $a)) (struct.new $a (ref.null none)))
  )
  "null descriptor reference"
)

(assert_trap
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    (global (ref (exact $a)) (struct.new $a (ref.null (exact $b))))
  )
  "null descriptor reference"
)

(assert_trap
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    (global (ref null (exact $b)) (ref.null none))
    (global (ref (exact $a)) (struct.new $a (global.get 0)))
  )
  "null descriptor reference"
)

;; Linking

(module $A
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct))
  )

  (global (export "b") (ref null (exact $b)) (struct.new $b))

  (global (export "null-b") (ref null (exact $b)) (ref.null none))

  (func (export "new-b") (result (ref null (exact $b)))
    (struct.new $b)
  )

  (func (export "new-null-b") (result (ref null (exact $b)))
    (ref.null none)
  )
)

(register "A")

(module $B
  ;; Add an extra type to make the type indices different between modules.
  (type $other (func))
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct))
  )

  (import "A" "b" (global $b (ref null (exact $b))))
  (import "A" "null-b" (global $null-b (ref null (exact $b))))
  (import "A" "new-b" (func $new-b (result (ref null (exact $b)))))
  (import "A" "new-null-b" (func $new-null-b (result (ref null (exact $b)))))

  (global (export "a") (ref (exact $a)) (struct.new $a (global.get $b)))

  (func (export "new-global") (result (ref (exact $a)))
    (struct.new $a (global.get $b))
  )

  (func (export "new-call") (result (ref (exact $a)))
    (struct.new $a (call $new-b))
  )

  (func (export "null-global") (result (ref (exact $a)))
    (struct.new $a (global.get $null-b))
  )

  (func (export "null-call") (result (ref (exact $a)))
    (struct.new $a (call $new-null-b))
  )
)

(assert_return (get "a") (ref.struct))
(assert_return (invoke "new-global") (ref.struct))
(assert_return (invoke "new-call") (ref.struct))
(assert_trap (invoke "null-global") "null descriptor reference")
(assert_trap (invoke "null-call") "null descriptor reference")
