;; Descriptor and describes pair.
(module binary
  "\00asm" "\01\00\00\00"
  "\01"  ;; Type section id
  "\0b"  ;; Type section length
  "\01"  ;; Types vector length
  "\4e"  ;; Recursion group
  "\02"  ;; Rec group size
  "\4d"  ;; Descriptor
  "\01"  ;; Descriptor type index
  "\5f"  ;; Struct
  "\00"  ;; Number of fields
  "\4c"  ;; Describes
  "\00"  ;; Describes type index
  "\5f"  ;; Struct
  "\00"  ;; Number of fields
)

;; Cannot have multiple descriptor clauses.
(assert_malformed
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\0d"  ;; Type section length
    "\01"  ;; Types vector length
    "\4e"  ;; Recursion group
    "\02"  ;; Rec group size
    "\4d"  ;; Descriptor
    "\01"  ;; Descriptor type index
    "\4d"  ;; Descriptor (repeated)
    "\01"  ;; Descriptor type index
    "\5f"  ;; Struct
    "\00"  ;; Number of fields
    "\4c"  ;; Describes
    "\00"  ;; Describes type index
    "\5f"  ;; Struct
    "\00"  ;; Number of fields
  )
  "malformed definition type"
)

;; Cannot have multiple describes clauses.
(assert_malformed
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\0d"  ;; Type section length
    "\01"  ;; Types vector length
    "\4e"  ;; Recursion group
    "\02"  ;; Rec group size
    "\4d"  ;; Descriptor
    "\01"  ;; Descriptor type index
    "\5f"  ;; Struct
    "\00"  ;; Number of fields
    "\4c"  ;; Describes
    "\00"  ;; Describes type index
    "\4c"  ;; Describes (repeated)
    "\00"  ;; Describes type index
    "\5f"  ;; Struct
    "\00"  ;; Number of fields
  )
  "malformed definition type"
)

;; Descriptor chain with three types.
(module binary
  "\00asm" "\01\00\00\00"
  "\01"  ;; Type section id
  "\11"  ;; Type section length
  "\01"  ;; Types vector length
  "\4e"  ;; Recursion group
  "\03"  ;; Rec group size
  "\4d"  ;; Descriptor
  "\01"  ;; Descriptor type index
  "\5f"  ;; Struct
  "\00"  ;; Number of fields
  "\4c"  ;; Describes
  "\00"  ;; Describes type index
  "\4d"  ;; Descriptor
  "\02"  ;; Descriptor type index
  "\5f"  ;; Struct
  "\00"  ;; Number of fields
  "\4c"  ;; Describes
  "\01"  ;; Describes type index
  "\5f"  ;; Struct
  "\00"  ;; Number of fields
)

;; Descriptor chain with three types, but middle type has descriptor before
;; describes.
(assert_malformed
  (module binary
    "\00asm" "\01\00\00\00"
    "\01"  ;; Type section id
    "\11"  ;; Type section length
    "\01"  ;; Types vector length
    "\4e"  ;; Recursion group
    "\03"  ;; Rec group size
    "\4d"  ;; Descriptor
    "\01"  ;; Descriptor type index
    "\5f"  ;; Struct
    "\00"  ;; Number of fields
    "\4d"  ;; Descriptor - This is out of order
    "\02"  ;; Descriptor type index
    "\4c"  ;; Describes
    "\00"  ;; Describes type index
    "\5f"  ;; Struct
    "\00"  ;; Number of fields
    "\4c"  ;; Describes
    "\01"  ;; Describes type index
    "\5f"  ;; Struct
    "\00"  ;; Number of fields
  )
  "malformed definition type"
)
