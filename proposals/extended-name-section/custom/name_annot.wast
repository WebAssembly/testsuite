;; Module names (subsection 0)

(module (@name "Modül"))

(module $moduel (@name "Modül"))

(assert_malformed_custom
  (module quote "(module (@name \"M1\") (@name \"M2\"))")
  "@name annotation: multiple module"
)

(assert_malformed_custom
  (module quote "(module (func) (@name \"M\"))")
  "misplaced @name annotation"
)

(assert_malformed_custom
  (module quote "(module (start $f (@name \"M\")) (func $f))")
  "misplaced @name annotation"
)


;; Function names (subsection 1)

(module definition
  (type $t (func))
  (import "m" "f" (func (@name "f") (type $t)))
  (import "m" "g" (func $g (@name "g") (type $t)))
  (func (@name "λ") (type $t))
  (func $lambda (@name "λ") (type $t))
)

(module definition
  (type $t (func))
  (func (@name "f") (import "m" "f") (type $t))
  (func $g (@name "g") (import "m" "g") (type $t))
)

(assert_malformed_custom
  (module quote
    "(module (type $t (func)) (func (@name \"f1\") (@name \"f2\") (type $t)))"
  )
  "@name annotation: multiple function names"
)

(assert_malformed_custom
  (module quote "(module (type $t (func)) (func (type $t) (@name \"f\")))")
  "misplaced @name annotation"
)


;; Local names (subsection 2)

(module
  (func
    (param (@name "p0") i32) (param $p1 (@name "p1") i64)
    (local (@name "l0") f32) (local $l1 (@name "l1") f64)
  )
)

(module definition
  (import "m" "f" (func (param (@name "p") i32)))
)

(assert_malformed_custom
  (module quote
    "(module (func (local (@name \"l1\") (@name \"l2\") i32)))"
  )
  "@name annotation: multiple local names"
)

(assert_malformed_custom
  (module quote "(module (func (local (@name \"l\") i32 i64)))")
  "@name annotation: multiple locals declared"
)


;; Label names (subsection 3)

(module
  (func
    block (@name "a") end
    block end
    loop (@name "b") end
    i32.const 1
    if (@name "c")
      block (@name "d") end
    else
      block (@name "e") end
    end
    block $f (@name "f")
      try_table (@name "g") (catch_all $f) end
    end
  )
)

;; These two modules should have the same label names.
(module
  (func (result i32)
    block (@name "a") (result i32) i32.const 1 end
    if (@name "b") (result i32)
      i32.const 2
    else
      i32.const 3
    end
  )
)
(module
  (func (result i32)
    (if (@name "b") (result i32)
      (block (@name "a") (result i32) (i32.const 1))
      (then (i32.const 2))
      (else (i32.const 3))
    )
  )
)

(assert_malformed_custom
  (module quote
    "(module (func block (@name \"b1\") (@name \"b2\") end))"
  )
  "@name annotation: multiple label names"
)

;; The label identifier at the matching `end` is not a binding occurrence.
(assert_malformed_custom
  (module quote "(module (func block $b end $b (@name \"b\")))")
  "misplaced @name annotation"
)

;; Nor is a branch target a binding occurrence.
(assert_malformed_custom
  (module quote "(module (func block $b br $b (@name \"b\") end))")
  "misplaced @name annotation"
)


;; Type and field names (subsections 4 and 10)

(module
  (type (@name "T") (func))
  (type (@name "T") (func (param i32)))
  (type (@name "S") (sub final (struct)))
  (rec
    (type (@name "R1") (struct
      (field (@name "f") i32)
      (field (@name "g") (ref null $r2))
    ))
    (type $r2 (@name "R2") (array (mut i8)))
  )
)

(assert_malformed_custom
  (module quote "(module (type (@name \"T1\") (@name \"T2\") (func)))")
  "@name annotation: multiple type names"
)

(assert_malformed_custom
  (module quote
    "(module (type (struct (field (@name \"f1\") (@name \"f2\") i32))))"
  )
  "@name annotation: multiple field names"
)

(assert_malformed_custom
  (module quote "(module (type (struct (field (@name \"f\") i32 i64))))")
  "@name annotation: multiple fields declared"
)


;; Table, memory, and global names (subsections 5, 6, and 7)

(module definition
  (import "m" "t" (table (@name "t0") 1 funcref))
  (import "m" "m" (memory (@name "m0") 1))
  (import "m" "g" (global (@name "g0") i32))
  (table (@name "t1") 1 funcref)
  (memory (@name "m1") 1)
  (global (@name "g1") i32 (i32.const 0))
)

(module
  (func $f)
  (table (@name "t") (export "t") funcref (elem $f))
  (memory (@name "m") (export "m") (data "hello"))
  (global (@name "g") (export "g") i32 (i32.const 0))
)

(assert_malformed_custom
  (module quote "(module (table (@name \"t1\") (@name \"t2\") 1 funcref))")
  "@name annotation: multiple table names"
)

(assert_malformed_custom
  (module quote "(module (memory (@name \"m1\") (@name \"m2\") 1))")
  "@name annotation: multiple memory names"
)

(assert_malformed_custom
  (module quote
    "(module (global (@name \"g1\") (@name \"g2\") i32 (i32.const 0)))"
  )
  "@name annotation: multiple global names"
)

(assert_malformed_custom
  (module quote "(module (table 1 funcref (@name \"t\")))")
  "misplaced @name annotation"
)


;; Element and data segment names (subsections 8 and 9)

(module
  (func $f)
  (table 1 funcref)
  (memory 1)
  (elem (@name "active") (i32.const 0) func $f)
  (elem (@name "passive") func $f)
  (elem (@name "declarative") declare func $f)
  (data (@name "active") (i32.const 0) "a")
  (data (@name "passive") "c")
)

(assert_malformed_custom
  (module quote
    "(module (func $f) (elem (@name \"e1\") (@name \"e2\") func $f))"
  )
  "@name annotation: multiple elem names"
)

(assert_malformed_custom
  (module quote "(module (data (@name \"d1\") (@name \"d2\") \"a\"))")
  "@name annotation: multiple data names"
)


;; Tag and tag parameter names (subsections 11 and 13)

(module definition
  (type $t (func (param i32)))
  (import "m" "e" (tag (@name "e") (type $t)))
  (tag (@name "θ") (type $t))
  (tag $theta (@name "θ") (type $t))
  (tag (@name "exn") (param (@name "code") i32) (param $extra (@name "extra") i64))
)

(assert_malformed_custom
  (module quote
    "(module (type $t (func)) (tag (@name \"t1\") (@name \"t2\") (type $t)))"
  )
  "@name annotation: multiple tag names"
)

(assert_malformed_custom
  (module quote
    "(module (tag (param (@name \"p1\") (@name \"p2\") i32)))"
  )
  "@name annotation: multiple tag param names"
)


;; Parameter names (subsection 12)

(module
  (type (func (param (@name "x") i32) (param $y (@name "y") i64)))
  (rec
    (type (func (param (@name "p") (ref null $r))))
    (type $r (func))
  )
)

(assert_malformed_custom
  (module quote
    "(module (type (func (param (@name \"p1\") (@name \"p2\") i32))))"
  )
  "@name annotation: multiple param names"
)

(assert_malformed_custom
  (module quote "(module (type (func (param (@name \"p\") i32 i64))))")
  "@name annotation: multiple params declared"
)

(assert_malformed_custom
  (module quote
    "(module (type $t (func (param i32)))"
    "  (func (i32.const 1) (block (type $t) (param (@name \"p\") i32) (drop))))"
  )
  "@name annotation: param names not allowed here"
)

(assert_malformed_custom
  (module quote
    "(module (table 1 funcref)"
    "  (func (call_indirect (param (@name \"p\") i32) (i32.const 7) (i32.const 0))))"
  )
  "@name annotation: param names not allowed here"
)


;; Misplaced annotations

;; Before the identifier
(assert_malformed_custom
  (module quote "(module (type $t (func)) (func (@name \"f\") $f (type $t)))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (table (@name \"t\") $t 1 funcref))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (func (local (@name \"l\") $l i32)))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (type (struct (field (@name \"f\") $f i32))))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (func block (@name \"b\") $b end))")
  "misplaced @name annotation"
)

;; Before the keyword
(assert_malformed_custom
  (module quote "(module (type $t (func)) ((@name \"f\") func (type $t)))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module ((@name \"t\") table 1 funcref))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (type (struct ((@name \"f\") field i32))))")
  "misplaced @name annotation"
)

;; After an inline export or import clause
(assert_malformed_custom
  (module quote "(module (func (export \"f\") (@name \"f\")))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (memory (export \"m\") (@name \"m\") 1))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (func (import \"m\" \"f\") (@name \"f\")))")
  "misplaced @name annotation"
)

;; Elsewhere inside a declaration
(assert_malformed_custom
  (module quote "(module (table 1 (@name \"t\") funcref))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (global (mut i32) (@name \"g\") (i32.const 0)))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (type (func (param i32) (@name \"T\") (result i32))))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (memory 1) (data (i32.const 0) (@name \"d\") \"x\"))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (import \"m\" (@name \"f\") \"f\" (func)))")
  "misplaced @name annotation"
)
(assert_malformed_custom
  (module quote "(module (func (local i32) (@name \"l\") (local i64)))")
  "misplaced @name annotation"
)


;; Annotation payload syntax

(assert_malformed_custom
  (module quote "(module (@name))")
  "@name annotation: string expected"
)

(assert_malformed_custom
  (module quote "(module (@name 1))")
  "@name annotation: string expected"
)

(assert_malformed_custom
  (module quote "(module (@name \"a\" \"b\"))")
  "@name annotation: unexpected token"
)

(assert_malformed_custom
  (module quote "(module (@name \"\\ff\"))")
  "malformed UTF-8 encoding"
)
