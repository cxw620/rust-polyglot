Introduction and overview
=========================

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

There are many guides and introductions to Rust.

This one is something different:
it is intended for the experienced programmer
who already knows many other programming languages.

I try to be comprehensive enough to be a starting point
for any area of Rust,
but to avoid going into too much detail
except where things are not as you might expect.

Also this guide is not entirely free of opinion,
including recommendations of libraries (crates), tooling, etc.

Alternatives or supplements to this guide
-----------------------------------------

 * Ralf Biedert's
   ["Rust Language Cheat Sheet"](https://cheats.rs/),
   A comprehensive summary reference,
   with diagrams,
   running to 68 pages in [PDF form](https://cheats.rs/rust_cheat_sheet.pdf).

 * The [Rust Book](https://doc.rust-lang.org/book/).
   Much more accessible, and less dense.

 * Official docs:
   the [Standard Library reference](https://doc.rust-lang.org/std/)
   (excellent) and the
   [Reference]
   (woefully incomplete).

Language
--------

Rust is a compiled language.

Rust's execution model is imperative, with strict evaluation
(except that there are types that embody lazy evaluation).

Rust is statically typed, with an algebraic type system.
It supports generic types (parameterised types) and generic functions.
Monomorphisation and dynamic despatch are both supported
(chosen at the point where a generic type is referred to).
Type inference is supported in some contexts,
especially local variables.

Rust is memory-safe and thread-safe,
but with a clearly-defined and well-used `unsafe` escape hatch.

Concurrency is supported by multithreading,
and alternatively via a green-threads-based 
`async` system.
Concurrent Rust programs are still memory-safe.

There is no garbage collector.
Stack objects are explicitly defined and automatically deallocated.
Heap objects are explicitly allocated, and automatically deallocated
when their references go out of scope.
Rust has a novel
memory and object lifetime management approach
with lifetime-based aliasing/mutability rules.

There are two macro systems for metaprogramming: a pattern matcher
(`macro_rules!`) and a very powerful system of arbitrary code
transformation (`proc_macro`).

There are fully-supported stripped-down profiles of the Rust standard library
without OS functions (`alloc`), and
without even a memory allocator (`core`),
for use in embedded situations.

The concrete syntax has many influences.
The basic function and expression syntax resembles "bracey" languages,
but with some wrinkles.
Notably:
`( )` are not required around the control expression for `if` etc.
but `{ }` *are* required around the controlled statement block;
and, presence vs absence of `;` at the end of a block is highly significant.

There is little meaningful separate compilation.
The usual aggregation of the Rust libraries making up a single Rust program
involves obtaining all of the source code to all the libraries
and building them into a single executable with static linking.

There is a good FFI system to talk to C
(and libraries for convenient interfacing to C++, WASM, Python,...)
Generally, dynamic linking is still used for FFI libraries.

The unit of compilation is large: the "crate", not file or module.

Implementation, docs, tooling, etc.
-----------------------------------

There is one principal implementation, `rustc`
which is maintained by the [Rust project](https://www.rust-lang.org/) itself,
alongside the specifications and documentation.

Compilation is slow by comparison with many other modern languages,
but the runtime speed of idiomatic Rust code is extremely good.

Code generation (to native code or WASM) is currently done via LLVM
but work is ongoing to allow use of
[GCC](https://blog.antoyo.xyz/rustc_codegen_gcc-progress-report-3)
and
[Cranelift](https://github.com/bjorn3/rustc_codegen_cranelift/blob/master/Readme.md).
There is also an
[IR interpreter](https://github.com/rust-lang/miri#readme)
used mostly for validation.

There is no formal language specification.
The [Rust Reference][Reference]
has most of the syntax but usually lacks
important information about semantics and details.

The [standard library documentation](https://doc.rust-lang.org/std/)
is excellent and comprehensive.

For unsafe code, which plays with raw pointers etc.,
the semantics are formally but unofficially described in
[Stacked Borrows](https://github.com/rust-lang/unsafe-code-guidelines/blob/master/wip/stacked-borrows.md)
and programs can be checked by [Miri](https://github.com/rust-lang/miri),
the interpreter for the Rust Mid-Intermediate Representation.

Rust is available in "stable", "beta" and "nightly" flavours.
Rust intends to avoid (and in practice, generally does avoid)
breaking existing code which was using stable interfaces.

There is [excellent support for cross-compilation](https://rust-lang.github.io/rustup/cross-compilation.html).

The project provides an [online playground](https://play.rust-lang.org/)
for playing with and sharing small experiments.
This is heavily used as a stable way to share snippets, repros, etc.,
including in bug reports.

Obtaining Rust is canonically done with rustup,
a pre-packaged installer/updater tool.
rustup's rather alarming `curl|bash`
[install rune](https://www.rust-lang.org/tools/install)
is mitigated by the care taken by the rustup maintainers;
however, you will also end up using cargo which is more of a problem.

Library ecosystem
-----------------

Rust relies heavily on its ecosystem of libraries (aka "crates"),
and its convenient but securitywise-troubling
language-specific package manager `cargo`.
It is not practical to write any but the smallest programs
without using external libraries.

Conversely, the library ecosystem is rich and generally of high quality
although slightly lacking in certain areas
(especially "webby" areas when compared with more "webby" languages).

The Rust ecosystem contains some exceptional and unique libraries,
which can conveniently provide advanced capabilities
found elsewhere only in special-purpose or research languages (if at all).

The combination of static linking of Rust libraries,
with heavy use of monomorphised generic code,
can lead to very large binaries.

The Rust Project
----------------

The Rust Project has robust and mature governance and review processes.
The compiler implementation quality is high
and the project is exceptionally welcoming.

Notable ideological features of the Rust community are:

 * A strong desire to help the programmer write correct code,
   including a desire for the compiler to take responsibility
   for preventing programmer error.
 * Pride in helping users write performant code.
 * Effective collaboration between practising developers and
   academic programming language and formal methods experts.
   ([Comprehensive survey](https://github.com/newca12/awesome-rust-formalized-reasoning).)

There is also a strong desire to help the programmer
with accessible documentation and useful error messages,
but generally ease of programming is traded off in favour of correctness,
and sometimes performance.
