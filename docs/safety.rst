Safety, threadsafety
====================

..
    Copyright 2021 Ian Jackson and contributors
    SPDX-License-Identifier: MIT
    There is NO WARRANTY.

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
(See the section on error handling.)

Nor does Safe Rust guarantee the absence of memory leaks.
However, in general, leaks are not very common in practice:
for example, given the faciities in the standard library,
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
The ``as`` type conversion operator,
silently truncates on overflow.

The stdlib provides ``checked_*`` and ``wrapping_*`` methods,
but they are not always convenient;
the ``Wrapping`` wrapper type can be helpful.

For conversion,
I recommend the ``Into`` and ``TryInto`` implementations in the
``num_traits`` crate.

Thread safety
-------------

Safe Rust is threadsafe.
You can freely start new threads and parallelise things.
The aliasing rules implied by the ownership model
guarantee an absence of data races.

Of course this does not necessarily protect you from concurrency bugs
(including lock deadlocks and other algorithmic bugs).

A reasonable collection of threading primitives and tools
is in ``std::thread`` and ``std::sync``.

Multithreading in Rust can be an adjunct to,
or replacement for,
`async Rust`_.

Unsafe Rust
-----------

If you want full manual control, ``unsafe { }`` exists.
Many of the standard library facilities,
and some important and widely used crates,
are implemented using ``unsafe``.

All ``unsafe`` does by itself is allow you to use unsafe facilities.
When you use an unsafe facility you take on a proof obligation.
The documentation for each facility explains what the rules are.
The Rust Reference has rules for type layout etc.

The Rest community generally tries very hard to make sound APIs
for libraries which use unsafe internally.
(Soundness being the property that no progrmas using your library,
and which do not themselves use ``unsafe``, have UB.)
You should ensure your library APIs are sound.

How difficult a proof obligation you have depends very much on
what you are doing.
Sometimes it is easy.

Most facilities marked unsafe are unsafe because they can allow
memory misuse and/or violation of the ownership and aliasing rules.

Aliasing rules are provenance-based.
(There is no type-based alias analysis.)
This has been formalised in Stacked Borrows,
the PhD thesis of Ralf Jung,
now adopted by the Rust Project.

The Rust interpreter miri (eg ``cargo miri test``)
will validate an execution of your program against Stacked Borrows.
With a suitable test suite,
this can help give you confidence in the correctness of your code.
If you are making a library with a semantically nontrivial API,
soundness is something you'll have to wrestle with largely unaided.
A common technique is to try to have
an internal module which uses ``unsafe`` but is sound,
surrounded by a convenience API written entirely in Safe Rust.

Particular beartraps in Unsafe Rust are:

 * Creating references which violate the aliasing rules is UB
   *even if the wrong aliases are never used*.
   Use the (often clumsy) circumlocutions in terms of raw pointers.

 * Creating a reference to uninitialised memory is UB,
   *even if the reference is not read before the memory is initialised*.
   Use ``MaybeUninit``.

 * The automatic destructor-calling of variables that go out of scope
   interacts very dangerously with attempts at manual lifetime management.
   This can make Unsafe Rust even more hazardous than C in some cases!
   Use ``ManuallyDrop``.

 * With ``#[repr(transparent)] struct X(Y)``,
   you may *not* assume that things containing X
   have the same layout as things containing Y.
   For example transmuting between ``Vec<Y>`` and ``Vec<X>`` is wrong.

 * ``mem::transmute`` is an extremely powerful hammer
   and should be used with great care.

(Here we distinguish references ``&T`` from raw pointers ``*T``.
Safe Rust cannot use raw pointers, only references.)
