Introduction
============

There are many guides to Rust, including the [Rust Book].
This guide is something different:
it is intended for get the polyglot programmer,
and it contains the bare bones.
For the details, consult the [official documentation].

Overview - language
-------------------

Rust is a compiled language.

Rust's execution model is imperative, with strict evaluation
(except that there are types that embody lazy evaluation).

Rust is statically typed, with an algebraic type system.
It supports generic types (parameterised types) and generic functions.
Monomorphisation and dynmic despatch are both supported,
(chosen at the point where a generic type is referred to).

Rust is generally memory-safe and thread-safe,
but with a clearly-defined and well-used ``unsafe`` escape hatch.

Concurrency is supported by multithreading,
and alternatively via a green-threads-based ``async`` system.

There is no garbage collector.
Stack objects are explicitly defined and automatically deallocated.
Heap objects are explicitly allocated, and automatically deallocated
when their references go out of scope.
Rust has a novel memory and object lifetime management approach
with lifetime-based aliasing/mutability rules.

There are two macro systems for metaprogramming: a pattern matcher
(``macro_rules!``) and a very powerful system of arbitrary code
transformation (``proc_macro``).

There are stripped-down profiles of Rust without OS functions, and
without even a memory allocator, for use in embedded situations.

Overview - implementation, docs, tooling, etc.
----------------------------------------------

There is one implementation, ``rustc`` which is maintained by the Rust
project itself, alongside the documentation.

Code generation (to native code or WASM) is currently done via LLVM
but work is ongoing to allow use of [GCC] and [Cranelift].  There is
also an IR interpreter used mostly for validation.

There is no formal language specification.
The Rust Reference has most of the syntax but often lacks important details.

The standard library documentation is excellent and comprehensive.

For unsafe code, which plays with raw pointers etc.,
the semantics are formally described in [Stacked Borrows]
and programs can be checked by ``miri``,
the interpreter for the Rust Mid-Intermediate Representation.

Rust relies heavily on its ecosystem of libraries (aka "crates"),
and its convenient but securitywise-troubling package manager ``cargo``.
It is not practical to write any but the smallest programs
without using external libraries.
Conversely, the library ecosystem is rich and generally of high quality
although slightly lacking in certain areas
(especially "webby" areas when compared with more "webby" languages).
