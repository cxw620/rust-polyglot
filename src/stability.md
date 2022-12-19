Stability
=========

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

The Rust Project and community value providing a stable platform,
but also want to be able to make progress and changes.

There are a number of facilities and practices
which try to achieve both,
with a surprising degree of success.

Rust language, release channels
-------------------------------

The Rust language itself
(the compiler, the standard library, and some of the core tools)
has a bespoke stability and release scheme:

There are three ["channels"](https://forge.rust-lang.org/),
each representing a moving target.
Stable is released periodically (about every 6 weeks).
Beta is a pre-view of the next Stable
and exists mostly to be tested.

The big difference is between Nightly and Beta/Stable
(henceforth and elsewhere, Stable).

[`rustup`](https://rustup.rs/) can manage
multiple versions of Rust.
The `cargo`, `rustc`, etc. in `~/.cargo/bin` (on your `PATH`)
are actually links to rustup so that you can
invoke a different version with e.g. `cargo +nightly build`.


### Nightly

Nightly provides numerous features which are explicitly denoted unstable.
These are sometimes introduced experimentally.
They are in any case subject to change without notice.

Each nightly language feature must be explicitly enabled by the use of
`#![feature(something)]` at the start of the crate toplevel.
Unstable command line options generally require
adding  `-Z unstable-options`.

There are even features which are known to be
incomplete, broken, or maybe even unsound,
for which an additional 
`#![allow(incomplete_features)]`
is required.


### Stable

Conversely Stable Rust aims to keep existing code working,
almost entirely successfully.

Considerable care is taken when stabilising a feature,
that the API and implementation is good,
and that it doesn't paint Rust into unfortunate corners.

"Breaking changes"
(defined as any change to the contract
of the language or library or tool
which might invalidate a previously-correct use)
are very much the exception.
Rarely, they are still considered,
but they are handled very cautiously,
including theoretical and practical assessment of the likely fallout.

(Actually, Stable Rust is actually simply a
stabilised release branch
of Nightly,
so it does contain the code for all the unstable features.
But measures are taken to prevent
the use of unstable features
in the stable compiler.
This allows the Rust Project to main one main line of development
containing both the unstable work,
and improvements to the stable compiler.)


Editions
--------

Orthogonally to the different release channels,
there are Editions of Rust.
Currently, Rust 2015, 2018, and 2021 (supported by Rust 1.56, Oct 2021).

Each edition is a dialect, even with different syntax.
The same compiler supports all the editions.
The edition is specified at the level of a crate,
and a single program may contain code from several editions.

This allows the language to evolve without breaking old code.


API stability management tools
------------------------------

The Rust language contains several features intended to allow
a library API designer to warn or prevent users from
relying on API properties which might change in the future.

For example,
[`#[non_exhaustive]`](https://doc.rust-lang.org/reference/attributes/type_system.html#the-non_exhaustive-attribute)
on data types
which prevents an API consumer from writing code
which would break when a new field or variant was added.

[`impl Trait`](traits.md#existential-types),
[visibility specifiers](https://doc.rust-lang.org/reference/visibility-and-privacy.html),
[newtypes](https://doc.rust-lang.org/book/ch19-04-advanced-types.html#using-the-newtype-pattern-for-type-safety-and-abstraction),
and [trait sealing](https://rust-lang.github.io/api-guidelines/future-proofing.html),
are also useful.

The standard library makes very extensive use of these facilities,
and sets an example which the better crates largely follow.

When designing an API,
you might want to take a look at the Rust Project's
[Rust API Guidelines](https://rust-lang.github.io/api-guidelines/).
But do treat them as *opinionated guidelines*, not *rules*.


Libraries - semver
------------------

The Rust community has strong expectations about
the API stability of Rust libraries (crates).

Cargo implements a
[modified semver scheme](https://doc.rust-lang.org/cargo/reference/semver.html?highlight=semver#semver-compatibility),
and crates are generally expected to
choose a cargo-semver-incompatible version
for releases with breaking changes.
The community will typically expect that
any inadvertent breaking changes
are reverted or fixed.

The semver scheme is like official semver,
but with an additional compatibility rule for `0.x.y` versions
where (for example) `0.x.(y+1)` satisfies a dependency on `0.x.y`.
(In official semver,
no `0.x` version is treated as compatible in any way with any other.)

That cargo expects there to be stability rules for `0.x` versions
has made it feasible for many crate authors to avoid publishing a `1.0`,
and inevitably many have failed to do so,
for all the usual kinds of reasons.
Many important and perfectly decent, stable, and reliable
Rust libraries
still have `0.x` version numbers.

Multiple versions of the same library can end up in the same program,
and are then treated as entirely disjoint by the language.
If they need to interoperate,
special measures must be taken.
For example,
when the [`log`](https://crates.io/crates/log) crate makes a new incompatible release,
an update is published with the old version number which
is actually a compatibility facade over the new version,
so that programs ending up containing a single instance of the library
and its crucial global state.
