# -*- perl -*-
#
# sourced by generate-inputs

$title = "Rust for the Polyglot Programmer";

@crate_refs_docs_rs = qw(
   anyhow
   arrayvec
   bstr
   bytemuck
   chrono
   chrono-tz
   crossbeam
   easy-ext
   eyre
   getopts
   glob
   gumdrop
   hyper
   index_vec
   indexmap
   jni
   lazy-regex
   lazy_static
   log
   ndarray
   num-derive
   once_cell
   pyo3
   reqwest
   ring
   tempfile
   thiserror
   tracing
   ureq
   warp
);
@crate_refs_crates_io = qw(
   argparse
   clap
   either
   env_logger
   generational_arena
   itertools
   j4rs
   libc
   ndarray-linalg
   nix
   num
   num-traits
   parking_lot
   rand
   rayon
   regex
   rustix
   rustls
   rusty_v8
   slab
   slotmap
   structopt
   strum
   void
   wasm-bindgen
   web-sys
);

1;
