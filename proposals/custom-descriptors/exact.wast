;; Type syntax

(module
  (rec
    (type $struct (struct (field (ref null (exact $func)))))
    (type $array (array (ref null (exact $struct))))
    (type $func (func (param (ref (exact $struct))) (result (ref (exact $array)))))
  )

  (global (ref null (exact 0)) (ref.null (exact $struct)))

  (table 0 (ref null (exact $array)))

  (elem (ref null $func))

  (func $f (param (ref (exact $struct))) (result (ref (exact $func)))
    (unreachable)
  )
)

;; No exact references to abstract heap types.
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact any)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact eq)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact i31)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact struct)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact array)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact none)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact func)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact nofunc)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact extern)))))"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact noextern)))))"
  )
  "unexpected token"
)

;; Must have a type index.
(assert_malformed
  (module quote
    "(type (struct (field (ref (exact)))))"
  )
  "unexpected token"
)

;; Must have parens.
(assert_malformed
  (module quote
    "(type (struct (field (ref exact 0))))"
  )
  "unexpected token"
)

;; Must have ref.
(assert_malformed
  (module quote
    "(type (struct (field (exact 0))))"
  )
  "unexpected token"
)


;; Binary encoding

;; Non-nullable exact reference.
(module binary
  "\00asm" "\01\00\00\00"
  "\01"  ;; Type section id
  "\07"  ;; Type section length
  "\01"  ;; Types vector length
  "\5f"  ;; Struct
  "\01"  ;; Number of fields
  "\64"  ;; Ref
  "\62"  ;; Exact
  "\00"  ;; Type index
  "\00"  ;; Immutable
)

;; Nullable exact reference.
(module binary
  "\00asm" "\01\00\00\00"
  "\01"  ;; Type section id
  "\07"  ;; Type section length
  "\01"  ;; Types vector length
  "\5f"  ;; Struct
  "\01"  ;; Number of fields
  "\63"  ;; Ref null
  "\62"  ;; Exact
  "\00"  ;; Type index
  "\00"  ;; Immutable
)

;; Reference must be either nullable or non-nullable.
(assert_malformed
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\06"  ;; Type section length
    "\01"  ;; Types vector length
    "\5f"  ;; Struct
    "\01"  ;; Number of fields
    "\62"  ;; Exact (neither nullable nor non-nullable!)
    "\00"  ;; Type index
    "\00"  ;; Immutable
  )
  "malformed storage type"
)

;; Cannot repeat exactness prefix.
(assert_malformed
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\08"  ;; Type section length
    "\01"  ;; Types vector length
    "\5f"  ;; Struct
    "\01"  ;; Number of fields
    "\64"  ;; Ref
    "\62"  ;; Exact
    "\62"  ;; Exact (again!)
    "\00"  ;; Type index
    "\00"  ;; Immutable
  )
  "malformed storage type"
)

;; Subtyping

;; none <: (exact t)
(module
  (type (struct))
  (func (param (ref none)) (result (ref (exact 0)))
    (local.get 0)
  )
)

;; nofunc <: (exact ft)
(module
  (type (func))
  (func (param (ref nofunc)) (result (ref (exact 0)))
    (local.get 0)
  )
)

;; (exact t) <: (exact t)
(module
  (type (struct))
  (func (param (ref (exact 0))) (result (ref (exact 0)))
    (local.get 0)
  )
)

;; (exact ft) <: (exact ft)
(module
  (type (func))
  (func (param (ref (exact 0))) (result (ref (exact 0)))
    (local.get 0)
  )
)

;; (exact t) <: (exact t) (with syntactically different types)
(module
  (type (struct))
  (type (struct))
  (type (struct (field (ref 0))))
  (type (struct (field (ref 1))))
  (func (param (ref (exact 2))) (result (ref (exact 3)))
    (local.get 0)
  )
)

;; (exact ft) <: (exact ft) (with syntactically different types)
(module
  (type (struct))
  (type (struct))
  (type (func (param (ref 0))))
  (type (func (param (ref 1))))
  (func (param (ref (exact 3))) (result (ref (exact 2)))
    (local.get 0)
  )
)

;; (exact t) <: t
(module
  (type (struct))
  (func (param (ref (exact 0))) (result (ref 0))
    (local.get 0)
  )
)

;; (exact ft) <: ft
(module
  (type (func))
  (func (param (ref (exact 0))) (result (ref 0))
    (local.get 0)
  )
)

;; (exact t) <: any
(module
  (type (struct))
  (func (param (ref (exact 0))) (result (ref any))
    (local.get 0)
  )
)

;; (exact ft) <: func
(module
  (type (func))
  (func (param (ref (exact 0))) (result (ref func))
    (local.get 0)
  )
)

;; (exact sub) <: super
(module
  (type $super (sub (struct)))
  (type $sub (sub $super (struct)))
  (func (param (ref (exact $sub))) (result (ref $super))
    (local.get 0)
  )
)

;; (exact sub) <: super (with function types)
(module
  (type $super (sub (func)))
  (type $sub (sub $super (func)))
  (func (param (ref (exact $sub))) (result (ref $super))
    (local.get 0)
  )
)

;; sub </: (exact super)
(assert_invalid
  (module
    (type $super (sub (struct)))
    (type $sub (sub $super (struct)))
    (func (param (ref $sub)) (result (ref (exact $super)))
      (local.get 0)
    )
  )
  "type mismatch"
)

;; sub </: (exact super) (with function types)
(assert_invalid
  (module
    (type $super (sub (func)))
    (type $sub (sub $super (func)))
    (func (param (ref $sub)) (result (ref (exact $super)))
      (local.get 0)
    )
  )
  "type mismatch"
)

;; (exact sub) </: (exact super)
(assert_invalid
  (module
    (type $super (sub (struct)))
    (type $sub (sub $super (struct)))
    (func (param (ref (exact $sub))) (result (ref (exact $super)))
      (local.get 0)
    )
  )
  "type mismatch"
)

;; (exact sub) </: (exact super) (with function types)
(assert_invalid
  (module
    (type $super (sub (func)))
    (type $sub (sub $super (func)))
    (func (param (ref (exact $sub))) (result (ref (exact $super)))
      (local.get 0)
    )
  )
  "type mismatch"
)

;; Nullability still matters: (ref (exact t)) <: (ref null (exact t))
(module
  (type (struct))
  (func (param (ref (exact 0))) (result (ref null (exact 0)))
    (local.get 0)
  )
)

;; Nullability still matters: (ref null (exact t)) </: (ref (exact t))
(assert_invalid
  (module
    (type (struct))
    (func (param (ref null (exact 0))) (result (ref (exact 0)))
      (local.get 0)
    )
  )
  "type mismatch"
)

;; TODO: Test that exact casts and nulls are allowed, but that instructions that
;; take only type indices (e.g. struct.new) do not allow exactness. Add these
;; tests once we've updated the validation and executiong for these instructions
;; so we can test cast execution.
