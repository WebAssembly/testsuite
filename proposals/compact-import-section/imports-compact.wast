;; Auxiliary module to import from

(module
  (func (export "func->11i") (result i32) (i32.const 11))
  (func (export "func->22f") (result f32) (f32.const 22))
  (global (export "global->1") i32 (i32.const 1))
  (global (export "global->20") i32 (i32.const 20))
  (global (export "global->300") i32 (i32.const 300))
  (global (export "global->4000") i32 (i32.const 4000))
)
(register "test")


;; Basic behavior

(module
  (import "test"
    (item "func->11i" (func (result i32)))
    (item "func->22f" (func (result f32)))
  )
  (import "test"
    (item "global->1")
    (item "global->20")
    (item "global->300")
    (item "global->4000")
    (global i32)
  )

  (global i32 (i32.const 50000))

  (func (export "sum1") (result i32)
    (local i32)

    call 0
    (i32.trunc_f32_s (call 1))
    i32.add
  )
  (func (export "sum2") (result i32)
    (local i32)

    global.get 0
    global.get 1
    global.get 2
    global.get 3
    i32.add
    i32.add
    i32.add
  )

  ;; Tests that indices were tracked correctly
  (func (export "sum3") (result i32)
    call 2 ;; sum1
    call 3 ;; sum2
    i32.add

    global.get 4
    i32.add
  )
)

(assert_return (invoke "sum1") (i32.const 33))
(assert_return (invoke "sum2") (i32.const 4321))
(assert_return (invoke "sum3") (i32.const 54354))

(module (import "test" (item "func->11i" (func (result i32)))))
(assert_unlinkable
  (module (import "test" (item "unknown" (func (result i32)))))
  "unknown import"
)
(assert_unlinkable
  (module (import "test" (item "func->11i" (func (result i32))) (item "unknown" (func (result i32)))))
  "unknown import"
)

(module (import "test" (item "func->11i") (func (result i32))))
(assert_unlinkable
  (module (import "test" (item "unknown") (func (result i32))))
  "unknown import"
)
(assert_unlinkable
  (module (import "test" (item "func->11i") (item "unknown") (func (result i32))))
  "unknown import"
)

(assert_unlinkable
  (module (import "test" (item "func->11i" (func))))
  "incompatible import type"
)
(assert_unlinkable
  (module (import "test" (item "func->11i" (func (result i32))) (item "func->22f" (func))))
  "incompatible import type"
)

(assert_unlinkable
  (module (import "test" (item "func->11i") (item "func->22f") (func (result i32))))
  "incompatible import type"
)


;; Zero-length groups

(module (import "not-test")) ;; encoding 1
(module (import "not-test" (func))) ;; encoding 2

(module
  (import "test")
  (import "test" (func (result i32)))                       ;; no func
  (import "test" (item "func->11i" (func (result i32))))    ;; func 0
  (import "test" (global i32))                              ;; no global
  (import "test" (item "global->20") (global i32))          ;; global 0

  (func (export "check") (result i32)
    call 0
    global.get 0
    i32.add
  )
)
(assert_return (invoke "check") (i32.const 31))

(module
  (import "not-test" (func (param i32)))  ;; still implicitly defines a func type
  (func (type 0))
)


;; Identifiers

(module
  (import "test" "func->11i" (func $f11i (result i32)))
  (import "test"
    (item "global->1" (global $g1 i32))
    (item "global->20" (global $g20 i32))
  )
  ;; Shared-type form does not allow identifiers

  (func (export "sum") (result i32)
    call $f11i
    global.get $g1
    global.get $g20
    i32.add
    i32.add
  )
)

(assert_return (invoke "sum") (i32.const 32))

(assert_malformed
  (module quote "(import \"test\" (func $foo))")
  "identifier not allowed"
)
(assert_malformed
  (module quote "(import \"test\" (item \"foo\") (func $foo))")
  "identifier not allowed"
)
(assert_malformed
  (module quote "(import \"test\" (item \"foo\") (item \"bar\") (func $foo))")
  "identifier not allowed"
)


;; All externtype kinds in a single encoding-1 group

(module
  (func (export "f") (result i32) (i32.const 1000))
  (table (export "t") 30 funcref)
  (memory (export "m") 1)
  (global (export "g") i32 (i32.const 700))
  (tag (export "e") (param i32))
)
(register "test-all")

(module
  (import "test-all"
    (item "f" (func (result i32)))
    (item "t" (table 3 funcref))
    (item "m" (memory 1))
    (item "g" (global i32))
    (item "e" (tag (param i32)))
  )

  (func (export "check") (result i32)
    call 0          ;; 1000
    table.size 0    ;; 30
    memory.size     ;; 1
    global.get 0    ;; 700
    i32.add
    i32.add
    i32.add
  )

  (func (export "throw-and-catch") (param i32) (result i32)
    (block $h (result i32)
      (try_table (result i32) (catch 0 $h)
        (throw 0 (local.get 0))
      )
    )
  )
)

(assert_return (invoke "check") (i32.const 1731))
(assert_return (invoke "throw-and-catch" (i32.const 42)) (i32.const 42))


;; Test encoding 2 for all externtypes

(module
  (func (export "f1") (result i32) (i32.const 1))
  (func (export "f2") (result i32) (i32.const 10))
  (table (export "t1") 2 funcref)
  (table (export "t2") 20 funcref)
  (memory (export "m1") 3)
  (memory (export "m2") 30)
  (global (export "g1") i32 (i32.const 4))
  (global (export "g2") i32 (i32.const 40))
  (tag (export "e1") (param i32))
  (tag (export "e2") (param i32))
)
(register "test-pairs")

(module
  (import "test-pairs" (item "f1") (item "f2") (func (result i32)))
  (func (export "sum") (result i32)
    (i32.add (call 0) (call 1))
  )
)
(assert_return (invoke "sum") (i32.const 11))

(module
  (import "test-pairs" (item "t1") (item "t2") (table 1 funcref))
  (func (export "sizes") (result i32)
    (i32.add (table.size 0) (table.size 1))
  )
)
(assert_return (invoke "sizes") (i32.const 22))

(module
  (import "test-pairs" (item "m1") (item "m2") (memory 1))
  (func (export "sizes") (result i32)
    (i32.add (memory.size 0) (memory.size 1))
  )
)
(assert_return (invoke "sizes") (i32.const 33))

(module
  (import "test-pairs" (item "g1") (item "g2") (global i32))
  (func (export "sum") (result i32)
    (i32.add (global.get 0) (global.get 1))
  )
)
(assert_return (invoke "sum") (i32.const 44))

(module
  (import "test-pairs" (item "e1") (item "e2") (tag (param i32)))
  (func (export "throw-1") (result i32)
    (block $h (result i32)
      (try_table (result i32) (catch 0 $h)
        (throw 0 (i32.const 5))
      )
    )
  )
  (func (export "throw-2") (result i32)
    (block $h (result i32)
      (try_table (result i32) (catch 1 $h)
        (throw 1 (i32.const 50))
      )
    )
  )
)
(assert_return (invoke "throw-1") (i32.const 5))
(assert_return (invoke "throw-2") (i32.const 50))

(assert_unlinkable
  (module (import "test-pairs" (item "t1") (item "t2") (table 1 externref)))
  "incompatible import type"
)


;; Mixed traditional + compact, same module name, index allocation

(module
  (func (export "f0") (result i32) (i32.const 1))
  (func (export "f1") (result i32) (i32.const 20))
  (func (export "f2") (result i32) (i32.const 300))
  (global (export "g0") i32 (i32.const 4000))
  (global (export "g1") i32 (i32.const 50000))
  (global (export "g2") i32 (i32.const 600000))
)
(register "mixed")

(module
  ;; Non-compact encoding
  (import "mixed" "f0" (func (result i32)))               ;; func 0
  (import "mixed" "f1" (func (result i32)))               ;; func 1

  ;; Encoding 1
  (import "mixed"
    (item "g2" (global i32))                              ;; global 0
    (item "f2" (func (result i32))))                      ;; func 2

  ;; Encoding 2
  (import "mixed" (item "g0") (item "g1") (global i32))   ;; globals 1, 2

  (func (export "check") (result i32)
    call 0
    call 1
    call 2
    global.get 0
    global.get 1
    global.get 2
    i32.add
    i32.add
    i32.add
    i32.add
    i32.add
  )
)
(assert_return (invoke "check") (i32.const 654321))


;; Empty item name inside a compact group

(module
  (func (export "") (result i32) (i32.const 0xab))
)
(register "")

(module
  (import "" (item "" (func (result i32))))
  (func (export "call-empty") (result i32) call 0)
)
(assert_return (invoke "call-empty") (i32.const 0xab))
