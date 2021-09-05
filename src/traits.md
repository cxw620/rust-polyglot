Traits, methods
===============

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Methods
-------

The `<receiver>.method(...)` syntax is used to call a "method":
a function
whose first parameter is a variant on `self`;
often `&self` or `&mut self`.
(`self` is a keyword; you can't choose your own name for it.)

Methods are defined in a block `impl StructName { }`
(and can also be part of traits).

There is no inheritance.
Some of the same effects can be achieved with traits,
particularly default trait methods,
and/or macro crates like 
[`delegate`](https://crates.io/crates/delegate) or
[`ambassador`](https://crates.io/crates/ambassador).

It follows from the ownership model that a method defined
`fn foo(self,...)` consumes its argument (unless it's `Copy`)
so that it can no longer be used.
This can used to good effect in typestate-like APIs.


Traits
------

Rust leans very heavily on its [trait system](https://doc.rust-lang.org/reference/items/traits.html).

Rust Traits are very like Haskell Typeclasses,
or C++ Concepts.

A trait defines a set of interfaces (usually, methods),
including possibly default implementations.
A trait must be explicitly implemented for a type
with `impl Trait for Type { ... }`,
giving definitions of all the items (perhaps except items with defaults).

Trait items (eg methods) and
"inherent" items (belonging to a particular type)
with the same name
are different items.
In this case when implementing a trait it can be necessary to
explicitly write out the implementation of a trait method
in terms of the inherent method.
However,
it is often idiomatic to provide functionality
only through trait implementations.

When a trait has (roughly speaking) only methods,
pointers to objects which implement the trait can be
made into pointers to type-erased [trait objects](https://doc.rust-lang.org/reference/types/trait-object.html#trait-objects) `dyn Trait`.
These "fat pointers" have a vtable as well as the actual object pointer.
Trait objects are often seen in the form `Box<dyn Trait>`.
Ability of a trait to be used this way is called "object safety";
[The rules](https://doc.rust-lang.org/reference/items/traits.html#object-safety) are a bit complicated but often a trait can be made
object-safe by adding `where Self: Sized` to troublesome methods.

Rust has a strict trait coherence system.
There can be only one implementation of a trait for any one concrete type,
in the whole program.
To ensure this, [it is forbidden](https://doc.rust-lang.org/reference/items/implementations.html#trait-implementation-coherence) (in summary)
to implement a foreign trait on a foreign type
(where "foreign" means outside your crate, not outside your module).


### Iterators: `Iterator`, `IntoIterator`, `FromIterator`


The [`Iterator`](https://doc.rust-lang.org/std/iter/trait.Iterator.html) and [`IntoIterator`](https://doc.rust-lang.org/std/iter/trait.IntoIterator.html) traits are
very important in idiomatic (and performant) Rust.

Most collections and many other key types (eg, [`Option`](https://doc.rust-lang.org/std/option/enum.Option.html)) implement
`Iterator` and/oor `IntoIterator`,
so that they can be iterated over;
this is how `for x in y` loops work:
`y` must `impl IntoIterator`.

The standard library provides a large set of combinator methods
on `Iterator`,
for mapping, folding, filtering, and so on.
These typically take closures as arguments.
See also the excellent [`itertools`] crate.

Idiomatic coding style for iteration in Rust involves
chaining iterator combinators.
Effectively,
Rust contains an iterator monad sublanguage with a funky syntax.
withoutboats has an excellent
[essay on Rust and Monads/effects](https://without.boats/blog/the-problem-of-effects/).

The [`.collect()`](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.collect) method in `Iterator`
reassembles the result of an iteration
back into a collection
(or something which could be a collection if you squint;
note for example the [`FromIterator` impl for `Result`](https://doc.rust-lang.org/std/iter/trait.FromIterator.html#impl-FromIterator%3CResult%3CA%2C%20E%3E%3E)).
Often one has to write the type of the desired result,
perhaps like this:

```
let processed = things
    .filter_map(|t| ...)
    .map(|t| ...?; ...; Ok(u))
    .take(42)
    .collect::<Result<Vec<_>,io::Error>()?;
```

`collect` is more idiomatic than
open-coding additions to a mutable collection variable:
use of iterators is often faster than a `for` loop, and
aggressively-Rustic style tries to minimise the use of
`mut` variables.


### Existential types


Rust has some very limited support for existential types.
This is written [`impl Trait`](https://doc.rust-lang.org/reference/types/impl-trait.html),
and means
"there is some concrete type here which implements this trait
but I'm not telling you what it is".
This is commonly used for functions returning iterators,
and for futures (see [Async Rust](async.html)).

Currently this is only allowed in function signatures,
typically as the return type.  e.g.
```
   fn get_strings() -> Result<impl Iterator<Item=String>, io::Error>;
```

It is not currently possible (on stable) to make an alias for the existential
type,
so you still can't name it properly,
put it into variables, etc.
This can be inconvenient and work is ongoing.
In the meantime,
the usual workaround is to use `Box<dyn Trait>`
instead of `impl Trait`.


### Closures and the fn pointer type


Each closure is a value of a unique opaque unnameable type
implementing one or more of the special closure traits
[`Fn`](https://doc.rust-lang.org/std/ops/trait.Fn.html),
[`FnMut`](https://doc.rust-lang.org/std/ops/trait.FnMut.html) and
[`FnOnce`](https://doc.rust-lang.org/std/ops/trait.FnOnce.html).

The different traits are because closures can borrow or own variables.
If the closure modifies closed-over variables, it is `FnMut`;
if it consumes them, it is `FnOnce`.

Each closure has its own separate type,
so closures can only be used with generics
(whether monomorphised `<F: Fn()>`, or type-erased `&dyn Fn()`).

Closures borrow their captures during their whole existence,
not just while they're running.
This can impede the use of closures as syntactic sugar.


### `dyn` closures


An `&dyn Fn` closure pointer is a fat pointer:
closed over data, and code pointer.

A `dyn` closure trait object
cannot be passed by value because it's unsized.
This can make `FnOnce` closures awkward.
Use monomorphistion,
`Box<dyn FnOnce>` or somehow make the closure be `FnMut`.

### Monomorphised closures `f: F where F: Fn()`


Monomorphisation of generic closure arguments
specialises the generic function taking the closure
to one which calls the specific closure.

The concrete representation of a particular closure type
is an unnameable struct containing the closed-over variables.

The code is known at compile time --
it is identified by the precise (unnameable) closure type --
so a pointer to it not part of the closure representation at runtime.
Likewise, the nature of the closed-over variables, and their uses,
are known at compile-time.

The monomorphised caller of a closure calls it directly
(statically known branch target).
The closure can even be inlined and its code and closed-over variables
intermixed with its caller's, and the outer caller's,
to produce more optimal code.

### fn pointers


There is also a pointer type `fn(args..) -> T`
but this is just a code pointer,
so only actual functions,
and closures with no captured variables,
count.


### Some other key traits


 * [`Deref`](https://doc.rust-lang.org/std/ops/trait.Deref.html): method despatch (see below)
 * [`std::ops::*`](https://doc.rust-lang.org/std/ops/index.html): expression operators (overloading)
 * [`Eq` et al](https://doc.rust-lang.org/std/cmp/index.html) for comparison, and `Hash` for putting objects in many kinds of collections.
 * [`From`]
   [`Into`]
   [`TryFrom`](https://doc.rust-lang.org/std/convert/trait.TryFrom.html) and 
   [`TryInto`](https://doc.rust-lang.org/std/convert/trait.TryInto.html).
   Prefer to `impl From` rather than `Into` if you can;
   that will get you `Into` automatically.
 * [`Debug`](https://doc.rust-lang.org/std/fmt/trait.Debug.html) and
   [`Display`](https://doc.rust-lang.org/std/fmt/trait.Display.html) for printing with
   [`format!`](https://doc.rust-lang.org/std/fmt/index.html),
   [`println!`](https://doc.rust-lang.org/std/macro.println.html) etc. and
   [`x.to_string()`](https://doc.rust-lang.org/std/string/trait.ToString.html)
 * [`io::Read`](https://doc.rust-lang.org/std/io/trait.Read.html),
   [`io::Write`](https://doc.rust-lang.org/std/io/trait.Write.html) (not to be confused with [`fmt::Write`](https://doc.rust-lang.org/std/fmt/trait.Write.html))
 * [`Copy`](https://doc.rust-lang.org/std/marker/trait.Copy.html),
   [`Clone`](https://doc.rust-lang.org/std/clone/trait.Clone.html),
   [`AsRef`](https://doc.rust-lang.org/std/convert/trait.AsRef.html),
   [`Borrow`](https://doc.rust-lang.org/std/borrow/trait.Borrow.html)/[`ToOwned`](https://doc.rust-lang.org/std/borrow/trait.ToOwned.html).
 * [`Send`] [`Sync`]
   for thread-safety (permitting use in multithreaded programs).
 * [`Default`](https://doc.rust-lang.org/std/default/trait.Default.html)
   (implemented promiscuously)


`Deref` and method resolution
-------------------------------

The magic traits [`Deref`](https://doc.rust-lang.org/std/ops/trait.Deref.html) and `DerefMut`
allow a type to "dereference to"
another type.
This is typically used for types like `Arc`, `Box`
and `MutexGuard` which are "smart" pointers to some other type
(ie, somehow a pointer, but with additional behaviour).

During [method resolution](https://doc.rust-lang.org/reference/expressions/method-call-expr.html),
`Deref` is applied repeatedly to try to find a type
with the appropriately-named method.
The signature of the method is not considered during resolution,
so there is no signature-based method overloading/dispatch.

If it is necessary to specify a particular method,
`Type::method` or
`Trait::method` can be used,
or even `<T as Trait>::method`.

This is also required for associated functions
(whether inherent or in traits)
which are not methods (do not take a `self` parameter).
Idiomatically this includes constructors like `T::new()`
and can also include other functions that
the struct's author has decided ought not to be methods.
For example `Arc::downgrade` is not a method
to avoid interfering with any `downgrade` method on `T`.

`Deref` effectively imports the dereference target type's methods
into the method namespace of the dereferencable object.
This could be used for a kind of method inheritance,
but this is considered bad style
(and it wouldn't work for multiple inheritance,
since there can be only one deref target).

Auto-dereferencing also occurs when a reference is assigned
(to a variable, or as part of parameter passing):
if the type does not match,
an attempt is made to see if dereferencing
(perhaps multiple times) will help.

The `Deref` implementation can be invoked explicitly
with the `*` operator.
Sometimes when this is necessary,
one wants a reference again,
so constructions like `&mut **x` are not unheard-of.
