Cargo
=====

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

[The `cargo` tool](https://doc.rust-lang.org/cargo/index.html),
which is used to build any nontrivial Rust program,
will automatically download and build all the dependencies
(from [`crates.io`](https://crates.io/), typically)
and (together with `rustc`) manage reuse of previous builds etc.

cargo is super-convenient for the common use cases,
but also has serious problems.


Basics
------

A (git) tree can be a **workspace** containing
multiple **packages**.
Each package can contain multiple `rustc` **crates**
(eg, a library and several binaries),
but informally people often say "crate" to mean "package".

When publishing to `crates.io`, each package becomes separate.

cargo needs some metadata,
from a file `Cargo.toml` in the toplevel.

cargo can often infer the intended libraries and executables
in a conventionally-laid-out package.
There are knobs to override these conventions.
In particular it is fairly easy (and a good idea)
to avoid the proliferation
of `src` directories in each subdirectory of a workspace.

It is a good idea to start a new project with `cargo init`.
Unlike some similar tools in other languages,
the resulting tree does not contain much boilerplate.

If you make a project from scratch do not forget to include
`edition = "2018"` (or similar).  See [Editions](stability.md#editions).

cargo maintains a calculated dependency resolution
(versions and hashes of all dependencies)
in `Cargo.lock`.
It is conventional to commit that file
for packages generating binaries,
and omit it for libraries
(where my personal practice is to commit `Cargo.lock.example`.)

By default cargo only operates on the crate in the cwd.
If you want it to build/test/whatever the whole workspace,
you must say `--workspace`.


Security implications
---------------------

cargo and the `crates.io` ecosystem
have some troublesome security properties.
Since I have not seen this discussed in depth elsewhere,
I will do so here.

cargo's model is heavily influenced by `npm`,
whose ecosystem and usual methods of use
have an appalling security record.

The Rust libraries are much less atomised than npm's.
In a typical project one may end up using
a handful, dozens or maybe hundreds of dependencies,
but not the thousands upon thousands one sees with npm.

Both cargo and `rustc`
will *run*, at build-time,
code supplied by the packages they are building.
There are no restrictions on what that code might do.

The `crates.io` package repository contains tarballs,
and there is no mechanical linkage or machine-readable traceability
of those crate tarballs
back to the git repositories they were hopefully originally created from.
(The `crates.io` index is maintained in git but
cargo does not look at
the git history of the index
and does not mind if the index history rewinds,
which it has done occasionally.)

Some of the more important libraries are part of library collections
managed by multiple-person umbrella institutions.
But many necessary libraries are standalone
and owned and maintained by a single Rust developer.

### Strategies


There are tools to help with the
software supply chain management problem,
such as
[`cargo-supply-chain`](https://crates.io/crates/cargo-supply-chain),
[`cargo-audit`](https://crates.io/crates/cargo-audit)
(which uses the
[Rustsec](https://rustsec.org/)
advisory database,
which even records advisories for 
APIs which are *capable of misuse*,
even if there is no known real-world bug).

Some OS distros (e.g. Debian) are starting to maintain
reasonable collections of Rust packages
within the distro package repository.
This puts your OS distro between you
and the raw data from `crates.io`,
which is likely to reduce your risk.
To do this,
you will probably want to configure cargo's
[source replacement](https://doc.rust-lang.org/cargo/reference/source-replacement.html)
not to
look at `crates.io` but to
[look at your distro packages instead](https://salsa.debian.org/rust-team/debcargo-conf/blob/master/README.rst#id22) (sorry, link needs JS).

You may also consider some kind of privsep,
where packages are built in a container or VM of some kind.

One approach is to keep all of the Rust code,
and run all of the tools and the generated code,
in the privsep environment.
But this is not always very convenient for day-to-day development.

I have a tool
[`nailing-cargo`]
(sorry, link needs JS)
which can
help maintain a convenient workflow
even when one doesn't want to run the Rust system
in one's main environment.


Other problems and limitations
------------------------------

cargo is very easy for simple cases.

But it has limitations, bugs, and inflexibilities.
Unlike most of the rest of Rust,
important problems can remain outstanding for years.
Some awkward limitations are even deliberate policy
on the part of cargo upstream.

The situation is too complex to document here,
but here are some of the key issues you may run into:

Out-of-tree builds are supported in theory,
but in practice the information needed to
successfully run a nontrivial test suite
(or complex code generator)
in an out-of-tree build
is not provided to the crates being compiled.
The ecosystem infrastructure does not use out-of-tree builds.
So many crates' tests do not work out-of-tree,
and some crates do not build.
(You *can* arrange for the `target` directory
to be somewhere else,
if you don't mind the build still needing write access to the source tree.)

Although a stated goal of cargo is to be
embeddable into other build systems,
cargo does not expose the interfaces necessary to do this well.
It's hard to know when to rerun cargo and when cargo's outputs changed.
It's hard to get cargo to build precisely what's needed.
If you want to run cargo inside `make`,
you will need to resort to stamp files,
and live with it sometimes doing unnecessary work.

It is not possible to have a
completely local (unpublished) dependency
without baking the path on the local filesystem
into the depending packages' source tree.

[`nailing-cargo`] and other tools may help with some of these issues.

[`nailing-cargo`]: https://salsa.debian.org/iwj/nailing-cargo
