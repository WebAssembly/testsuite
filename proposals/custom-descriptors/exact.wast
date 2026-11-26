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

;; Exact type index is decoded as u32 (not s32/s33), so 0x40 is type index 64
;; and matches 5-byte u32 64 (\c0\80\80\80\00).
(module binary
  "\00asm" "\01\00\00\00"
  "\01"      ;; Type section id
  "\9a\01"   ;; Type section length (154)
  "\43"      ;; Types vector length (67)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 0..7: (struct)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 8..15: (struct)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 16..23: (struct)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 24..31: (struct)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 32..39: (struct)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 40..47: (struct)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 48..55: (struct)
  "\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00\5f\00"  ;; Types 56..63: (struct)
  "\5f\01\7f\00"                          ;; Type 64: (struct (field i32))
  "\50\00\5f\01\64\62\c0\80\80\80\00\01"  ;; Type 65: (sub (struct (field (mut (ref (exact 64))))))
  "\4f\01\41\5f\01\64\62\40\01"           ;; Type 66: (sub final 65 (struct (field (mut (ref (exact 64))))))
)

;; Max u32 (0xffff_ffff) is a well-formed exact type index (rejected by s32).
(assert_invalid
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\0b"  ;; Type section length
    "\01"  ;; Types vector length
    "\60"  ;; Func
    "\01"  ;; Number of params
    "\64"  ;; Ref
    "\62"  ;; Exact
    "\ff\ff\ff\ff\0f"  ;; Type index 0xffff_ffff (u32)
    "\00"  ;; Number of results
  )
  "unknown type"
)

;; Exact type index >= 2^32 is malformed (even when low 32 bits are valid type 0).
(assert_malformed
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\0b"  ;; Type section length
    "\01"  ;; Types vector length
    "\60"  ;; Func
    "\01"  ;; Number of params
    "\64"  ;; Ref
    "\62"  ;; Exact
    "\80\80\80\80\10"  ;; Type index 2^32
    "\00"  ;; Number of results
  )
  "integer too large"
)

;; Overlong exact type index is malformed (even when value is valid type 0).
(assert_malformed
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\0c"  ;; Type section length
    "\01"  ;; Types vector length
    "\60"  ;; Func
    "\01"  ;; Number of params
    "\64"  ;; Ref
    "\62"  ;; Exact
    "\80\80\80\80\80\00"  ;; Type index 0 in 6 bytes
    "\00"  ;; Number of results
  )
  "integer representation too long"
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

;; Cannot repeat exactness prefix (second 0x62 is parsed as u32 type index 98).
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
  "section size mismatch"
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
