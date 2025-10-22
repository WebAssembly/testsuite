;; Type syntax

(module
  (rec
    (type (descriptor 1) (struct))
    (type (describes 0) (struct))
  )
  (rec
    (type $a (descriptor $b) (struct))
    (type $b (describes $a) (struct))
  )
  (rec
    (type $c (sub (descriptor $d) (struct)))
    (type $d (sub (describes $c) (struct)))
  )
  (rec
    (type $e (sub final (descriptor $f) (struct)))
    (type $f (sub final (describes $e) (struct)))
  )
  (rec
    (type $g (sub $c (descriptor $h) (struct)))
    (type $h (sub $d (describes $g) (struct)))
  )
  (rec
    (type $i (sub final $g (descriptor $j) (struct (field i32))))
    (type $j (sub final $h (describes $i) (struct (field f32))))
  )
  (rec
    (type $k (descriptor $l) (struct))
    (type $l (describes $k) (descriptor $m) (struct))
    (type $m (describes $l) (struct))
  )
)

;; Describes clause must precede descriptor clause.
(assert_malformed
  (module quote
    "(rec"
    "  (type $a (descriptor $b) (struct))"
    "  (type $b (descriptor $c) (describes $a) (struct))"
    "  (type $c (describes $b) (struct))"
    ")"
  )
  "unexpected token"
)

;; Cannot have multiple descriptor clauses.
(assert_malformed
  (module quote
    "(rec"
    "  (type $a (descriptor $b) (descriptor $b) (struct))"
    "  (type $b (describes $a) (struct))"
    ")"
  )
  "unexpected token"
)

;; Cannot have multiple describes clauses.
(assert_malformed
  (module quote
    "(rec"
    "  (type $a (descriptor $b) (struct))"
    "  (type $b (describes $a) (describes $a) (struct))"
    ")"
  )
  "unexpected token"
)

;; Type validation

(assert_invalid
  (module
    (type (descriptor 1) (struct))
  )
  "descriptor type is outside rec group"
)

(assert_invalid
  (module
    (type (describes 1) (struct))
  )
  "described type is outside rec group"
)

(assert_invalid
  (module
    (type (descriptor 1) (struct))
    (type (struct))
  )
  "descriptor type is outside rec group"
)

(assert_invalid
  (module
    (type (describes 1) (struct))
    (type (struct))
  )
  "described type is outside rec group"
)

(assert_invalid
  (module
    (type (struct))
    (type (descriptor 0) (struct))
  )
  "descriptor type is outside rec group"
)

(assert_invalid
  (module
    (type (struct))
    (type (describes 0) (struct))
  )
  "described type is outside rec group"
)

(assert_invalid
  (module
    (rec
      (type (descriptor 1) (struct))
      (type (struct))
    )
  )
  "type is not described by its descriptor"
)

(assert_invalid
  (module
    (rec
      (type (struct))
      (type (describes 0) (struct))
    )
  )
  "described type is not described by descriptor"
)

(assert_invalid
  (module
    (rec
      (type (describes 1) (struct))
      (type (descriptor 0) (struct))
    )
  )
  "forward use of described type"
)

(assert_invalid
  (module
    (type (describes 0) (descriptor 0) (struct))
  )
  "forward use of described type"
)

(assert_invalid
  (module
    (type (descriptor 1) (struct))
    (type (describes 0) (struct))
  )
  "descriptor type is outside rec group"
)

(assert_invalid
  (module
    (rec
      (type (descriptor 1) (func))
      (type (describes 0) (struct))
    )
  )
  "descriptor type must be a struct"
)

(assert_invalid
  (module
    (rec
      (type (descriptor 1) (struct))
      (type (describes 0) (func))
    )
  )
  "described type must be a struct"
)

(assert_invalid
  (module
    (rec
      (type (descriptor 1) (func))
      (type (describes 0) (func))
    )
  )
  "descriptor type must be a struct"
)

(assert_invalid
  (module
    (rec
      (type (descriptor 1) (array i8))
      (type (describes 0) (struct))
    )
  )
  "descriptor type must be a struct"
)

(assert_invalid
  (module
    (rec
      (type (descriptor 1) (struct))
      (type (describes 0) (array i8))
    )
  )
  "described type must be a struct"
)

(assert_invalid
  (module
    (rec
      (type (descriptor 1) (array i8))
      (type (describes 0) (array i8))
    )
  )
  "descriptor type must be a struct"
)

;; Subtyping

(module
  (rec
    (type $A (sub (descriptor $A.desc) (struct)))
    (type $A.desc (sub (describes $A) (struct)))
    (type $B (sub $A (descriptor $B.desc) (struct)))
    (type $B.desc (sub $A.desc (describes $B) (struct)))
  )
)

(module
  (rec
    (type $A (sub (descriptor $A.desc) (struct)))
    (type $B (sub $A (descriptor $B.desc) (struct)))
    (type $A.desc (sub (describes $A) (struct)))
    (type $B.desc (sub $A.desc (describes $B) (struct)))
  )
)

(module
  (rec
    (type $A (sub (descriptor $A.desc) (struct)))
    (type $A.desc (sub (describes $A) (struct)))
  )
  (rec
    (type $B (sub $A (descriptor $B.desc) (struct)))
    (type $B.desc (sub $A.desc (describes $B) (struct)))
  )
)

;; If a subtype has a descriptor, its supertype does not need to have a
;; descriptor.
(module
  (rec
    (type $A (sub (struct)))
    (type $B (sub $A (descriptor $B.desc) (struct)))
    (type $B.desc (sub (describes $B) (struct)))
  )
)
(module
  (rec
    (type $A (sub (struct)))
  )
  (rec
    (type $B (sub $A (descriptor $B.desc) (struct)))
    (type $B.desc (sub (describes $B) (struct)))
  )
)

;; If a supertype has a descriptor, its subtype must also have a descriptor.
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
      (type $B (sub $A (struct)))
    )
  )
  "sub type 2 does not match super type 0"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
    )
    (rec
      (type $B (sub $A (struct)))
    )
  )
  "sub type 2 does not match super type 0"
)


;; If a subtype has a described type, its supertype must also have a described
;; type.
(assert_invalid
  (module
    (rec
      (type $A.desc (sub (struct)))
      (type $B (sub (descriptor $B.desc) (struct)))
      (type $B.desc (sub $A.desc (describes $B) (struct)))
    )
  )
  "sub type 2 does not match super type 0"
)
(assert_invalid
  (module
    (rec
      (type $A.desc (sub (struct)))
    )
    (rec
      (type $B (sub (descriptor $B.desc) (struct)))
      (type $B.desc (sub $A.desc (describes $B) (struct)))
    )
  )
  "sub type 2 does not match super type 0"
)

;; If a supertype has a described type, its subtype must also have a described
;; type.
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
      (type $B.desc (sub $A.desc (struct)))
    )
  )
  "sub type 2 does not match super type 1"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
    )
    (rec
      (type $B.desc (sub $A.desc (struct)))
    )
  )
  "sub type 2 does not match super type 1"
)

;; The subtype's descriptor must be a subtype of the supertype's descriptor.
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
      (type $B (sub $A (descriptor $B.desc) (struct)))
      (type $B.desc (sub (describes $B) (struct))) ;; Not a subtype of A.desc.
    )
  )
  "descriptor type 3 does not match"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
    )
    (rec
      (type $B (sub $A (descriptor $B.desc) (struct)))
      (type $B.desc (sub (describes $B) (struct))) ;; Not a subtype of A.desc.
    )
  )
  "descriptor type 3 does not match"
)


;; The supertype's described type must be a supertype of the subtype's described
;; type.
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
      (type $B (sub (descriptor $B.desc) (struct))) ;; Not a subtype of A.
      (type $B.desc (sub $A.desc (describes $B) (struct)))
    )
  )
  "described type 2 does not match"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
    )
    (rec
      (type $B (sub (descriptor $B.desc) (struct))) ;; Not a subtype of A.
      (type $B.desc (sub $A.desc (describes $B) (struct)))
    )
  )
  "described type 2 does not match"
)

;; The supertype of a descriptor must describe the supertype of the descriptor's
;; described type.
(assert_invalid
  (module
    (rec
      (type $A (sub (struct))) ;; Not described by A.desc.
      (type $A.desc (sub (struct))) ;; Does not describe A.
      (type $B (sub $A (descriptor $B.desc) (struct)))
      (type $B.desc (sub $A.desc (describes $B) (struct)))
    )
  )
  "sub type 3 does not match super type 1"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (struct))) ;; Not described by A.desc.
      (type $A.desc (sub (struct))) ;; Does not describe A.
    )
    (rec
      (type $B (sub $A (descriptor $B.desc) (struct)))
      (type $B.desc (sub $A.desc (describes $B) (struct)))
    )
  )
  "sub type 3 does not match super type 1"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (struct))) ;; Not described by A.desc.
    )
    (rec
      (type $A.desc (sub (struct))) ;; Does not describe A.
    )
    (rec
      (type $B (sub $A (descriptor $B.desc) (struct)))
      (type $B.desc (sub $A.desc (describes $B) (struct)))
    )
  )
  "sub type 3 does not match super type 1"
)

;; The subtype of a descriptor must describe a subtype of the descriptor's
;; described type.
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
      (type $B (sub $A (struct))) ;; Not described by B.desc.
      (type $B.desc (sub $A.desc (struct))) ;; Does not describe B.
    )
  )
  "sub type 2 does not match super type 0"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
    )
    (rec
      (type $B (sub $A (struct))) ;; Not described by B.desc.
      (type $B.desc (sub $A.desc (struct))) ;; Does not describe B.
    )
  )
  "sub type 2 does not match super type 0"
)
(assert_invalid
  (module
    (rec
      (type $A (sub (descriptor $A.desc) (struct)))
      (type $A.desc (sub (describes $A) (struct)))
    )
    (rec
      (type $B (sub $A (struct))) ;; Not described by B.desc.
    )
    (rec
      (type $B.desc (sub $A.desc (struct))) ;; Does not describe B.
    )
  )
  "sub type 2 does not match super type 0"
)
