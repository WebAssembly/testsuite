;; Validation

(module
  (rec
    (type $a (sub (descriptor $b) (struct)))
    (type $b (sub (describes $a) (struct)))
    (type $c (sub $a (descriptor $d) (struct)))
    (type $d (sub $b (describes $c) (struct)))
  )

  ;; All nullness combinations
  (func (param (ref null any) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref null $b)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref $b)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null $b)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref $b)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )

  ;; All nullness combinations with subtype descriptors
  (func (param (ref null any) (ref null $d)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref null $d)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref $d)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref $d)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null $d)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null $d)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref $d)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref $d)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )

  ;; All nullness combinations with exact subtype descriptors
  (func (param (ref null any) (ref null (exact $d))) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref null (exact $d))) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref (exact $d))) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref (exact $d))) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null (exact $d))) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null (exact $d))) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref (exact $d))) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref (exact $d))) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
  )

  ;; All nullness combinations with exact casts
  (func (param (ref null any) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref null (exact $b))) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref (exact $b))) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref null (exact $b))) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )
  (func (param (ref any) (ref (exact $b))) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (local.get 1))
  )

  ;; Unreachable descriptor
  (func (param (ref null any)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (unreachable))
  )
  (func (param (ref null any)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (unreachable))
  )
  (func (param (ref any)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (unreachable))
  )
  (func (param (ref any)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (unreachable))
  )
  (func (param (ref null any)) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (unreachable))
  )
  (func (param (ref null any)) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (unreachable))
  )
  (func (param (ref any)) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (unreachable))
  )
  (func (param (ref any)) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (unreachable))
  )

  ;; Null descriptor
  (func (param (ref null any)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (ref.null none))
  )
  (func (param (ref null any)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (ref.null none))
  )
  (func (param (ref any)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (ref.null none))
  )
  (func (param (ref any)) (result (ref $a))
    (ref.cast_desc_eq (ref $a) (local.get 0) (ref.null none))
  )
  (func (param (ref null any)) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (ref.null none))
  )
  (func (param (ref null any)) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (ref.null none))
  )
  (func (param (ref any)) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (ref.null none))
  )
  (func (param (ref any)) (result (ref (exact $a)))
    (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (ref.null none))
  )
)

(module
  (rec
    (type $a (sub (descriptor $b) (struct)))
    (type $b (sub (describes $a) (struct)))
    (type $c (sub $a (descriptor $d) (struct)))
    (type $d (sub $b (describes $c) (descriptor $e) (struct)))
    (type $e (describes $d) (struct))
  )

  ;; Cast to self
  (func (param (ref null $a) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null $a) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )

  ;; Cast to unrelated type
  (func (param (ref null i31) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null i31) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )

  ;; Cast from defined type to unrelated type
  (func (param (ref null $e) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null $e) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )

  ;; Cast from exact defined type to unrelated type
  (func (param (ref null (exact $e)) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null (exact $e)) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )

  ;; Cast to supertype
  (func (param (ref null $c) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null $c) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )

  ;; Cast from exact to supertype
  (func (param (ref null (exact $c)) (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (local.get 0) (local.get 1))
  )
  (func (param (ref null (exact $c)) (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (local.get 0) (local.get 1))
  )

  ;; Cast to subtype
  (func (param (ref null $a) (ref null $d)) (result (ref null $c))
    (ref.cast_desc_eq (ref null $c) (local.get 0) (local.get 1))
  )
  (func (param (ref null $a) (ref null (exact $d))) (result (ref null (exact $c)))
    (ref.cast_desc_eq (ref null (exact $c)) (local.get 0) (local.get 1))
  )

  ;; Cast from exact to subtype
  (func (param (ref null (exact $a)) (ref null $d)) (result (ref null $c))
    (ref.cast_desc_eq (ref null $c) (local.get 0) (local.get 1))
  )
  (func (param (ref null (exact $a)) (ref null (exact $d))) (result (ref null (exact $c)))
    (ref.cast_desc_eq (ref null (exact $c)) (local.get 0) (local.get 1))
  )

  ;; Cast from null
  (func (param (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (ref.null none) (local.get 0))
  )
  (func (param (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (ref.null none) (local.get 0))
  )

  ;; Cast from unreachable
  (func (param (ref null $b)) (result (ref null $a))
    (ref.cast_desc_eq (ref null $a) (unreachable) (local.get 0))
  )
  (func (param (ref null (exact $b))) (result (ref null (exact $a)))
    (ref.cast_desc_eq (ref null (exact $a)) (unreachable) (local.get 0))
  )

  ;; Cast to descriptor type
  (func (param (ref null any) (ref null $e)) (result (ref null $d))
    (ref.cast_desc_eq (ref null $d) (local.get 0) (local.get 1))
  )
  (func (param (ref null any) (ref null (exact $e))) (result (ref null (exact $d)))
    (ref.cast_desc_eq (ref null (exact $d)) (local.get 0) (local.get 1))
  )
)

(assert_invalid
  (module
    ;; Type must exist.
    (func (result anyref)
      (ref.cast_desc_eq (ref 1) (unreachable))
    )
  )
  "unknown type"
)

(assert_invalid
  (module
    ;; Type must have a descriptor.
    (func (result anyref)
      (ref.cast_desc_eq (ref any) (unreachable))
    )
  )
  "type any does not have a descriptor"
)

(assert_invalid
  (module
    ;; Type must have a descriptor.
    (func (result nullref)
      (ref.cast_desc_eq (ref null none) (unreachable))
    )
  )
  "type none does not have a descriptor"
)

(assert_invalid
  (module
    (type $a (struct))
    ;; Type must have a descriptor.
    (func (result anyref)
      (ref.cast_desc_eq (ref $a) (unreachable))
    )
  )
  "type 0 does not have a descriptor"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    ;; Cannot cast to descriptor without its own descriptor.
    (func (result anyref)
      (ref.cast_desc_eq (ref $b) (unreachable))
    )
  )
  "type 1 does not have a descriptor"
)

(assert_invalid
  (module
    (rec
      (type $a (descriptor $b) (struct))
      (type $b (describes $a) (struct))
    )
    ;; Descriptor must have expected type.
    (func (param (ref null any) (ref null struct)) (result (ref null any))
      (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
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
    ;; Descriptor must be exact when cast is exact.
    (func (param (ref null any) (ref $b)) (result (ref null any))
      (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (local.get 1))
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
    ;; Descriptor must be exact when cast is exact, even if the descriptor is null.
    (func (param (ref null any)) (result (ref null any))
      (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (ref.null $b))
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
    ;; An exact reference to a subtype of the descriptor does not cut it.
    (func (param (ref null any) (ref (exact $d))) (result (ref null any))
      (ref.cast_desc_eq (ref (exact $a)) (local.get 0) (local.get 1))
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
    ;; Cannot cast across hierarchies.
    (func (param (ref null func) (ref $b)) (result (ref null any))
      (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
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
    ;; Ouput type is determined by immediate, not actual input.
    (func (param (ref $c) (ref $d)) (result (ref null $c))
      (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
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
    ;; Same, but with an exact reference to the descriptor subtype.
    (func (param (ref $c) (ref (exact $d))) (result (ref null $c))
      (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
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
    ;; Same, but with an exact reference to the expected descriptor type.
    (func (param (ref $c) (ref (exact $b))) (result (ref null $c))
      (ref.cast_desc_eq (ref $a) (local.get 0) (local.get 1))
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
    ;; Same, but now the cast value and descriptor are both null.
    (func (result (ref null $c))
      (ref.cast_desc_eq (ref $a) (ref.null none) (ref.null none))
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
    ;; Same, but now the cast value and descriptor are bottom.
    (func (result (ref null $c))
      (ref.cast_desc_eq (ref $a) (unreachable))
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
    (global (ref $a) (ref.cast_desc_eq (ref null $a) (ref.null none) (ref.null none)))
  )
  "constant expression required"
)

;; Execution

(module
  (rec
    (type $a (sub (descriptor $b) (struct)))
    (type $b (sub (describes $a) (struct)))
    (type $c (sub $a (descriptor $d) (struct)))
    (type $d (sub $b (describes $c) (struct)))
  )
  (type $no-desc (struct))

  (global $b1-exact (ref null (exact $b)) (struct.new $b))
  (global $b2-exact (ref null (exact $b)) (struct.new $b))
  (global $b1 (ref null $b) (global.get $b1-exact))
  (global $b2 (ref null $b) (global.get $b2-exact))
  (global $a1 (ref null $a) (struct.new_desc $a (global.get $b1-exact)))

  (global $d1-exact (ref null (exact $d)) (struct.new $d))
  (global $d2-exact (ref null (exact $d)) (struct.new $d))
  (global $d1 (ref null $d) (global.get $d1-exact))
  (global $d2 (ref null $d) (global.get $d2-exact))
  (global $c1 (ref null $c) (struct.new_desc $c (global.get $d1-exact)))

  (global $c1-as-a (ref null $a) (global.get $c1))

  (global $a-null (ref null (exact $a)) (ref.null none))
  (global $b-null (ref null (exact $b)) (ref.null none))
  (global $c-null (ref null (exact $c)) (ref.null none))
  (global $d-null (ref null (exact $d)) (ref.null none))

  (global $no-desc (ref null (exact $no-desc)) (struct.new $no-desc))
  (global $no-desc-null (ref null (exact $no-desc)) (ref.null none))

  (global $i31 (ref null any) (ref.i31 (i32.const 0)))
  (global $i31-null (ref null any) (ref.null i31))

  (func (export "self-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $a-null) (global.get $b-null))
  )
  (func (export "self-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $a1) (global.get $b-null))
  )
  (func (export "self-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $a-null) (global.get $b1))
  )
  (func (export "self-nullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $a1) (global.get $b1))
  )
  (func (export "self-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $a1) (global.get $b2))
  )

  (func (export "self-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $a-null) (global.get $b-null))
  )
  (func (export "self-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $a1) (global.get $b-null))
  )
  (func (export "self-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $a-null) (global.get $b1))
  )
  (func (export "self-nonnullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $a1) (global.get $b1))
  )
  (func (export "self-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $a1) (global.get $b2))
  )

  (func (export "self-exact-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $a-null) (global.get $b-null))
  )
  (func (export "self-exact-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $a1) (global.get $b-null))
  )
  (func (export "self-exact-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $a-null) (global.get $b1-exact))
  )
  (func (export "self-exact-nullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $a1) (global.get $b1-exact))
  )
  (func (export "self-exact-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $a1) (global.get $b2-exact))
  )

  (func (export "self-exact-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $a-null) (global.get $b-null))
  )
  (func (export "self-exact-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $a1) (global.get $b-null))
  )
  (func (export "self-exact-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $a-null) (global.get $b1-exact))
  )
  (func (export "self-exact-nonnullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $a1) (global.get $b1-exact))
  )
  (func (export "self-exact-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $a1) (global.get $b2-exact))
  )

  (func (export "down-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null $c) (global.get $a-null) (global.get $d-null))
  )
  (func (export "down-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null $c) (global.get $c1-as-a) (global.get $d-null))
  )
  (func (export "down-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null $c) (global.get $a-null) (global.get $d1))
  )
  (func (export "down-nullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref null $c) (global.get $c1-as-a) (global.get $d1))
  )
  (func (export "down-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null $c) (global.get $c1-as-a) (global.get $d2))
  )

  (func (export "down-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref $c) (global.get $a-null) (global.get $d-null))
  )
  (func (export "down-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref $c) (global.get $c1-as-a) (global.get $d-null))
  )
  (func (export "down-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref $c) (global.get $a-null) (global.get $d1))
  )
  (func (export "down-nonnullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref $c) (global.get $c1-as-a) (global.get $d1))
  )
  (func (export "down-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref $c) (global.get $c1-as-a) (global.get $d2))
  )

  (func (export "down-exact-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $c)) (global.get $a-null) (global.get $d-null))
  )
  (func (export "down-exact-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $c)) (global.get $c1-as-a) (global.get $d-null))
  )
  (func (export "down-exact-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null (exact $c)) (global.get $a-null) (global.get $d1-exact))
  )
  (func (export "down-exact-nullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref null (exact $c)) (global.get $c1-as-a) (global.get $d1-exact))
  )
  (func (export "down-exact-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null (exact $c)) (global.get $c1-as-a) (global.get $d2-exact))
  )

  (func (export "down-exact-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $c)) (global.get $a-null) (global.get $d-null))
  )
  (func (export "down-exact-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $c)) (global.get $c1-as-a) (global.get $d-null))
  )
  (func (export "down-exact-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref (exact $c)) (global.get $a-null) (global.get $d1-exact))
  )
  (func (export "down-exact-nonnullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref (exact $c)) (global.get $c1-as-a) (global.get $d1-exact))
  )
  (func (export "down-exact-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref (exact $c)) (global.get $c1-as-a) (global.get $d2-exact))
  )

  (func (export "up-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $c-null) (global.get $d-null))
  )
  (func (export "up-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $c1) (global.get $d-null))
  )
  (func (export "up-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $c-null) (global.get $d1))
  )
  (func (export "up-nullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $c1) (global.get $d1))
  )
  (func (export "up-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $c1) (global.get $d2))
  )

  (func (export "up-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $c-null) (global.get $d-null))
  )
  (func (export "up-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $c1) (global.get $d-null))
  )
  (func (export "up-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $c-null) (global.get $d1))
  )
  (func (export "up-nonnullable-val-desc") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $c1) (global.get $d1))
  )
  (func (export "up-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $c1) (global.get $d2))
  )

  (func (export "up-exact-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $c-null) (global.get $b-null))
  )
  (func (export "up-exact-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $c1) (global.get $b-null))
  )
  (func (export "up-exact-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $c-null) (global.get $b1-exact))
  )
  (func (export "up-exact-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $c1) (global.get $b1-exact))
  )

  (func (export "up-exact-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $c-null) (global.get $b-null))
  )
  (func (export "up-exact-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $c1) (global.get $b-null))
  )
  (func (export "up-exact-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $c-null) (global.get $b1-exact))
  )
  (func (export "up-exact-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $c1) (global.get $b1-exact))
  )

  (func (export "nodesc-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $no-desc-null) (global.get $b-null))
  )
  (func (export "nodesc-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $no-desc) (global.get $b-null))
  )
  (func (export "nodesc-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $no-desc-null) (global.get $b1))
  )
  (func (export "nodesc-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $no-desc) (global.get $b1))
  )

  (func (export "nodesc-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $no-desc-null) (global.get $b-null))
  )
  (func (export "nodesc-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $no-desc) (global.get $b-null))
  )
  (func (export "nodesc-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $no-desc-null) (global.get $b1))
  )
  (func (export "nodesc-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $no-desc) (global.get $b1))
  )

  (func (export "nodesc-exact-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $no-desc-null) (global.get $b-null))
  )
  (func (export "nodesc-exact-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $no-desc) (global.get $b-null))
  )
  (func (export "nodesc-exact-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $no-desc-null) (global.get $b1-exact))
  )
  (func (export "nodesc-exact-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $no-desc) (global.get $b1-exact))
  )

  (func (export "nodesc-exact-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $no-desc-null) (global.get $b-null))
  )
  (func (export "nodesc-exact-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $no-desc) (global.get $b-null))
  )
  (func (export "nodesc-exact-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $no-desc-null) (global.get $b1-exact))
  )
  (func (export "nodesc-exact-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $no-desc) (global.get $b1-exact))
  )

  (func (export "i31-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $i31-null) (global.get $b-null))
  )
  (func (export "i31-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $i31) (global.get $b-null))
  )
  (func (export "i31-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $i31-null) (global.get $b1))
  )
  (func (export "i31-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null $a) (global.get $i31) (global.get $b1))
  )

  (func (export "i31-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $i31-null) (global.get $b-null))
  )
  (func (export "i31-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $i31) (global.get $b-null))
  )
  (func (export "i31-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $i31-null) (global.get $b1))
  )
  (func (export "i31-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref $a) (global.get $i31) (global.get $b1))
  )

  (func (export "i31-exact-nullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $i31-null) (global.get $b-null))
  )
  (func (export "i31-exact-nullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $i31) (global.get $b-null))
  )
  (func (export "i31-exact-nullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $i31-null) (global.get $b1-exact))
  )
  (func (export "i31-exact-nullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref null (exact $a)) (global.get $i31) (global.get $b1-exact))
  )

  (func (export "i31-exact-nonnullable-null-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $i31-null) (global.get $b-null))
  )
  (func (export "i31-exact-nonnullable-val-null") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $i31) (global.get $b-null))
  )
  (func (export "i31-exact-nonnullable-null-desc") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $i31-null) (global.get $b1-exact))
  )
  (func (export "i31-exact-nonnullable-val-other") (result anyref)
    (ref.cast_desc_eq (ref (exact $a)) (global.get $i31) (global.get $b1-exact))
  )
)

(assert_trap (invoke "self-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "self-nullable-val-null") "null descriptor reference")
(assert_return (invoke "self-nullable-null-desc") (ref.null none))
(assert_return (invoke "self-nullable-val-desc") (ref.struct))
(assert_trap (invoke "self-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "self-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "self-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "self-nonnullable-null-desc") "descriptor cast failure")
(assert_return (invoke "self-nonnullable-val-desc") (ref.struct))
(assert_trap (invoke "self-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "self-exact-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "self-exact-nullable-val-null") "null descriptor reference")
(assert_return (invoke "self-exact-nullable-null-desc") (ref.null none))
(assert_return (invoke "self-exact-nullable-val-desc") (ref.struct))
(assert_trap (invoke "self-exact-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "self-exact-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "self-exact-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "self-exact-nonnullable-null-desc") "descriptor cast failure")
(assert_return (invoke "self-exact-nonnullable-val-desc") (ref.struct))
(assert_trap (invoke "self-exact-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "down-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "down-nullable-val-null") "null descriptor reference")
(assert_return (invoke "down-nullable-null-desc") (ref.null none))
(assert_return (invoke "down-nullable-val-desc") (ref.struct))
(assert_trap (invoke "down-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "down-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "down-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "down-nonnullable-null-desc") "descriptor cast failure")
(assert_return (invoke "down-nonnullable-val-desc") (ref.struct))
(assert_trap (invoke "down-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "down-exact-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "down-exact-nullable-val-null") "null descriptor reference")
(assert_return (invoke "down-exact-nullable-null-desc") (ref.null none))
(assert_return (invoke "down-exact-nullable-val-desc") (ref.struct))
(assert_trap (invoke "down-exact-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "down-exact-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "down-exact-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "down-exact-nonnullable-null-desc") "descriptor cast failure")
(assert_return (invoke "down-exact-nonnullable-val-desc") (ref.struct))
(assert_trap (invoke "down-exact-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "up-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "up-nullable-val-null") "null descriptor reference")
(assert_return (invoke "up-nullable-null-desc") (ref.null none))
(assert_return (invoke "up-nullable-val-desc") (ref.struct))
(assert_trap (invoke "up-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "up-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "up-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "up-nonnullable-null-desc") "descriptor cast failure")
(assert_return (invoke "up-nonnullable-val-desc") (ref.struct))
(assert_trap (invoke "up-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "up-exact-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "up-exact-nullable-val-null") "null descriptor reference")
(assert_return (invoke "up-exact-nullable-null-desc") (ref.null none))
(assert_trap (invoke "up-exact-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "up-exact-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "up-exact-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "up-exact-nonnullable-null-desc") "descriptor cast failure")
(assert_trap (invoke "up-exact-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "nodesc-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "nodesc-nullable-val-null") "null descriptor reference")
(assert_return (invoke "nodesc-nullable-null-desc") (ref.null none))
(assert_trap (invoke "nodesc-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "nodesc-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "nodesc-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "nodesc-nonnullable-null-desc") "descriptor cast failure")
(assert_trap (invoke "nodesc-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "nodesc-exact-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "nodesc-exact-nullable-val-null") "null descriptor reference")
(assert_return (invoke "nodesc-exact-nullable-null-desc") (ref.null none))
(assert_trap (invoke "nodesc-exact-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "nodesc-exact-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "nodesc-exact-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "nodesc-exact-nonnullable-null-desc") "descriptor cast failure")
(assert_trap (invoke "nodesc-exact-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "i31-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "i31-nullable-val-null") "null descriptor reference")
(assert_return (invoke "i31-nullable-null-desc") (ref.null none))
(assert_trap (invoke "i31-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "i31-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "i31-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "i31-nonnullable-null-desc") "descriptor cast failure")
(assert_trap (invoke "i31-nonnullable-val-other") "descriptor cast failure")

(assert_trap (invoke "i31-exact-nullable-null-null") "null descriptor reference")
(assert_trap (invoke "i31-exact-nullable-val-null") "null descriptor reference")
(assert_return (invoke "i31-exact-nullable-null-desc") (ref.null none))
(assert_trap (invoke "i31-exact-nullable-val-other") "descriptor cast failure")

(assert_trap (invoke "i31-exact-nonnullable-null-null") "null descriptor reference")
(assert_trap (invoke "i31-exact-nonnullable-val-null") "null descriptor reference")
(assert_trap (invoke "i31-exact-nonnullable-null-desc") "descriptor cast failure")
(assert_trap (invoke "i31-exact-nonnullable-val-other") "descriptor cast failure")
