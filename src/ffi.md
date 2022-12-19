FFI
===

[comment]: # ( Copyright 2021-2022 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Rust has a range of FFI support
for interworking with other languages.

Raw C FFI
---------

Built into the language,
you can write [`extern "C" { ... }`](https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html#using-extern-functions-to-call-external-code)
and both define and call C functions.

You have to write out a Rust version of the prototype of the C function.
This is somewhat subtle,
especially if the types are nontrivial.
This is all, of course, `unsafe`.

You can exchange both references and raw pointers with C.
If you use references, it is up to you to define the lifetimes
and aliasing behaviour
on the Rust side in a way consistent with the behaviour of the C.
You will need to obey both C's and Rust's aliasing rules!

An `Option<&T>` is represented at the FFI as a pointer,
despite the `Option`.
This is because a reference `&T` cannot be null.
So a null pointer corresponds to `None`.
Nullable pointer arguments must appear in Rust as
`Option<&T>` (or `*T`);
existence of an actually-null `&T` is instant UB.

The
[FFI chapter in the Nomicon](https://doc.rust-lang.org/nomicon/ffi.html)
is comprehensive.
You may also need to look at 
[Type Layout in the Reference][type layout].

Rust's various string types are typically not the same as the platform's.
Use [std::ffi](https://doc.rust-lang.org/std/ffi/).

The raw FFI system has no direct interworking with C++
(but see below).

It is usual to wrap up `unsafe` FFI interfaces
with a safe-to-call veneer.
These are often in different crates,
for separate compilation reasons etc.,
in which case conventionally the unsafe FFI crate is called `...-sys`.


FFI support crates
------------------

There are a range of crates which allow convenient interworking
with a variety of languages.

 * C++: [`cxx`]
 * Python: [`inline-python`], [`pyo3`]
 * JS/DOM/WASM: [`wasm-bindgen`] (do *not* use `wasm-pack`), [`web-sys`].  [`rusty_v8`].
 * Java: [`j4rs`], [`jni`]

There are others available - look on `lib.rs`.


FFI use in practice
-------------------

The ecosystem contains Rust bindings to many C and C++ libraries.
Look for a binding before writing one.
However,
because such bindings are largely `unsafe`,
and often cannot be statically verified,
correctness and quality are important considerations.

Sometimes FFI bindings to C libraries are in competition with
whole replacement libraries written in Rust.


Alternatives - consider serde, json, etc.
-----------------------------------------

[serde] can make it very easy for Rust to exchange
marshalled data with code written in other languages.

This is often a more effective approach,
especially when talking to scripting languages.
