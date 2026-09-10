;; module name (0): "M"
(module (;(@name "M");) (@custom "name" (after data) "\00\02\01M"))

;; function names (1): 0 = "f", 1 = "g"
(module
  (func (;(@name "f");))
  (func (;(@name "g");))
  (@custom "name" (after data) "\01\07\02\00\01f\01\01g")
)

;; local names (2): function 0, local 0 = "p", local 1 = "l"
(module
  (func (param (;(@name "p");) i32) (local (;(@name "l");) i64))
  (@custom "name" (after data) "\02\09\01\00\02\00\01p\01\01l")
)

;; label names (3): function 0, label 0 = "a", label 1 = "b"
(module
  (func
    block (;(@name "a");) end
    loop (;(@name "b");) end
  )
  (@custom "name" (after data) "\03\09\01\00\02\00\01a\01\01b")
)

;; type names (4): 0 = "T"
(module
  (type (;(@name "T");) (func))
  (@custom "name" (after data) "\04\04\01\00\01T")
)

;; table names (5): 0 = "t"
(module
  (table (;(@name "t");) 1 funcref)
  (@custom "name" (after data) "\05\04\01\00\01t")
)

;; memory names (6): 0 = "m"
(module
  (memory (;(@name "m");) 1)
  (@custom "name" (after data) "\06\04\01\00\01m")
)

;; global names (7): 0 = "g"
(module
  (global (;(@name "g");) i32 (i32.const 0))
  (@custom "name" (after data) "\07\04\01\00\01g")
)

;; element segment names (8): 0 = "e"
(module
  (func $f)
  (table 1 funcref)
  (elem (;(@name "e");) (i32.const 0) func $f)
  (@custom "name" (after data) "\08\04\01\00\01e")
)

;; data segment names (9): 0 = "d"
(module
  (memory 1)
  (data (;(@name "d");) (i32.const 0) "x")
  (@custom "name" (after data) "\09\04\01\00\01d")
)

;; field names (10): type 0, field 0 = "f"
(module
  (type (struct (field (;(@name "f");) i32)))
  (@custom "name" (after data) "\0a\06\01\00\01\00\01f")
)

;; tag names (11): 0 = "x"
(module
  (type $t (func))
  (tag (;(@name "x");) (type $t))
  (@custom "name" (after data) "\0b\04\01\00\01x")
)

;; parameter names (12): type 0, parameter 0 = "x".
(module
  (type (func (param (;(@name "x");) i32)))
  (@custom "name" (after data) "\0c\06\01\00\01\00\01x")
)

;; tag parameter names (13): tag 0, parameter 0 = "c"
(module
  (type $t (func (param i32)))
  (tag (type $t) (param (;(@name "c");) i32))
  (@custom "name" (after data) "\0d\06\01\00\01\00\01c")
)


;; All subsections at once, in increasing id order

(module
  (type (struct (field i32)))          ;; type 0
  (type $ft (func (param i32)))        ;; type 1
  (func (local i32) block end)         ;; func 0, local 0, label 0
  (table 1 funcref)
  (memory 1)
  (global i32 (i32.const 0))
  (elem (i32.const 0) func 0)
  (data (i32.const 0) "x")
  (tag (type $ft))
  (@custom "name" (after data)
    "\00\02\01M"                       ;; 0  module name
    "\01\04\01\00\01f"                 ;; 1  function names
    "\02\06\01\00\01\00\01l"           ;; 2  local names
    "\03\06\01\00\01\00\01a"           ;; 3  label names
    "\04\09\02\00\02T0\01\02T1"        ;; 4  type names
    "\05\04\01\00\01t"                 ;; 5  table names
    "\06\04\01\00\01m"                 ;; 6  memory names
    "\07\04\01\00\01g"                 ;; 7  global names
    "\08\04\01\00\01e"                 ;; 8  element segment names
    "\09\04\01\00\01d"                 ;; 9  data segment names
    "\0a\08\01\00\01\00\03fld"         ;; 10 field names
    "\0b\06\01\00\03tag"               ;; 11 tag names
    "\0c\06\01\01\01\00\01x"           ;; 12 parameter names
    "\0d\06\01\00\01\00\01c"           ;; 13 tag parameter names
  )
)


;; Well-formed edge cases

;; An empty name map.
(module (@custom "name" (after data) "\01\01\00"))

;; An empty inner name map in an indirect name map.
(module (func) (@custom "name" (after data) "\02\03\01\00\00"))

;; An empty name.
(module (func) (@custom "name" (after data) "\01\03\01\00\00"))

;; Duplicate names.
(module (func) (func) (@custom "name" (after data) "\01\07\02\00\01a\01\01a"))


;; Section structure

;; Subsections must appear in increasing id order: 1 (function names) then 0 (module name)
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\04\\01\\00\\01f\\00\\02\\01M\"))"
  )
  "invalid name subsection id"
)

;; Each subsection may occur at most once: 1 (function names) twice
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data)"
    "    \"\\01\\04\\01\\00\\01f\\01\\04\\01\\00\\01g\"))"
  )
  "invalid name subsection id"
)

;; Invalid subsection id.
(assert_malformed_custom
  (module quote
    "(module (@custom \"name\" (after data) \"\\ff\\04\\01\\00\\01x\"))"
  )
  "invalid name subsection id"
)

;; Trailing bytes after the last subsection.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\04\\01\\00\\01f\\ff\"))"
  )
  "invalid name subsection id"
)

;; A name runs past the end of its subsection.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\04\\01\\00\\03f\"))"
  )
  "unexpected end of name subsection"
)
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data)"
    "    \"\\01\\04\\01\\00\\03f\\00\\02\\01M\"))"
  )
  "unexpected end of name subsection"
)

;; A subsection ends in the middle of a non-name.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\02\\01\\00\\01f\"))"
  )
  "unexpected end of name subsection"
)

;; A name map's count is too large.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\04\\02\\00\\01f\"))"
  )
  "unexpected end of name subsection"
)

;; A subsection's declared size exceeds the bytes remaining in the section.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\09\\01\\00\\01f\"))"
  )
  "unexpected end of name section"
)

;; The payload decodes but leaves bytes unconsumed inside the subsection.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\05\\01\\00\\01f\\ff\"))"
  )
  "name subsection size mismatch"
)

;; Names are UTF-8.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\04\\01\\00\\01\\ff\"))"
  )
  "malformed UTF-8 encoding"
)


;; Name map index constraints

;; Duplicate index in a name map.
(assert_malformed_custom
  (module quote
    "(module (func)"
    "  (@custom \"name\" (after data) \"\\01\\07\\02\\00\\01a\\00\\01b\"))"
  )
  "custom @name: duplicate function name"
)

;; Decreasing index in a name map.
(assert_malformed_custom
  (module quote
    "(module (func) (func)"
    "  (@custom \"name\" (after data) \"\\01\\07\\02\\01\\01b\\00\\01a\"))"
  )
  "custom @name: function names out of order"
)

;; Duplicate primary index in an indirect name map.
(assert_malformed_custom
  (module quote
    "(module (func (local i32))"
    "  (@custom \"name\" (after data)"
    "    \"\\02\\0b\\02\\00\\01\\00\\01a\\00\\01\\00\\01b\"))"
  )
  "custom @name: duplicate local name map"
)

;; Decreasing primary index in an indirect name map.
(assert_malformed_custom
  (module quote
    "(module (func (local i32)) (func (local i32))"
    "  (@custom \"name\" (after data)"
    "    \"\\02\\0b\\02\\01\\01\\00\\01b\\00\\01\\00\\01a\"))"
  )
  "custom @name: local name maps out of order"
)

;; Duplicate secondary index within one inner name map.
(assert_malformed_custom
  (module quote
    "(module (func (local i32))"
    "  (@custom \"name\" (after data)"
    "    \"\\02\\09\\01\\00\\02\\00\\01a\\00\\01b\"))"
  )
  "custom @name: duplicate local name"
)

;; Decreasing secondary index within one inner name map.
(assert_malformed_custom
  (module quote
    "(module (func (local i32) (local i64))"
    "  (@custom \"name\" (after data)"
    "    \"\\02\\09\\01\\00\\02\\01\\01b\\00\\01a\"))"
  )
  "custom @name: local names out of order"
)


;; Index spaces include imports

(module definition
  (import "m" "f" (func))
  (func)
  (@custom "name" (after data) "\01\04\01\01\01f")   ;; function 1 = "f"
)

(module definition
  (import "m" "t" (table 1 funcref))
  (table 1 funcref)
  (@custom "name" (after data) "\05\04\01\01\01t")   ;; table 1 = "t"
)

(module definition
  (import "m" "m" (memory 1))
  (memory 1)
  (@custom "name" (after data) "\06\04\01\01\01m")   ;; memory 1 = "m"
)

(module definition
  (import "m" "g" (global i32))
  (global i32 (i32.const 0))
  (@custom "name" (after data) "\07\04\01\01\01g")   ;; global 1 = "g"
)

(module definition
  (type $t (func))
  (import "m" "e" (tag (type $t)))
  (tag (type $t))
  (@custom "name" (after data) "\0b\04\01\01\01t")   ;; tag 1 = "t"
)

(assert_invalid_custom
  (module
    (type $t (func))
    (import "m" "e" (tag (type $t)))
    (tag (type $t))
    (@custom "name" (after data) "\0b\04\01\02\01?")
  )
  "custom @name: invalid tag index 2"
)

;; The local name subsection covers imported functions too.
(module definition
  (type $t (func (param i32)))
  (import "m" "f" (func (type $t)))
  (func (type $t))
  (@custom "name" (after data)
    "\02\0b\02\00\01\00\01p\01\01\00\01q"            ;; params of functions 0 and 1
  )
)


;; Out-of-range indices (with imports where possible)

(assert_invalid_custom
  (module (func) (@custom "name" (after data) "\01\04\01\01\01?"))
  "custom @name: invalid function index 1"
)
(assert_invalid_custom
  (module
    (import "m" "f" (func))
    (func)
    (@custom "name" (after data) "\01\04\01\02\01?")
  )
  "custom @name: invalid function index 2"
)

(assert_invalid_custom
  (module (func (local i32)) (@custom "name" (after data) "\02\06\01\01\01\00\01?"))
  "custom @name: invalid function index 1"
)
(assert_invalid_custom
  (module
    (import "m" "f" (func (param i32)))
    (func (local i32))
    (@custom "name" (after data) "\02\06\01\02\01\00\01?")
  )
  "custom @name: invalid function index 2"
)
(assert_invalid_custom
  (module (func (param i32) (local i64))
    (@custom "name" (after data) "\02\06\01\00\01\02\01?"))
  "custom @name: invalid local index 2 for function 0"
)

(assert_invalid_custom
  (module (func block end) (@custom "name" (after data) "\03\06\01\01\01\00\01?"))
  "custom @name: invalid function index 1"
)
(assert_invalid_custom
  (module (func block end) (@custom "name" (after data) "\03\06\01\00\01\01\01?"))
  "custom @name: invalid label index 1 for function 0"
)
(assert_invalid_custom
  (module (import "m" "f" (func)) (@custom "name" (after data) "\03\06\01\00\01\00\01?"))
  "custom @name: invalid label index 0 for function 0"
)

(assert_invalid_custom
  (module (type (func)) (@custom "name" (after data) "\04\04\01\01\01?"))
  "custom @name: invalid type index 1"
)

(assert_invalid_custom
  (module (table 1 funcref) (@custom "name" (after data) "\05\04\01\01\01?"))
  "custom @name: invalid table index 1"
)
(assert_invalid_custom
  (module
    (import "m" "t" (table 1 funcref))
    (table 1 funcref)
    (@custom "name" (after data) "\05\04\01\02\01?")
  )
  "custom @name: invalid table index 2"
)

(assert_invalid_custom
  (module (memory 1) (@custom "name" (after data) "\06\04\01\01\01?"))
  "custom @name: invalid memory index 1"
)
(assert_invalid_custom
  (module
    (import "m" "m" (memory 1))
    (memory 1)
    (@custom "name" (after data) "\06\04\01\02\01?")
  )
  "custom @name: invalid memory index 2"
)

(assert_invalid_custom
  (module (global i32 (i32.const 0))
    (@custom "name" (after data) "\07\04\01\01\01?"))
  "custom @name: invalid global index 1"
)
(assert_invalid_custom
  (module
    (import "m" "g" (global i32))
    (global i32 (i32.const 0))
    (@custom "name" (after data) "\07\04\01\02\01?")
  )
  "custom @name: invalid global index 2"
)

(assert_invalid_custom
  (module
    (func $f)
    (elem func $f)
    (@custom "name" (after data) "\08\04\01\01\01?")
  )
  "custom @name: invalid elem index 1"
)

(assert_invalid_custom
  (module
    (data "x")
    (@custom "name" (after data) "\09\04\01\01\01?")
  )
  "custom @name: invalid data index 1"
)

(assert_invalid_custom
  (module (type (struct (field i32)))
    (@custom "name" (after data) "\0a\06\01\01\01\00\01?"))
  "custom @name: invalid type index 1"
)

(assert_invalid_custom
  (module (type (struct (field i32)))
    (@custom "name" (after data) "\0a\06\01\00\01\01\01?"))
  "custom @name: invalid field index 1 for type 0"
)

(assert_invalid_custom
  (module (type $t (func)) (tag (type $t))
    (@custom "name" (after data) "\0b\04\01\01\01?"))
  "custom @name: invalid tag index 1"
)

(assert_invalid_custom
  (module (type (func (param i32)))
    (@custom "name" (after data) "\0c\06\01\01\01\00\01?"))
  "custom @name: invalid type index 1"
)
(assert_invalid_custom
  (module (type (func (param i32)))
    (@custom "name" (after data) "\0c\06\01\00\01\01\01?"))
  "custom @name: invalid param index 1 for type 0"
)

(assert_invalid_custom
  (module (type $t (func (param i32))) (tag (type $t))
    (@custom "name" (after data) "\0d\06\01\01\01\00\01?"))
  "custom @name: invalid tag index 1"
)
(assert_invalid_custom
  (module (type $t (func (param i32))) (tag (type $t))
    (@custom "name" (after data) "\0d\06\01\00\01\01\01?"))
  "custom @name: invalid param index 1 for tag 0"
)


;; Restrictions

;; Field names only apply to struct types.
(assert_invalid_custom
  (module (type (func)) (@custom "name" (after data) "\0a\06\01\00\01\00\01?"))
  "custom @name: non-struct type 0"
)

;; Parameter names only apply to function types.
(assert_invalid_custom
  (module (type (struct (field i32)))
    (@custom "name" (after data) "\0c\06\01\00\01\00\01?"))
  "custom @name: non-function type 0"
)
