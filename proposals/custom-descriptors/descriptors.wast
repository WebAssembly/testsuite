;; Type syntax

(module
  (rec
    (type (descriptor 1) (struct))
    (type (describes 0) (struct))
  )
)

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
