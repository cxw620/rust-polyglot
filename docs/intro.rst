Introduction and overview
=========================

..
    Copyright 2021 Ian Jackson and contributors
    SPDX-License-Identifier: MIT
    There is NO WARRANTY.

There are many guides to Rust, including the [Rust Book].
This guide is something different:
it is intended for the experienced programmer
who already knows many other programming languages.
Also this guide is not entirely free of opinion.

I try to give enough information to get you started,
but to avoid going into too much detail.

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
but with a clearly-defined and well-used ``unsafe`` escape hatch.

Concurrency is supported by multithreading,
and alternatively via a green-threads-based ``async`` system.
Uniquely, concurrent Rust programs are memory-safe.

There is no garbage collector.
Stack objects are explicitly defined and automatically deallocated.
Heap objects are explicitly allocated, and automatically deallocated
when their references go out of scope.
Rust has a novel memory and object lifetime management approach
with lifetime-based aliasing/mutability rules.

There are two macro systems for metaprogramming: a pattern matcher
(``macro_rules!``) and a very powerful system of arbitrary code
transformation (``proc_macro``).

There are fully-supported stripped-down profiles of the Rust standard library
without OS functions (``alloc``), and
without even a memory allocator (``core``),
for use in embedded situations.

The concrete syntax has many influences.
The basic function and expression syntax resembles "bracey" languages,
but with some wrinkles.
Notably,
``( )`` are not required around the control expression for ``if`` etc.
but ``{ }`` *are* required around the controlled statement block.

There is little meaningful separate compilation.
The usual aggregation of the Rust libraries making up a single Rust program
involves obtaining all of the source code to all the libraries
and building them into a single executable with static linking.

There is a good FFI system to talk to C
(and libraries for convenient interfacing to C++, WASM, Python,...)
Generally, dynamic linking is still used for FFI libraries.

The unit of compilation is large: the "crate", not file or module.

implementation, docs, tooling, etc.
-----------------------------------

There is one implementation, ``rustc``
which is maintained by the Rust project itself,
alongside the specifications and documentation.

Compilation is slow by comparison with many other modern languages,
but the runtime speed of idiomatic Rust code is extremely good.

Code generation (to native code or WASM) is currently done via LLVM
but work is ongoing to allow use of [GCC] and [Cranelift].  There is
also an IR interpreter used mostly for validation.

There is no formal language specification.
The Rust Reference has most of the syntax but often lacks
important information about semantics and details.

The standard library documentation is excellent and comprehensive.

For unsafe code, which plays with raw pointers etc.,
the semantics are formally described in [Stacked Borrows]
and programs can be checked by ``miri``,
the interpreter for the Rust Mid-Intermediate Representation.

Rust is available in "stable", "beta" and "nightly" flavours.
Rust intends to avoid (and in practice, generally does avoid)
breaking existing code which was using stable interfaces.

Library ecosystem
-----------------

Rust relies heavily on its ecosystem of libraries (aka "crates"),
and its convenient but securitywise-troubling
language-specific package manager ``cargo``.
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
 * Effective collaboration between practicing developers and
   academic programming language and formal methods experts.

There is also a strong desire to help the programmer
with accessible documentation and useful error messages,
but generally ease of programming is traded off in favour of correctness,
and sometimes performance.
