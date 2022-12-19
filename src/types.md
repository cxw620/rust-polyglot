Types and patterns
==================

[comment]: # ( Copyright 2021-2022 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Rust's type system is based on Hindley-Milner-style
[algebraic types](https://en.wikipedia.org/wiki/Algebraic_data_type),
as seen in languages like ML and Haskell.

The compiler will often infer the types of variables (including closures)
and also usually infer the correct types for a generic function call.
Type elision is not supported everywhere,
notably in function signatures and public interfaces.

Generics
--------

Types, functions, and traits can be generic over other types
(and over lifetimes and some types of constant).
This is done with a C++-like `< >` syntax.

Generic code will be monomorphised automatically by the compiler,
for all of the concrete types that are actually required.

When it is necessary to explicitly specify generic parameters,
for example in a function call,
one uses the
[turbofish](https://doc.rust-lang.org/reference/glossary.html?highlight=turbo#turbofish) syntax
(so named because `::<>` looks a bit like a speedy fish):

```
let r = function::<Generic,Args>(...);
```

Generic parameters can be constrained with bounds written
where they are introduced `fn foo<T: Default + Clone>() -> T;`
or with where clauses `fn foo<T>() -> T where T: Default + Clone;`.
Lifetimes are constrained thus: `'longer: 'shorter`,
reading `:` as "outlives".


Types
-----

Nominal types can be defined in terms of (combinations of) other types:

| Semantics | Syntax (definition of nominal type)
| ------- | ---------------------------- |
| Product, named fields  |  `struct S { f: u64, g: &'static str }`
|  Product, tuple-like    | `struct ST(u64, ());`                     |  
| Empty products (units) | `struct Z0; struct Z1(); struct Z2{}`	  
| Sum type | `enum E { V0, V1(usize), V2{ f: String, } }`	  
| Uninhabited type | `enum Void { }` - see [Uninhabited types](#uninhabited-types)
| Generic type | e.g. `struct SG<F>{ f: F, g: &'static str }`	  
| Untagged union (unsafe) | `union U {...}`			  

Otherwise, types have structural equivalence.

| Semantics | Syntax (referring to a type) |
| -- | -- |
| Named type (see above) | `S`, `ST`, `Z0`, `E`, `Void`, `SG<u8>`, `U` |
| Empty tuple (primitive unit type) | `()`
| Product type, tuple | `(T,)`, `(T,U)`, `(T,U,V)` etc.
| Primitive integers | `usize`, `isize`, `u8`, `u16` .. `u128`, `i8` .. `i128`
| Floating point (IEEE-754) | `f32`, `f64` |
| Other Primitives | `bool`, `char`, `str`
| Array | `[T; N]`
| Slice | `[T]`
| References (always valid, never null) | `&T`, `&mut T`, `&'lifetime T`, `&'l mut T`
| Raw pointers | `*const T`, `*mut T`
| Runtime trait despatch (vtable) | `dyn Trait`
| [Existential type](traits.md#existential-types) | `impl Trait`
| Type to be inferred | `_`, `&'_ T`, `&'_ mut T` |

Most of these are straightforward.

[**char**](https://doc.rust-lang.org/std/primitive.char.html) is a [Unicode Scalar Value](http://www.unicode.org/glossary/#unicode_scalar_value).

In Rust an 
[**array**](https://doc.rust-lang.org/std/primitive.array.html)
 has a size fixed at compile time.
(Generic types can be parameterised by constant integers,
not only types,
so the same code can compile with a variety of different array sizes,
resulting in monomorphisation.)
Often a slice is better.

A 
[**slice**](https://doc.rust-lang.org/std/primitive.slice.html) is a contiguous sequence of objects of the same type,
with size known at run-time.
The slice itself (`[T]`) means the actual data,
not a pointer to it - rather an abstract concept.
Normally one works with `&[T]`, which is a reference to a slice.
This consists of a pointer to the start, and a length.

A slice is just an example of an **unsized** type
(a.k.a. dynamically sized type, **DST**):
a type whose size is not known at compile time.
References (and heap and raw pointers) to unsized types are "fat pointers":
they are two words wide - one for the data pointer, and one for the metadata.

Unsized *values* cannot be stack allocated,
nor passed as parameters or returned from functions.
But they can be heap allocated, and passed as references.
Often, unsized references are type-erased references to sized values
(see also [Coercion](#coercion)).

[**str**](https://doc.rust-lang.org/std/primitive.str.html) is identical to `[u8]` (ie, a slice of bytes),
except with the guarantee that it consists entirely of valid UTF-8.
As with `[u8]`, usually one works with `&str`.
Making a `str` containing invalid UTF-8 is UB
(and, therefore, not possible in Safe Rust).
C.f. [`String`], [`Box<str>`](https://doc.rust-lang.org/std/boxed/struct.Box.html#impl-From%3C%26%27_%20str%3E)

[**dyn Trait**](https://doc.rust-lang.org/reference/types/trait-object.html) is a **trait object**:
an object which implements `Trait`,
with despatch done at run-time via a vtable.
(Not to be confused with `impl Trait`.)
`&dyn Trait` is a pointer to the object,
plus a pointer to its vtable; `dyn Trait` itself is unsized.

[**usize**](file:///home/rustcargo/docs/share/doc/rust/html/std/primitive.usize.html) is the type of array and slice indices.
It corresponds to C `size_t`.
Rust
[avoids](https://doc.rust-lang.org/std/primitive.pointer.html#method.offset_from)
the existence of objects bigger than fits into an `isize`.

The empty tuple `()`, aka "unit", is the type of
blocks (incl. functions) that do not evaluate to (return) an actual value.

Unit structs are used extensively in idiomatic Rust, e.g.
as things to `impl Trait` for,
parameters indicating a type rather than value,
and as objects to hang methods on.

### Some very important nominal types from the standard library

| Purpose | Type |
| -------- | --- |
| Heap allocation | [`Box<T>`][`Box`]
| Expanding vector (ptr, len, capacity) | [`Vec<T>`][`Vec`]
| Expanding string (ptr, len, capacity) | [`String`]
| Hash table / ordered B-Tree | [`HashMap`] / [`BTreeMap`]
| Reference-counted heap allocation <br> (no GC, can leak cycles) | [`Arc<T>`](https://doc.rust-lang.org/std/sync/struct.Arc.html), [`Rc<T>`](https://doc.rust-lang.org/std/rc/index.html)
| Optional (aka Haskell `Maybe`) | [`Option<T>`][`Option`]
| Fallible (commonly a function return type) | [`Result<T,E>`][`Result`]
| Mutex (for multithreaded programs) | [`Mutex<T>`](https://doc.rust-lang.org/std/sync/struct.Mutex.html), [`RwLock<T>`](https://doc.rust-lang.org/std/sync/struct.RwLock.html)

See also
[our table comparing `Box`, `Rc`, `Arc`, `RefCell`, `Mutex` etc.](ownership.html#interior-mutability-table)

Other important types include:
[`BufReader`]/[`BufWriter`],
[`VecDeque`],
[`Cow`].

[`Path` and `PathBuf`](https://doc.rust-lang.org/nightly/std/path/) appear in many standard library APIs.
They must be used if your program should support accessing
arbitrarily named files
(i.e. even files whose names are not valid Unicode).
But they are very awkward.
They are a veneer over
[`OsString`]/[`OsStr`] which have a very very limited API,
primarily because [Windows is terrible](https://docs.rs/bstr/latest/bstr/#file-paths-and-os-strings).
If you need to do anything nontrivial with filenames,
you may need [`os_str_bytes`].
If you can limit yourself to valid Unicode,
you can just pass `str` to the standard library file APIs.

Literals
--------

| Type | Examples |
| ---- | ---- |
| integer (inferred) | `0`, `1`, `23_000`, `0x7f`, `0b010`, `0o27775` |
| integer (specified) | `0usize`, `1i8`, `0x7fu8` |
| floating point | `0.`, `1e23f64` |
| `&'static str` | `"string"`, `"\n\b\u{007d}\""`, `r#"^raw:"\.\s"#` [etc.](https://doc.rust-lang.org/reference/tokens.html#string-literals) |
| `char` | `'c'`, `'\n'`, [etc.](https://doc.rust-lang.org/reference/tokens.html#character-literals)
| `&'static [u8]` | `b"byte string"` [etc.](https://doc.rust-lang.org/reference/tokens.html#byte-string-literals), `&[b'c', 42]` (actually `&[u8;2]`) |
| `[T; N]` | `["hi","there"]` (`[&str; 2]`), `[0u32;14]` (`[u32; 14]`) |
| `()`, `(T,)`, `(T,U)` | `()`, `(None,)` `(42,"forty-two")` |

Numeric literals default to `i32` or `f64` as applicable,
if the type is not specified and cannot be inferred.

### Nominal types (e.g., structs)

Literals of nominal types use a straightforward
literal display syntax.
Enum variants, qualified by their enum type, are constructors
(although they are not types in their own right).

Named fields can be provided in any order;
the provided field values are computed in the order you provide.
Aggregates can be rest-initialised with `..`,
naming another value of the same type (often `Default::default()`).

Instead of `field: field`, you can just write `field`,
implicitly referencing a local variable with the same name.

Using the examples from above:

```
   let _ = S { f: 42, g: "forty-two" };
   let _ = ST(42, ());
   let _ = Z0;
   let _ = Z1();
   let _ = Z2{};
   let _ = E::V0;
   let _ = E::V1(42);
   let _ = E::V2 { f: format!("hi") };
   let _ = SG       { f: 0u8,                g: "type of F is inferred"  };
   let _ = SG::<u8> { f: Default::default(), g: "type of F is specified" };
   let f = 0u8; let _ = SG { g: "f is abbreviated", f };
```

If a nominal type has fields you cannot name because they're not `pub`,
you cannot construct it.


Coercion
--------

Rust does have
implicit type conversions (["coercions"](https://doc.rust-lang.org/reference/type-coercions.html))
but only to 
[change the type, not (in general) the value](https://doc.rust-lang.org/reference/type-coercions.html#coercion-types).
The effect is to make many things Just Work,
e.g. passing `&[T;N]` as a slice `&[T]`,
or `&Struct` as `&dyn Trait` where `Struct` implements `Trait`.

Sometimes,
especially with these
[conversions to unsized](https://doc.rust-lang.org/reference/type-coercions.html#unsized-coercions),
writing _`expression`_ `as _` can help,
to introduce an explicit conversion to an inferred type.
If the type is numeric, this can be lossy -
see [under Safety](safety.md#integers-conversion-checking)

Patterns
--------

Rust uses functional-programming-style pattern-matching
for variable binding,
and for handling sum types.

The pattern syntax is made out of constructor syntax, with some
additional features:

 * `pat1 | pat2` for alternation
   (both branches must bind the same names).
 * `name @ pattern` which binds `name`
   to the whole of whatever matched `pattern`.
 * `ref name` avoids moving out of the matched value;
   instead, it makes the binding a reference to the value.
 * `mut name` makes the binding mutable.

There is a special affordance when
a reference is matched against a pattern:
if the pattern does not itself start with `&`
the individual bindings themselves bind references to the contents
of the referred-to value (as if they had been `ref binding`).

Writing just the field name in a struct pattern
binds a local variable of the same name as the field.

[Unneeded (parts of) values](https://doc.rust-lang.org/stable/book/ch18-03-pattern-syntax.html#ignoring-values-in-a-pattern) can be ignored
([not even bound](https://github.com/rust-lang/rust/issues/10488#issuecomment-30879810))
by writing
`_` or `..` .
The usual idiom to suppress the `#[must_use]` warning is `let _ = ...`.


Irrefutable patterns appear in ordinary `let` bindings
and function parameters.
(It is not possible to define the different pattern matches
for a single function name separately like in Haskell or Ocaml;
use `match`.)

Refutable patterns appear in `if let`, `let...else`, `match`
and `matches!`.

`match` is the most basic way to handle a value of a sum type.
```
  match variable { pat1 => ..., pat2 if cond =>, ... }
```
Here `cond` may refer to the bindings established by `pat2`.

Uninhabited types
-----------------

You can write `!` for a function return type
to indicate that it won't return.
But `!` is 
[not a first-class type in Stable Rust](https://doc.rust-lang.org/reference/types/never.html?highlight=never#never-type);
you can't generally use it as a generic type parameter, etc.

You can define an enum with no variants.
The standard library has `Infallible` which is
an uninhabited error type,
but its ergonomics are not always great.
The crate [`void`] can help fill this gap.
It provides not only a trivial uninhabited type (`Void`)
but also
helpful trait impls, functions and macros.

Other features
---------------

[`#[non_exhaustive]`](https://doc.rust-lang.org/reference/attributes/type_system.html#the-non_exhaustive-attribute) for reserving space to
non-breakingly extend types in your published API.

[`#[derive]`](https://doc.rust-lang.org/reference/attributes/derive.html#derive), often `#[derive(Trait)]`, for many `Trait`.
In particular, see:

 * `#[derive(`[`Default`](https://doc.rust-lang.org/std/default/trait.Default.html)`])`
 * `#[derive(`[`Debug`](https://doc.rust-lang.org/std/fmt/trait.Debug.html)`])`
 * `#[derive(`[`Clone`](https://doc.rust-lang.org/std/clone/trait.Clone.html)`,`[`Copy`](https://doc.rust-lang.org/std/marker/trait.Copy.html)`)]`
 * `#[derive(`[`Eq`](https://doc.rust-lang.org/std/cmp/trait.Eq.html)`,`[`PartialEq`](https://doc.rust-lang.org/std/cmp/trait.PartialEq.html)`,`[`Ord`](https://doc.rust-lang.org/std/cmp/trait.Ord.html)`,`[`PartialOrd`](https://doc.rust-lang.org/std/cmp/trait.PartialOrd.html)`)]`
 * `#[derive(`[`Hash`]`)]`

It is conventional for libraries to promiscuously implement these for
their public types, whenever it would make sense.

If you derive `Hash`, but manually implement `Eq`,
see the [note in the docs for `Hash`](https://doc.rust-lang.org/std/hash/trait.Hash.html#hash-and-eq).
