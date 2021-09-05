Async Rust
==========

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Introduction
------------

Rust has an `async` system
for cooperative multitasking,
based on **futures**
(which are rather like *promises* in e.g. JavaScript),
but have some important novel features.

Async Rust is considerably less mature than the rest of the language.
It can achieve rather higher performance
(including, for example, lower power use in embedded setups,
and better scaleability in highly concurrent server applications).
But it comes at the cost of additional inconvenience and hazards.

Many important libraries (especially web libraries)
provide (only) async interfaces.

I recommend using ordinary (synchronous) Rust,
with multithreading where you need concurrency,
unless you have a reason to do otherwise.

Good reasons to do otherwise might include:
using async libraries;
expecting a very wide deployment of your program;
tight performance, efficiency or scaleabilty requirements;
or working in a completely single-threaded environment.

Effectively, async Rust is a different dialect.

Work is ongoing to try to improve async Rust,
and remove some of the rough edges.


Fundamentals
------------

A magic trait 
[`Future<Output=T>`](https://doc.rust-lang.org/std/future/trait.Future.html)
 represents an
uncompleted asynchronous process.

Syntactic sugar `async { }`
for both functions and blocks
tells the compiler to convert the contained code
into a state machine implementing the `Future` trait.
An `async fn foo() -> T` actually returns `impl Future<Output=T>`.

Local variables (including lexical captures, for `async` blocks)
become members of the state machine data structure,
which is an anonymous type whose internals are hidden
but which `impl Future`.

The special keyword constrution `.await`
is to be applied to a `Future`.
It introduces a yield (await) point
into the generated state machine.

Utilities, types, and combinators are available for
evaluating multiple futures in parallel
and getting the answer from whichever finishes first
([`select!`](https://docs.rs/tokio/latest/tokio/macro.select.html))
or all of the answers
([`join!`](https://docs.rs/tokio/latest/tokio/macro.join.html)),
async "iterators" ([`Stream`](https://docs.rs/futures/latest/futures/stream/index.html)),
and so on.

The overall result is that, at a high level,
much code can be written in a direct imperative style,
without explicit state machines.

The usual Rust memory-safety guarantees are retained.

### Innards

Futures have one method, `poll`,
which either returns
[`Ready(T)` or `Pending`](https://doc.rust-lang.org/std/task/enum.Poll.html).

`poll` takes a 
[Context](https://doc.rust-lang.org/std/task/struct.Context.html)
 which has an associated 
[`Waker`](https://doc.rust-lang.org/std/task/struct.Waker.html).
When the future returns `Pending`,
it is supposed to have recorded the `Waker` somewhere
so that when the task can make progress, the `Waker` is woken.

An async Rust program contains a contraption known as the
**executor**
which is responsible for creating tasks
(typically, it provides a
[`spawn`](https://docs.rs/tokio/1.11.0/tokio/fn.spawn.html) facility),
keeping track of which are ready,
and calling `poll` repeatedly
so that the program makes progress.

Practicalities
--------------

### Choosing a runtime

The executor is not supplied by the Rust language itself.
Multiple executors are available, as libraries.
In practice,
one needs async inter-task communication facilities,
IO utilities, and so on.

The executor, and many of these other facilities,
are generally provided by the async **runtime**.
Many useful facilities turn out to be runtime-specific.
In practice,
library authors have in many cases been forced
to choose a specific runtime.

Most of the important libraries use **Tokio**
a mature production-quality runtime
(which actually predates modern async Rust language features).

Worth mentioning is
[`smol`](https://docs.rs/smol/1.2.5/smol/), which might
be good for small mostly-standalone projects.

Fairly recently 
[`async-std`](https://docs.rs/async-std/1.10.0/async_std/) appeared.
Despite the name and strapline etc., `async-std` is not
an official emanation of the Rust Project.
This name grab in itself leaves a bad taste in my mouth.

There are some glue libraries to help with bridging
the gaps between different runtimes.

### Mixing and matching sync and async; thread context

In a larger program,
or one which makes use of diverse libraries,
it can be necessary to mix-and-match sync and async code.
Unlike in many other languages with async features,
this is possible in Rust.
There are facilities for calling async code from sync,
and vice versa.

But there are gotchas.
Specifically,
there are complex rules about what kind of function
you can call from what runtime context
(ie, in what kind of thread).

For example, if you call
[tokio::runtime::Handle::block_on](https://docs.rs/tokio/1.11.0/tokio/runtime/struct.Handle.html#method.block_on)
from a non-async function,
to run async code from within non-async code,
thinking you are not in an async execution context,
but in fact the current thread is a Tokio executor thread,
it will panic.
Of course a sync veneer over an async library might
not know if it's been called, indirectly, from an async task.
If you think this might happen,
you're supposed to use
[`spawn_blocking`](https://docs.rs/tokio/1.11.0/tokio/runtime/struct.Handle.html#method.spawn_blocking).

This kind of thing complicates the liberal use of the
sync/async gateway facilities.
The rules, while documented,
are hard to make sense of without a full mental model
of the whole runtime, threading, and executor system.
They are hard to follow without
a full mental model of the whole program structure,
including (sometimes) library implementation choices.

Complex programs may have multiple async executors and runtimes:
a common way to make a sync veneer over an async library
is to instantiate a "pet" executor.

### Pin

The state machines generated by `async { }`
can contain local variables which are
references to other local variables.
But!  Rust does not support self-referential data structures,
because they cannot be moved
without invalidating their internal pointers.

The solution to this is a type `Pin`
which is used to wrap references (and smart pointers),
and guarantees that the referenced data does not move.
The type judo is confusing to think about,
and is also awkward to use in practice.

Many types involved in futures
(especially those you find in "manual" `impl Future`)
end up with `Pin` wrappers,
in a form of syntactic vinegar.
Pinning brings more problems:
even ordinary struct field access (projection)
is not straightforward on a pinned object!

See the
docs for
[`std::pin`](https://doc.rust-lang.org/std/pin/index.html)
and the crates
[`pin-project`](https://crates.io/crates/pin-project)
and
[`pin-project-lite`](https://crates.io/crates/pin-project-lite).


### Anonymous future types, traits, etc.

Futures are not quite first-class objects in Rust.
In particular, like closures, `async` blocks and `fn`s
have anonymous types - types that cannot be named.
But it is often necessary to store futures in structures,
return them from functions (especially trait methods),
and so on.

Because the type of an `async` block cannot be named,
it cannot be made into an associated type
in a trait implementation.
So trait methods cannot simply be async.

The 
[`impl Trait` existential type featuer](traits.md#existential-types)
is nearly enough to solve this,
but because one cannot write `impl Trait`
anywhere except as a function return,
it is often not sufficient.

If a trait method returns a different type
for different implementations of the trait,
it must be a nominal type,
which is not possible if the function is
an `async fn` (and therefore returns an anonymous future type).
The usual workaround for async trait methods to return
[`Box`]`<dyn Future<Output=_>>`.
This is suboptimal because
it requires an additional heap allocation,
and runtime despatch.
This workaround has been neatly productised
in the [`async-trait`](https://crates.io/crates/async-trait) macro package.


### Cancellation safety

Unlike most other languages' async systems,
Rust futures are inert:
they don't run unless they are polled,
by an executor.

If a future is no longer needed, it is simply dropped.
This can happen quite easily,
for example if `select!` is used,
or if a future is put explicitly into a data structure
and then dropped at some point.

The effect from the point of view of an `async { }`
is that the code simply stops running in the middle,
effectively-unpredictably,
discarding all of the local state.

Many straightforward-looking implementations of common tasks
such as reading from incoming streams
can lose data, or become desynchronised,
if the local variables containing partially-processed data
are simply discarded,
and the algorithm later restarted from the beginning
by a re-creation of the same future
(eg, the next iteration of a loop containing a `select!`).

A type, future, data structure, or method, is said to be
**cancellation-safe** if the underlying data structure is such that
things do not malfunction if the future is dropped before completion.

There is no compiler support to ensure cancellation-safety
and cancellation bugs turn up in real-world async Rust code
with depressing frequency.
Avoiding them is a matter of vigilance
(and careful study of API docs).

While cancellation bugs do not affect
the program's core memory safety,
they often have security implications,
because they can easily result
in frame desynchronisation of network streams
and other alarming consequences.


### Send


Most async Rust executors are multithreaded
and will move tasks from thread to thread at whim.
This means that every future in such a task must be [`Send`],
meaning it can safely be sent between threads.
Therefore the local variables in async code must all be `Send`;
captured references must be to [`Sync`] types.

Most concrete Rust types are in fact `Send`,
but many generic types are not `Send` unless explicitly constrained.
So `Send` (or, sometimes, `Sync`) bounds must be added,
sometimes in surprising places.

The compiler errors do a pretty good job at pointing out the
type or variable which is the root cause of a lack of `Send`
but this is still a nuisance.

Futures don't *have* to be `Send`.
In a single-threaded environment,
working with non-`Send` futures is totally possible.
But usually lack of `Send` is just an omission.


### Error messages


Async Rust has a tendency to produce rather opaque error messages
referring to opaque types
missing bounds, and other abstruse diagnostics.

You will get used to them,
but it is in stark contrast to the rest of the language.


### Libraries and utilities


It is not entirely straightforward to find the right libraries to use.
Matters are complicated by older decoy libraries
from prior incarnations of Rust's approach to async.

You will end up using, at least:

 * `std`'s builtin futures support:
   [std::task](https://doc.rust-lang.org/std/task/index.html),
   [std::future](https://doc.rust-lang.org/std/future/index.html);
 * utilities from your runtime, eg: [Tokio](https://docs.rs/tokio/latest/tokio/)'s modules and macros.
 * utilities from the [`futures` crate](https://docs.rs/futures/latest/futures/).

Unfortunately, many of these don't lend themselves to
convenient blanket imports
(although you should consider `use `[`futures::prelude`](https://docs.rs/futures/0.3.17/futures/prelude/index.html)`::*`).

Futures-related items share names with non-async thread tools
(eg, `Mutex`, `mpsc`, etc., can mean different things).
You will often want to use both sync and async tools
in the same program.
(In particular, a sync `Mutex` is often right.)

Importing the sub-module names is little better
because the useful modules have generic names:
 - [`futures::future`](https://docs.rs/futures/0.3.17/futures/future/index.html) vs
   [`std::future`](https://doc.rust-lang.org/std/future/index.html)
 - [`tokio::process`](https://docs.rs/tokio/latest/tokio/process/index.html) vs
   [`std::process`](https://doc.rust-lang.org/std/process/index.html)
 - [`tokio::task`](https://docs.rs/tokio/latest/tokio/task/index.html) vs
   [`futures::task`](https://docs.rs/futures/0.3.17/futures/task/index.html) vs
   [`std::task`](https://doc.rust-lang.org/std/task/index.html)
 - [`tokio::stream`](https://docs.rs/tokio/latest/tokio/stream/index.html) vs
   [`futures::stream`](https://docs.rs/futures/latest/futures/stream/index.html)
   vs the decoy (nightly-only)
   [`std::stream`](https://doc.rust-lang.org/std/stream/index.html)

Sometimes you'll want to use all of these in one program.
Finding and naming anything is a chore!
