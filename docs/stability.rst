Stability
=========

..
    Copyright 2021 Ian Jackson and contributors
    SPDX-License-Identifier: MIT
    There is NO WARRANTY.

The Rust Project and community value providing a stable platform,
but also want to be able to make progress and changes.

There are a number of facilities and practices
which try to achieve both,
with a surprising degree of sucess.

Rust language, release channels
-------------------------------

The Rust language itself
(the compiler, the standard library, and some of the core tools)
has a bespoke stability and release scheme:

There are three "channels",
each representing a moving target.
Stable is released periodically (about every 6 weeks).
Beta is a pre-view of the next Stable
and exists mostly to be tested.

The big difference is between Nightly and Beta/Stable
(henceforth and elsewhere, Stable).

Nightly
~~~~~~~

Nightly provides numerous features which are explicitly denoted unstable.
These are sometimes introduced experimentally.
They are in any case subject to change without notice.

Each nightly language feature must be explicitly enabled by the use of
``#![feature(something)]`` at the start of the crate toplevel.
Unstable command line options generally require
also saying  ``-Z unstable-options``.

There are even features which are known to be
incompletel, broken, or maybe even unsound,
for which an additional 
``#![allow(incomplete_features)]``
is required.

Stable
~~~~~~

Conversely Stable Rust aims to keep existing code working,
almost entirely successfully.

Considerable care is taken when stabilising a feature,
that the API and implementation is good,
and that it doesn't paint Rust into unfortunate corners.

"Breaking changes"
(defined as any change to the contract
of the language or library or tool
which might invalidate a previously-correvt use)
are very much the exception.
Rarely, they are still considered,
but they are handled very cautiously,
including an assessment of the likely practical fallout.

Actually, Stable Rust is actually simply a
stabilised release branch
of Nightly,
so it does contain the code for all the unstable features.
But measures are taken to prevent
the use of unstable features
in the stable compiler.
This allows the Rust Project to main one main line of development
containing both the unstable work,
and improvements to the stable compiler.


API stability management tools
------------------------------

The Rust language contains several features intended to allow
a library API designer to warn or prevent users from
relying on API properties which might change in the future.

For example,
``#[non_exhaustive]`` on data typesm
which prevents an API consumer from writing code
which would break when a new field or variant was added.

``impl Trait``, visibility tools, newtypes, and trait sealing,
are also useful.

The standard library makes very extensive use of these facilities,
and sets an example which the better crates largely follow.


Libraries - semver
------------------

The Rust community has strong expectations about
the API stability of Rust libraries (crates).

Cargo implements a modified semver scheme,
and crates are generally expected to
choose a cargo-semver-incompatible version
for releases with breaking changes.
The community will typically expect that
any inadvertant breaking changes
are reverted.

The semver scheme is like official semver,
but with an additional compatibility rule for "0.x.y" versions
where (for example) "0.x.y+1" satisfies a dependency on "0.x.y".
(In official semver,
no "0.x" version is treated as compatible in any way with any other.)

That cargo expects there to be stability rules for "0.x" versions
has made it feasible for many crate authors to avoid publishing a "1.0",
and inevitably many have failed to do so,
for all the usual crop of (bad) reasons.
Many important and perfectly deecent, stable, and reliable
Rust libraries
still have "0.x" version numbers.

Multiple versions of the same library can end up in the same program;
if they are require to interoperate,
special measures must be taken.
For example,
when the ``log`` crate makes a new incompatible release,
an update is published with the old version number which
is actually a compatibility facade over the new version,
so that programs ending up containing a single instance of the library
and its crucial global state.
