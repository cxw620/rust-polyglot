# -*- perl -*-
#
# sourced by generate-inputs

$title = "DRAFT - Rust for the Polyglot Programmer";

$precontents = <<END;
Rust for the experienced programmer, a DRAFT guide.

See the [Introduction](intro.md) for
the rubric, goals, and non-goals.
See the [Colophon](colophon.md) for
authorship and acknowledgements,
making contributions and corrections,
and document source code,

### THIS IS A DRAFT - FOR REVIEW BY THE RUST COMMUNITY

I would greatly appreciate feedback from fellow Rustaceans.

I am interested in reports of any or all of
 * Technical errors
 * Significant omissions
 * Duplication, redundancy, verbosity, or otioseness
 * Differences of opinion especially about crate recommendations,

See the [Colophon](colophon.md) for information about contributing
including a link to the Gitlab repo.

I hope to remove the "draft" label and
release this document to a general audience
soon after Thursday the 23rd of September.

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
