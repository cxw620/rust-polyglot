Safety, threadsafety
====================

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Most Rust code is written in Safe Rust,
the memory-safe subset of Rust.
Generally when people speak of Rust,
they mean Safe Rust unless the context indicates otherwise.

Both optimised and unoptimised binaries are memory-safe.
There is no compile-time option for reducing memory safety.

Safety
------

Safety means the lack of undefined behaviour (UB) as found in C,
and generally that the program does what the programmer wrote,
or crashes.

Safety in Rust does not mean the absence of errors detected at runtime.
(See the chapter on [error handling](errors.html).)

Nor does Safe Rust guarantee the absence of memory leaks.
However, in general, leaks are not very common in practice:
for example, given the facilities in the standard library,
leaks are only possible by making
circularly referential refcounted data structures,
or when using certain esoteric or explicitly-leaking functions.

Integers, conversion, checking
------------------------------

Arithmetic and type conversions are always safe,
but overflow handling may need care for correct results.

The basic arithmetic operations
panic on overflow in debug builds,
and silently truncate (bitwise) in release builds.
The [`as` type conversion operator](https://doc.rust-lang.org/reference/expressions/operator-expr.html#type-cast-expressions)
silently truncates on overflow.

The stdlib provides `checked_*` and `wrapping_*` methods,
but they are not always convenient;
the [`Wrapping`](https://doc.rust-lang.org/std/num/struct.Wrapping.html) wrapper type can be helpful.

For conversions expected to be fallible,
use the [`TryFrom` implementations](https://doc.rust-lang.org/std/convert/trait.TryFrom.html#implementors) via [`TryInto::try_into()`](https://doc.rust-lang.org/std/convert/trait.TryInto.html).
For conversions expected to be infallible,
using [`num::cast`](https://docs.rs/num/latest/num/cast/index.html)
will avoid accidentally writing a lossy raw `as` operation.

| from |    i8 |  i16 |  i32 |  i64 | i128 |isz |    u8 |  u16 |  u32 |  u64 | u128 | usz |   f32 |  f64
|------|------|-----|-----|-----|-----|-----|------|-----|-----|-----|-----|------|------|-----|
|   i8 | . | . | . | . | . | T< | T+ | T+ | T+ | T+ | T+ | T< | . | f
|  i16 | T< | . | . | . | . | T< | T< | T+ | T+ | T+ | T+ | T< | . | f
|  i32 | T< | T< | . | . | . | T< | T< | T< | T+ | T+ | T+ | T< | N= | f
|  i64 | T< | T< | T< | . | . | T< | T< | T< | T< | T+ | T+ | T< | N= | N=
| i128 | T< | T< | T< | T< | . | T< | T< | T< | T< | T< | T+ | T< | N= | N=
|isize | T< | T< | T< | T< | T< | . | T< | T< | T< | T< | T< | T+ | N# | N=
|      |      |     |     |     |     |     |      |     |     |     |     |      |      |     |
|   u8 | T< | . | . | . | . | T< | . | . | . | . | . | T< | . | f
|  u16 | T< | T< | . | . | . | T< | T< | . | . | . | . | T< | . | f
|  u32 | T< | T< | T< | . | . | T< | T< | T< | . | . | . | T< | N= | f
|  u64 | T< | T< | T< | T< | . | T< | T< | T< | T< | . | . | T< | N= | N=
| u128 | T< | T< | T< | T< | T< | T< | T< | T< | T< | T< | . | T< | N# | N=
|usize | T< | T< | T< | T< | T< | T< | T< | T< | T< | T< | T< | . | N# | N=
|      |      |     |     |     |     |     |      |     |     |     |     |      |      |     |
| f32 | NX | NX | NX | NX | NX | NX | NX | NX | NX | NX | NX | NX | . | .
| f64 | NX | NX | NX | NX | NX | NX | NX | NX | NX | NX | NX | NX | N# | .

Thread safety
-------------

Safe Rust is threadsafe.
You can freely start new threads and parallelise things.
The aliasing rules implied by the ownership model
guarantee an absence of data races.

Of course this does not necessarily protect you from concurrency bugs
(including lock deadlocks and other algorithmic bugs).

A reasonable collection of threading primitives and tools
is in
[`std::thread`](https://doc.rust-lang.org/std/thread/index.html) and
[`std::sync`](https://doc.rust-lang.org/std/sync/index.html#higher-level-synchronization-objects).
Many projects prefer the locking primitives from the [`parking_lot`] crate.
[`crossbeam`] has [scoped threads],
which avoids everything having to be `'static`.

Multithreading in Rust can be an adjunct to,
or replacement for,
Async Rust.

Global variables
----------------

Mutable global variables `static mut` are completely unsynchronised
and there is no control of reentrancy hazards.
Accessing a `static mut` twice at once
(including just separately making two `&mut`)
is UB.
Even in a single-threaded program,
the reentrancy hazards remain.
So *any* access to a `static mut` is `unsafe`.

Instead, either pass mutable access down your call stack,
or use [interior mutability](ownership.md#interior-mutability-and-runtime-lifetime-management).

Annoyingly, [`std::sync::Mutex`] is not const-initialisable.
Use [`parking_lot`], or [`lazy_static`].

Unsafe Rust
-----------

If you want full manual control, `unsafe { }` exists.
Many of the standard library facilities,
and some important and widely used crates,
are implemented using `unsafe`.

All `unsafe { }` does by itself is allow you to use unsafe facilities.
When you use an unsafe facility you take on a proof obligation.
How difficult a proof obligation you have depends very much on
what you are doing.
Sometimes it is easy.

The documentation for each facility explains what the rules are.
The Reference has rules for [type layout] etc.

The Rust community generally tries very hard to make sound APIs
for libraries which use unsafe internally.
(Soundness being the property that no programs using your library,
and which do not themselves use `unsafe`, have UB.)
You should ensure your library APIs are sound.

Most facilities marked unsafe are unsafe because they can allow
memory misuse and/or violation of the ownership and aliasing rules.

One difficulty is the lack of formal specifications.
The [Reference] and the
[Nomicon](https://doc.rust-lang.org/nomicon/index.html)
have some information.
It is sometimes necessary to rely on
the reasonableness of the implementation.
This is less bad than it sounds because
the Rust community try quite hard to make things reasonable.

Aliasing rules are provenance-based.
(There is no type-based alias analysis.)
This has been formalised in
[Stacked Borrows](https://github.com/rust-lang/unsafe-code-guidelines/blob/master/wip/stacked-borrows.md).
This was Ralf Jung's PhD thesis and has been
now adopted by the Rust Project.
It's not yet officially ratified as the spec but
in practice it is what you must write to.

The [Rust interpreter Miri](https://github.com/rust-lang/miri) (eg `cargo miri test`)
will validate an execution of your program
against Stacked Borrows and other aspects of a Rust Abstract Machine.
With a suitable test suite,
this can help give you confidence in the correctness of your code.
If you are making a library with a semantically nontrivial API,
soundness is something you'll have to wrestle with largely unaided.
A common technique is to try to have
a small internal module which uses `unsafe` but is sound,
surrounded by a convenience API written entirely in Safe Rust.

Particular beartraps in Unsafe Rust are:

 * Creating references which violate the aliasing rules is UB
   *even if the wrong aliases are never used*.
   Use the (often clumsy) circumlocutions in terms of raw pointers.

 * Creating a reference to uninitialised memory is UB,
   *even if the reference is not read before the memory is initialised*.
   Use [`MaybeUninit`](https://doc.rust-lang.org/std/mem/union.MaybeUninit.html).

 * The automatic destructor-calling of variables that go out of scope
   interacts very dangerously with attempts at manual lifetime management.
   This can make Unsafe Rust even more hazardous than C in some cases!
   Use [`ManuallyDrop`](https://doc.rust-lang.org/std/mem/struct.ManuallyDrop.html).

 * With [`#[repr(transparent)] struct X(Y)`](https://doc.rust-lang.org/reference/type-layout.html#the-transparent-representation),
   you may *not* assume that *things containing* X
   have the same layout as things containing Y.
   For example transmuting between `Option<Y>` and `Option<X>` is wrong.

 * [`mem::transmute`](https://doc.rust-lang.org/nightly/std/mem/fn.transmute.html)
   is an extremely powerful hammer
   and should be used with great care.

(Here we distinguish references [`&T`](https://doc.rust-lang.org/std/primitive.reference.html) from raw pointers [`*T`](https://doc.rust-lang.org/std/primitive.pointer.html).
Safe Rust cannot use raw pointers, only references.)
