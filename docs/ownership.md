Ownership, memory model
======================

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Rust has a novel ownership-based safety/memory system.

The best way to think of it is as a formalisation
of the object and memory ownership rules found in C programs,
which are typically documented in comments.

Ownership
---------

Every object (value) in Rust has a single owner.
Ownership can be lent (therefore, borrowed by the recipient),
and also transferred ("moved" in Rust terms).
(The reference resulting from a borrow is a machine pointer,
but this is hidden from the programmer
and of course might be elided by the compiler if it can.)

Objects inside other values are typically owned by that other object;
but objects can also contain references to (borrows of) values
held elsewhere.

Borrowing is done explicitly with the `&` reference operator.
Borrows can be mutable (`&mut T`) or immutable (`&T`).
The same object can be borrowed immutably any number of times,
but only borrowed mutably once.

During the lifetime of a borrow,
incompatible uses of the object are forbidden.
In Safe Rust, incompatible uses are prevented by the borrow checker.

The lifetimes of borrows are often part of the types of objects;
so types can be generic over lifetimes.  For example:
```
   struct WrappedCounterRef<'r>(&'r u64);
```

Even simple functions such as this
```
    fn not_bonkers(s: &str) -> Option<&str> {
        if s == "bonkers" { None } else { Some(s) }
    }
```
are generic over elided lifetime arguments:
```
    fn not_bonkers<'s>(s: &'s str) -> Option<&'s str> {
```

Although lifetimes are part of types,
there are many places where type inference is *not* supported,
but lifetime inference *is* permitted (and usual).

The special lifetime `'static`
is for objects that will never go away.

Movement, `Copy`, `Clone`, `Drop`
---------------------------------------

Objects in Rust can be moved, without special formalities.

When you pass an owned value to a function,
or it returns one to you,
the value is **moved**.
You can only do this with a value you own.
It must not be borrowed by anyone,
since moving it would invalidate any references.

This also means that Rust values do not contain addresses
pointing within themselves.
(Exception: see [`Pin`](https://doc.rust-lang.org/std/pin/struct.Pin.html).)

Moving in program source terms
might or might not mean that its memory address actually changes
(perhaps the compiler can optimise away the memory copy).
If it does, the compiler will generate the necessary memcpy calls.

Usually, when you assign a value to a variable, or pass or return it,
the value is moved.

Some types are "plain data":
They can simply be duplicated without problem with memcpy.
These types are  [**Copy**](https://doc.rust-lang.org/std/marker/trait.Copy.html).
`Copy` is usually implemented via `#[derive(Copy)]`.
Types that are `Copy` are copied
rather than being moved out of
(by assignments, parameter passing, etc.)

For other types,
[**Clone**](https://doc.rust-lang.org/std/clone/trait.Clone.html) is a trait with a single method `clone()`
which supports getting a "new object like the original"
whatever that means.
You might think of it as a copy
(although in the Rust world "copy" often means strictly `Copy`).
For example,
while [`String`](https://doc.rust-lang.org/std/string/struct.String.html)`::clone()` copies the data into a new heap allocation,
[`Arc`](https://doc.rust-lang.org/std/sync/struct.Arc.html#cloning-references)`::clone()` increments the reference count,
rather than copying the underlying object.
Obviously not every type is `Clone`.

Values are destroyed when the variable containing them
goes out of scope,
or (rarely) by explicit calls to [`std::mem::drop`](https://doc.rust-lang.org/std/mem/fn.drop.html) or the like.
When a value is destroyed,
all of its fields are automatically destroyed too.
If this is nontrivial the type is said to have "drop glue"
(and, obviously, it is not `Copy`).

If a type's destruction needs something more than
simply destroying each of its fields,
it can `impl `[`Drop`](https://doc.rust-lang.org/std/ops/trait.Drop.html).
You provide a function **drop**
which is called automatically
precisely once
just before the fields are themselves destroyed.

There are no special "constructors" in Rust.
It is conventional to provide a function **Type::new()**
for use as a constructor,
but it is not special in any way.
It typically does whatever setup is needed and
finishes with a struct literal for the type.
Conventionally,
types that have a zero-argument `new()` usually implement `Default`.
Constructors that take arguments are often
named like `Type::with_wombat()`.

It is very common to construct from a value of another relevant type,
for exmaple via the [`From`](https://doc.rust-lang.org/std/convert/trait.From.html) and [`Into`](https://doc.rust-lang.org/std/convert/trait.Into.html) traits,
or specific methods
(for purposes like complex construction or conversion,
typestate arrangements, and so on).

There is no equivalent to C++'s "placement new".
It is up to the caller whether the created object will go on the heap.
Indeed, an object from `Type::new` might never be on the heap.
Or it might be on the stack for a bit and then later be
moved to the heap for example using [`Box`](https://doc.rust-lang.org/std/boxed/index.html)`::new()`.

Borrow checker
--------------

Correctness is enforced by a proof checker in the compiler,
known as the **borrow checker**.

The borrow checker is (supposed to be) sound, but not complete.
The scope of its (in)completeness is not documented
(and is probably not possible to document in a reasonable way).
This incompleteness is often encountered in practice.

When you find your program is rejected by the borrow checker,
firstly try the compiler's suggestions,
which are generally very good
(especially if the programmer is new to Rust).

If that fails, the right approach is to flail semi-randomly
applying the various tactics you're aware of.
When the program compiles, it is correct.

If the program cannot be made to compile,
then one of the following is the case:

 * You haven't flailed hard enough `:-)`.

 * There is a mistake in the ownership model
   implied by the program design,
   or a bug.
   I.e. the algorithm could indeed generate or try to use
   incompatible references,
   even though you mistakenly think it can't.

 * The ownership model implied by the program design
   is too complicated for the borrow checker.
   This often arises with self-referential data structures.

   Another classic example is that soundness of
   an implementation of [`Iterator<Item=&mut T>`](https://doc.rust-lang.org/std/iter/trait.Iterator.html) 
   often depends on
   the *correctness* of the underlying iteration algorithm;
   since soundness depends on it not returning the same item twice.
   The borrow checker is not typically able to check the
   correctness of a from-scratch `impl Iterator for ..::IterMut`.

   There are also a few commonly-arising particular limitations,
   for example [one surrounding borrowing and early exits](https://github.com/rust-lang/rust/issues/51545).

### Tactics for fighting the borrow checker

 * Copy rather than borrowing:
   Sprinkle `.clone()`, [`.to_owned`](https://doc.rust-lang.org/std/borrow/trait.ToOwned.html), etc., and/or
   change types to owned variants (or [`Cow`](https://doc.rust-lang.org/std/borrow/enum.Cow.html)).

 * Introduce `let` bindings to prolong the lifetime of temporaries.
   (Normally if this will help the compiler will suggest it.)

 * Introduce a `match`.
   Within the body of the `match`,
   all the values computed in the match expression remain live.
   This is often used in macros.

 * Add lifetime annotations.
   Typically, as you add lifetime annotations,
   the compiler messages will become more detailed and precise.
   However, they will also become harder to read `:-)`.
   One can add lifetime annotations until the code compiles,
   and then commit,
   and start removing them again to try to trim the redundant ones.

 * Add redundant type and lifetime annotations to closures
   (`'_`, `_`, `&'_ _`, `-> &'_ _` etc.)
   The type and [lifetime elision](https://doc.rust-lang.org/reference/lifetime-elision.html) rules can interact badly with closures.
   Sometimes writing out explicit types and lifetimes,
   even completely elided ones,
   can make it work.

 * Turn a closure into a function, and pass in the closed-over variables.
   Closures are not generic.  Even over lifetimes.
   So if you call a closure on `&a` and `&b`,
   there needs to be a single lifetime that is correct for both calls.
   If you turn the closure into a `fn` (writing out all the types, sorry)
   then it can be generic over the relevant lifetimes ---
   and in particular,
   its return value can now borrow from its input
   even if the different calls have inputs with different lifetimes.

### Strategies for evading the borrow checker

If you have a correct program, but the borrow checker can't see it,
and you can't persuade it,
you have these options:

 * Use runtime ownership checking instead of compile-time checking.
   I.e., switch to
    [`Arc`](https://doc.rust-lang.org/std/sync/struct.Arc.html)
    [`Mutex`](https://doc.rust-lang.org/std/sync/struct.Mutex.html)
    (maybe [`parking_lot`](https://crates.io/crates/parking_lot)'s),
    [`Rc`](https://doc.rust-lang.org/std/rc/struct.Rc.html),
    [`RefCell`](https://doc.rust-lang.org/std/cell/struct.RefCell.html) etc.

   This may be not as slow as you think.
   `Arc` in particular is less slow than reference counting
   in many other languages,
   since you usually end up passing `&Arc<T>` around,
   borrowing a reference rather than manipulating the refcount.

 * Use a crate like
   [`generational_arena`](https://crates.io/crates/generational_arena) or
   [`slotmap`](https://crates.io/crates/slotmap) or
   [`slab`](https://crates.io/crates/slab)
   where the data structure owns the values,
   and your "references" are actually indices.

   These often perform very well, and are ergonomic to use.

 * Completely change the algorithm and data structures
   (for example to make things less self-referential).

 * Use `unsafe` and take on a proof obligation.
   How onerous that is depends very much on the situation.
