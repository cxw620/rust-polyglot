Libraries
=========

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

There are many excellent Rust libraries
(and also many poor ones of course).
These are all collected at [`crates.io`](https://crates.io/),
the Rust language-specific package repository.

For most programs,
use of ecosystem library packages is a practical necessity.

Rust's excellent metaprogramming system
makes it possible for libraries to provide facilities
that resemble bespoke language features.

When searching for libraries,
usually use the opinionated catalogue at [`lib.rs`](https://lib.rs).
Or use "recent downloads" for the search order on `crates.io`,
which is inexact but is likely to give you fate-sharing
with the rest of the community, at least.


Libraries you should know about
-------------------------------

 * [`itertools`].
   Superb collection of extra iterator combinators.

 * [`fehler`]; [`thiserror`]; [`eyre`] (or [`anyhow`]).  Error handling.

 * [`num`],
   [`num-traits`],
   [`num-derive`].
   Not just for "numeric" code - helpful integer conversions etc. too.

 * [`strum`].  Iterate over enum variants; enums to strings, etc.

 * [`slab`], [`generational_arena`] or [`slotmap`].
   Heap storage tools which safely sidestep borrowck (and are fast).

 * [`index_vec`].  [`arrayvec`]. [`indexmap`].
   Variations on [`Vec`] and [`HashMap`].

 * [`easy-ext`].  Conveniently define methods on other people's types.

 * [`rayon`]\: Semi-magical safe multicore parallelism
   as a drop-in replacement for std's serial iterators.

 * [`parking_lot`].  Alternatives to the standard mutex etc.;
   `parking_lot::Mutex` is const-initialisable.

 * [`crossbeam`]\: other tools for multithreaded programming,
   including [scoped threads].

 * [`chrono`] for human-readable date/time handling.
   API is a bit funky.  Be sure to use [`chrono-tz`] on Unix.

 * [`libc`] and [`nix`].  Take your pick.
   (Maybe consider [`rustix`].)

 * [`lazy_static`], [`once_cell`]
   for data to be initialised once.

Libraries for specific purposes
-------------------------------

 * [`log`] (and [`env_logger`], etc.); [`tracing`].

 * [`regex`] (and [`lazy-regex`]), [`glob`], 
   [`tempfile`], [`rand`], [`either`], [`void`].

 * [`ndarray`], [`ndarray-linalg`], etc.
   Vectors, matrices, linear algebra.

 * Cryptography\: [`ring`], [`rustls`],
   [Rust Crypto](https://github.com/RustCrypto);
   see [Sylvain Kerkour's writeup](https://kerkour.com/blog/rust-cryptography-ecosystem/).

 * [`bstr`]\: Stringish methods on byte strings
   that are *hopefully* UTF-8 (but might not be).

 * [`bytemuck`]\: Reinterpret-casting of plain data.


`serde`
---------

[serde]
is a serialisation/deserialisation framework.

It defines a [data model](https://serde.rs/data-model.html),
and provides automatic translation of ordinary Rust `struct`s
to and from that model.

Ecosystem libraries provide concrete implementations
for a wide variety of data formats,
and some interesting data format metaprogramming tools.

The result is a superb capability to handle
a wide variety of data marshalling problems.
serde is especially good for ad-hoc data structures and
structures whose definition is owned by a Rust project.

serde and its ecosystem are considerably better for many tasks than
anything available in any other programming environment.

Generally, the resulting code
is a fully monomorphised open-coded marshaller
specialised for the specific data structure(s) and format(s),
so performance is good but the code size can be very large.


Web tools and frameworks
------------------------

Most Rust web tools are async.

Use [`reqwest`] or [`ureq`] for making HTTP requests.

Use [`hyper`] for a raw HTTP client or server,
but consider using [`reqwest`] (client)
or a web framework (server) instead.

Rust is well supplied with web frameworks,
but it is hard to choose.

 * I have been using [Rocket](https://rocket.rs/) for some years,
   But the `rocket 0.4` branch (sync) doesn't compile on Stable
   and is in the process of being replaced by the not-yet-released
   `0.5` which uses async.
   `0.4` to `0.5` is quite a big compat break
   (this was to be expected, but is still a nuisance).
   If you start a new project with Rocket, use the `0.5` preview.

 * [`actix-web`](https://actix.rs/) is popular too.
   When I was choosing Rocket some years ago,
   it had lots of unsound `unsafe`, but that seems fixed now.

 * [`rouille`](https://crates.io/crates/rouille) is sync.
   Yay!  But I haven't tried it.

 * You should perhaps also consider: [`warp`].

I would avoid "`stdweb`",
which depends on the "`async-std`" async runtime.
because [I prefer Tokio](async.md#practicalities).


Command line parsing: ``clap`
-----------------------------

If you are writing a command line program
you should probably use [`clap`].
It allows declarative definition of command line options.

Unfortunately,
`clap` has some problems.

 * Serious problems handling options which override each other.
   There is a facility for this but it is not convenient and
   its algorithm is fundamentally wrong.

 * General failure to follow (at least by default) well-established
   Unix option parsing conventions.

To illustrate:
it is quite awkward even to provide a conventional pair of
mutually-overriding `--foo` and `--no-foo` options.

In practice, using `clap`
means accepting that one's program will have
an imperfect and sometimes-balky command line syntax.

There are alternatives,
notably [`getopts`], [`gumdrop`] and [`argparse`],
but they are much less popular and less well maintained.
I sometimes use `argparse` where I want a fine-tuned option parser,
but it is quite odd and the docs are not great.
