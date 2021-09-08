# -*- perl -*-
#
# sourced by generate-inputs

$title = "DRAFT - Rust for the Polyglot Programmer";

$precontents = <<END;
END

@crate_refs_docs_rs = qw(
   anyhow
   arrayvec
   crossbeam
   easy-ext
   eyre
   index_vec
   indexmap
   num-derive
   thiserror
   chrono
   chrono-tz
   lazy_static
   once_cell
   tracing
   ndarray
   lazy-regex
   log
   glob
   tempfile
   reqwest
   hyper
   pyo3
   warp
   getopts
   gumdrop
   jni
   ring
);
@crate_refs_crates_io = qw(
   generational_arena
   itertools
   num-traits
   num
   parking_lot
   rayon
   slab
   slotmap
   strum
   libc
   nix
   env_logger
   regex
   rand
   either
   ndarray-linalg
   void
   structopt
   clap
   argparse
   wasm-bindgen
   web-sys
   rusty_v8
   j4rs
   rustls
);

1;
