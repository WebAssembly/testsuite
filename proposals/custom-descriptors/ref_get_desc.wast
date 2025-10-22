;; Validation

(module
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct))
  )

  (func (param (ref $a)) (result (ref $b))
    (ref.get_desc $a (local.get 0))
  )
  (func (param (ref null $a)) (result (ref $b))
    (ref.get_desc $a (local.get 0))
  )
  (func (param (ref (exact $a))) (result (ref (exact $b)))
    (ref.get_desc $a (local.get 0))
  )
  (func (param (ref null (exact $a))) (result (ref (exact $b)))
    (ref.get_desc $a (local.get 0))
  )

  (func (result (ref (exact $b)))
    (ref.get_desc $a (unreachable))
  )
  (func (result (ref (exact $b)))
    (ref.get_desc $a (ref.null none))
  )
  (func (result (ref (exact $b)))
    (ref.get_desc $a (ref.null (exact $a)))
  )
  (func (result (ref $b))
    (ref.get_desc $a (ref.null $a))
  )
)

;; Same, but now get a descriptor of a descriptor.
(module
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (descriptor $c) (struct))
    (type $c (describes $b) (struct))
  )

  (func (param (ref $b)) (result (ref $c))
    (ref.get_desc $b (local.get 0))
  )
  (func (param (ref null $b)) (result (ref $c))
    (ref.get_desc $b (local.get 0))
  )
  (func (param (ref (exact $b))) (result (ref (exact $c)))
    (ref.get_desc $b (local.get 0))
  )
  (func (param (ref null (exact $b))) (result (ref (exact $c)))
    (ref.get_desc $b (local.get 0))
  )

  (func (result (ref (exact $c)))
    (ref.get_desc $b (unreachable))
  )
  (func (result (ref (exact $c)))
    (ref.get_desc $b (ref.null none))
  )
  (func (result (ref (exact $c)))
    (ref.get_desc $b (ref.null (exact $b)))
  )
  (func (result (ref $c))
    (ref.get_desc $b (ref.null $b))
  )
)

(assert_invalid
  (module
    ;; Type must exist.
    (func (result anyref)
      (ref.get_desc 1 (unreachable))
    )
  )
  "unknown type"
)

(assert_invalid
  (module
    ;; Cannot get the described type from a type that does not have one.
    (type $a (struct))
    (func (param (ref $a)) (result anyref)
      (ref.get_desc $a (local.get 0))
    )
  )
  "type without descriptor"
)

(assert_invalid
  (module
    ;; Same, but now the type is a function type.
    (type $a (func))
    (func (param (ref $a)) (result anyref)
      (ref.get_desc $a (local.get 0))
    )
  )
  "type without descriptor"
)

(assert_invalid
  (module
    (rec
      (type $a (sub (descriptor $b) (struct)))
      (type $b (sub (describes $a) (struct)))
    )
    ;; Cannot get the described type from the descriptor.
    (func (param (ref $b)) (result (ref $a))
      (ref.get_desc $b (local.get 0))
    )
  )
  "type without descriptor"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    ;; Operand must have expected type.
    (func (param (ref any)) (result (ref $b))
      (ref.get_desc $a (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    ;; Only exact inputs produce exact outputs.
    (func (param (ref $a)) (result (ref (exact $b)))
      (ref.get_desc $a (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    ;; Only exact inputs produce exact outputs, even for nulls.
    (func (result (ref (exact $b)))
      (ref.get_desc $a (ref.null $a))
    )
  )
  "type mismatch"
)

(module
  (rec
    (type $a (sub (descriptor $b) (struct)))
    (type $b (sub (describes $a) (struct)))
    (type $c (sub $a (descriptor $d) (struct)))
    (type $d (sub $b (describes $c) (struct)))
  )
  ;; Subtyping works.
  (func (param (ref (exact $c))) (result (ref $b))
    (ref.get_desc $a (local.get 0))
  )
  (func (param (ref $c)) (result (ref $b))
    (ref.get_desc $a (local.get 0))
  )
)

(assert_invalid
  (module
    (rec
      (type $a (sub (descriptor $b) (struct)))
      (type $b (sub (describes $a) (struct)))
      (type $c (sub $a (descriptor $d) (struct)))
      (type $d (sub $b (describes $c) (struct)))
    )
    ;; Only exact inputs of the inspected type produce exact outputs.
    (func (param (ref (exact $c))) (result (ref (exact $b)))
      (ref.get_desc $a (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (sub (descriptor $b) (struct)))
      (type $b (sub (describes $a) (struct)))
      (type $c (sub $a (descriptor $d) (struct)))
      (type $d (sub $b (describes $c) (struct)))
    )
    ;; Same as above, but with a null.
    (func (result (ref (exact $b)))
      (ref.get_desc $a (ref.null (exact $c)))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (sub (descriptor $b) (struct)))
      (type $b (sub (describes $a) (struct)))
      (type $c (sub $a (descriptor $d) (struct)))
      (type $d (sub $b (describes $c) (struct)))
    )
    ;; The output describes the expected input, not the actual input.
    (func (param (ref (exact $c))) (result (ref $d))
      (ref.get_desc $a (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (sub (descriptor $b) (struct)))
      (type $b (sub (describes $a) (struct)))
      (type $c (sub $a (descriptor $d) (struct)))
      (type $d (sub $b (describes $c) (struct)))
    )
    ;; Same as above, but now the input is not exact.
    (func (param (ref $c)) (result (ref $d))
      (ref.get_desc $a (local.get 0))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    ;; Invalid in constant expression.
    (global (ref $b) (ref.get_desc $a (ref.null none)))
  )
  "constant expression required"
)

;; Binary format

(module binary
  "\00asm" "\01\00\00\00"
  "\01" ;; Type section id
  "\12" ;; Type section length
  "\02" ;; Types vector length
  "\4e" ;; Recursion group
  "\02" ;; Rec group size
  "\4d" ;; Descriptor
  "\01" ;; Descriptor type index
  "\5f" ;; Struct
  "\00" ;; Number of fields
  "\4c" ;; Describes
  "\00" ;; Describes type index
  "\5f" ;; Struct
  "\00" ;; Number of fields
  "\60" ;; Func
  "\01" ;; Number of params
  "\63" ;; Ref null
  "\00" ;; Type index
  "\01" ;; Number of results
  "\64" ;; Ref
  "\01" ;; Type index
  "\03" ;; Function section id
  "\02" ;; Function section length
  "\01" ;; Functions vector length
  "\02" ;; Type index
  "\0a" ;; Code section id
  "\09" ;; Code section length
  "\01" ;; Code vector length
  "\07" ;; Code length
  "\00" ;; Number of locals
  "\20" ;; local.get
  "\00" ;; Local index
  "\fb\22" ;; ref.get_desc
  "\00" ;; Type index
  "\0b" ;; end
)

;; Execution

(module
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct (field i32)))
  )

  (rec
    (type $one (descriptor $two) (struct))
    (type $two (describes $one) (descriptor $three) (struct))
    (type $three (describes $two) (struct))
  )

  (global $b1 (ref (exact $b)) (struct.new $b (i32.const 1)))
  (global $b2 (ref (exact $b)) (struct.new $b (i32.const 2)))

  (global $a1 (ref null $a) (struct.new $a (global.get $b1)))
  (global $a2 (ref null (exact $a)) (struct.new $a (global.get $b2)))
  (global $a3 (ref (exact $a)) (struct.new $a (struct.new $b (i32.const 3))))

  (global $null (ref null $a) (ref.null none))
  (global $null-exact (ref null (exact $a)) (ref.null (exact $a)))

  (func $null (result (ref null $a)) (ref.null none))
  (func $null-exact (result (ref null (exact $a))) (ref.null (exact $a)))
  (func $alloc-i32 (param i32) (result (ref (exact $a)))
    (struct.new $a (struct.new $b (local.get 0)))
  )
  (func $alloc-desc (param (ref (exact $b))) (result (ref (exact $a)))
    (struct.new $a (local.get 0))
  )

  (func (export "null") (result anyref)
    (ref.get_desc $a (ref.null none))
  )
  (func (export "null-typed") (result anyref)
    (ref.get_desc $a (ref.null (exact $a)))
  )
  (func (export "null-global") (result anyref)
    (ref.get_desc $a (global.get $null))
  )
  (func (export "null-exact-global") (result anyref)
    (ref.get_desc $a (global.get $null-exact))
  )
  (func (export "null-call") (result anyref)
    (ref.get_desc $a (call $null))
  )
  (func (export "null-exact-call") (result anyref)
    (ref.get_desc $a (call $null-exact))
  )
  (func (export "get-from-param") (param (ref null $a)) (result anyref)
    (ref.get_desc $a (local.get 0))
  )

  (func (export "alloc-0") (result i32)
    (struct.get $b 0
      (ref.get_desc $a
        (struct.new $a
          (struct.new $b
            (i32.const 0)
          )
        )
      )
    )
  )
  (func (export "global-1") (result i32)
    (struct.get $b 0 (ref.get_desc $a (global.get $a1)))
  )
  (func (export "global-2") (result i32)
    (struct.get $b 0 (ref.get_desc $a (global.get $a2)))
  )
  (func (export "global-3") (result i32)
    (struct.get $b 0 (ref.get_desc $a (global.get $a3)))
  )
  (func (export "call-4") (result i32)
    (struct.get $b 0 (ref.get_desc $a (call $alloc-i32 (i32.const 4))))
  )
  (func (export "call-5") (result i32)
    (struct.get $b 0 (ref.get_desc $a (call $alloc-desc (struct.new $b (i32.const 5)))))
  )
  (func (export "equal") (result i32)
    (local (ref null (exact $b)))
    (local.set 0 (struct.new_default $b))
    (ref.eq
      (local.get 0)
      (ref.get_desc $a (struct.new $a (local.get 0)))
    )
  )
  (func (export "not-equal") (result i32)
    (ref.eq
      (struct.new_default $b)
      (ref.get_desc $a (struct.new $a (struct.new_default $b)))
    )
  )
  (func (export "chain-equal") (result i32)
    (local $three (ref null (exact $three)))
    (local $two (ref null (exact $two)))
    (local $one (ref null (exact $one)))
    (local.set $three (struct.new $three))
    (local.set $two (struct.new $two (local.get $three)))
    (local.set $one (struct.new $one (local.get $two)))
    (ref.eq
      (local.get $three)
      (ref.get_desc $two (ref.get_desc $one (local.get $one)))
    )
  )
)

(assert_trap (invoke "null") "null reference")
(assert_trap (invoke "null-typed") "null reference")
(assert_trap (invoke "null-global") "null reference")
(assert_trap (invoke "null-exact-global") "null reference")
(assert_trap (invoke "null-call") "null reference")
(assert_trap (invoke "null-exact-call") "null reference")
(assert_trap (invoke "get-from-param" (ref.null none)) "null reference")

(assert_return (invoke "alloc-0") (i32.const 0))
(assert_return (invoke "global-1") (i32.const 1))
(assert_return (invoke "global-2") (i32.const 2))
(assert_return (invoke "global-3") (i32.const 3))
(assert_return (invoke "call-4") (i32.const 4))
(assert_return (invoke "call-5") (i32.const 5))
(assert_return (invoke "equal") (i32.const 1))
(assert_return (invoke "not-equal") (i32.const 0))
(assert_return (invoke "chain-equal") (i32.const 1))

;; Cross-instance execution

(module
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct))
  )

  (global (export "b") (ref null (exact $b)) (struct.new $b))

  (func (export "make-a") (result (ref null $a))
    (struct.new $a (global.get 0))
  )

  (func (export "check-eq") (param (ref null $a)) (result i32)
    (ref.eq (ref.get_desc $a (local.get 0)) (global.get 0))
  )
)

(register "A")

(module
   ;; Add an extra type to make the type indices different between modules.
  (type $other (func))
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct))
  )

  (import "A" "b" (global $b (ref null (exact $b))))
  (import "A" "make-a" (func $make-a (result (ref null $a))))
  (import "A" "check-eq" (func $check-eq (param (ref null $a)) (result i32)))

  (func (export "imported-desc-equal") (result i32)
    (ref.eq (ref.get_desc $a (call $make-a)) (global.get $b))
  )

  (func (export "imported-check-equal") (result i32)
    (call $check-eq (struct.new $a (global.get $b)))
  )

  (func (export "imported-check-not-equal") (result i32)
    (call $check-eq (struct.new $a (struct.new $b)))
  )
)

(assert_return (invoke "imported-desc-equal") (i32.const 1))
(assert_return (invoke "imported-check-equal") (i32.const 1))
(assert_return (invoke "imported-check-not-equal") (i32.const 0))
