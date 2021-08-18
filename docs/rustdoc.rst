Documentation and testing
=========================

..
    Copyright 2021 Ian Jackson and contributors
    SPDX-License-Identifier: MIT
    There is NO WARRANTY.

rustdoc
-------

Rust's documentation generator, rustdoc,
can automatically generate API documentation
from appropriate comments in the Rust source.

You document an item with a ``///`` comment, like this:

::

   /// pigpiod tick (\[us])
   pub type Tick = Word;

``/** */`` works too but is uglier and less idiomatic.
``//!`` is an "inner doc comment" which lives inside
the thing it is documenting,
and is normally used only for crates and modules.

The doc comments are in a Markdown dialect.

Rust community conventions value high-quality documentation,
and especially, documentation which describes
the semantics, details, and fine points of an API.

The Rust Standard Library documentation is built using rustdoc.

To invoke rustdoc to document your crate, run ``cargo doc``.
It will produce documentation for all your dependencies too,
by default.
It's nice to have that locally.

You can use include syntax,
to include your ``README.md``
in your crate's top-level rustdoc docs too:
``#[doc=include_str!("../README.md")]``.

See the Rustdoc Book.


tests
-----

Functions marked ``#[test]`` are treated as unit tests.
They are run by ``cargo test``.
Multiple tests may be run at once,
in different threads of a single process,
so these unit test functions should avoid process-wide disruption.
Panicking on failure is fine.

It is often convenient to put tests together in a module,
marked ``#[cfg(test)]``;
(if for no other reason than to avoid dead code warnings
for code which exists just to support tests).

cargo supports other layouts for the test source code.
The cargo documentation describes
a difference between "integration tests" and "unit tests"
but there is no real distinction between how they are treated or run;
the distinction is just layout opinions.

For real integration tests,
including anything that wants to run any executables
produced by this crate,
it is necessary to step outside cargo.

See the Testing Guide in the Rust Book.


doctests
--------

Code examples written like this are automatically treated as doctests:

::

   /// ```
   /// let hello = String::from("Hello, world!");
   /// ```

``cargo test`` compiles and runs them.

Writing `````ignore`` at the start suppresses this.


Test annotations
----------------

Annotations are available for ``#[test]`` functions and doctests,
including in particular ``should_panic``:

::
   
   #[test]
   #[should_panic]
   fn panics() { panic!() }

::
   
   /// ```should_panic
   /// panic!();
   /// ```
