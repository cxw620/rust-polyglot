Types and patterns
==================

Rust's type system is based on Hindley-Milter-style algebraic types,
as seen in languages like ML and Haskell.

The compiler will often infer the types of variables (including closures)
and also usually infer the correct types for a generic function call.
Type elision is not supported everywhere,
notably in function signatures and public interfaces.

Generics
--------

Types, functions, and traits can be generic over other types
(and over lifetimes and some types of constant).
This is done with a C++-like ``< >`` syntax.

Generic code will be monomorphised automatically by the compiler,
for all of the concrete types that are actually required.

When it is necessary to qualify a function, or in some other
circumstances, the *turbofish* syntax is used, like this::

  function::<Generic,Args>(...)

Generic parameters can be constrained with bounds written
where they are introduced ``fn foo<T: Default>() -> T;``
or with where clauses ``fn foo<T>() -> T where T: Default;``.
Lifetimes are constrained thus: ``'longer: 'shorter``,
reading ``:`` as "outlives".


Types
-----

Examples of nominal type definitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
 :widths: 35 65

 * - Product, named fields
   - ``struct S { f: u64, g: &'static str };``
 * - Product, tuple-like
   - ``struct ST(u64, ());``
 * - Product, units
   - ``struct Z0; struct Z1(); struct Z2{}``
 * - Sum type
   - ``enum E { V0, V1(usize), V2{ f: String, }``
 * - Uninhabited type
   - ``enum Void { }`` // see `Infallible` in std; `void` crate
 * - Generic type
   - e.g. ``struct SG<F>{ f: F, g: &'static str }``

Referring to types
~~~~~~~~~~~~~~~~~~

.. list-table::

 * - Named type (see above)
   - ``N``
 * - Empty tuple (primitive unit type)
   - ``()``
 * - Product type, tuple
   - ``(T,U)``
 * - Primitive integers
   - ``usize``, ``isize``, ``u8``, ``u16`` .. ``u128``, ``i8`` .. ``i128``
 * - Other Primitives                
   - ``bool``, ``char``, ``str``
 * - Array                     
   - ``[T; N]``
 * - Slice                     
   - ``[T]``
 * - References                
   - ``&T``, ``&mut T``
 * - Raw pointers              
   - ``*const T``, ``*mut T``
 * - Runtime trait despatch (vtable)
   - ``dyn Trait``

Most of these are straightforward.

**char** is a Unicode Scalar Value.  See the documentation.

In Rust an **array** has a size fixed at compile time.
(Generic types can be parameterised by constant integers,
as well as other types,
so the same code can compile with a variety of different array sizes,
resulting in monomorphisation.)
Often a slice is better.

A **slice** is a contiguous sequence of objects of the same type,
with size known at run-time.
The slice itself (``[T]``) means the actual data,
not a pointer to it - rather an abstract concept.
Normally one works with ``&[T]``, which is a reference to a slice.
This consists of a pointer to the start, and a length.

A slice is just an example of an **unsized** type:
a type whose size is not known at compile time.

Unsized values cannot be stack allocated,
nor passed as parameters or returned from functions.
But they can be heap allocated, and passed as references.
References to unsized types are "fat pointers":
they are two words wide - one for the data pointer, and one for the metadata.

**str** is identical to ``[u8]`` (ie, a slice of bytes),
except with the guarantee that it consists entirely of valid UTF-8.
As with ``[u8]``, usually one works with ``&str``.
Making a ``str`` containing invalid UTF-8 is UB
(and, therefore, not possible in Safe Rust).

**dyn Trait** is a **trait object**:
an object which implements ``Trait``,
with despatch done at run-time via a vtable.
(Not to be confused with ``impl Trait``,
which is an `existential type`_ .)
``&dyn Trait`` is a pointer to the object,
plus a pointer to its vtable; ``dyn Trait`` itself is unsized.

**usize** is the type of array and slice indices.

Some very important nominal types from the standard library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
 :widths: 65 35

 * - Heap allocation                          
   - ``Box<T>``
 * - Expanding vector (ptr, len, capacity)      
   - ``Vec<T>``
 * - Expanding string (ptr, len, capacity)                       
   - ``String``
 * - Reference-counted heap allocation (no GC, can leak cycles)
   - ``Arc<T>``, ``Rc<T>``
 * - Optional (aka Haskell ``Maybe``)         
   - ``Option<T>``
 * - Fallible (commonly a function return type)
   - ``Result<T,E>``
     
Constructors
------------

Values of aggregate types can be made by with a straightforward
literal display syntax.
Enum variants, qualified by their enum type, are also constructors.
Using the examples from above:

::

   let _ = S { f: 42, g: "forty-two" };
   let _ = ST(42, ());
   let _: E = E::V0;
   let _: E = E::V1(42);
   let _: E = E::V2{ f: format!("hi") };
   let _ = Z0;
   let _ = Z1();
   let _ = Z2{};

Named fields can be provided in any order;
the provided field values are computed in the order you provide.
Aggregates can be rest-initialised with ``..``,
naming another value of the same type (often ``Default::default()``).

If a value has fields you cannot name because they're not ``pub``,
you cannot construct it.

Patterns
--------

Rust uses functional-programming-style pattern-matching
for variable binding,
and for handling sum types.

The pattern syntax is made out of constructor syntax, with some
additional features:

 * ``pat1 | pat2`` for alternation
   (both branches must bind the same names).
 * ``name @pattern`` which binds ``name``
   to the whole of whatever matched ``pattern``.
 * ``ref name`` avoids moving out of the matched value;
   instead, it makes binding a reference to the value.
 * ``mut name`` makes the binding mutable.

There is a special affordance when
a reference is matched against a pattern:
if the pattern does not itself start with ``&``
the individual bindings themselves bind references to the contents
of the referred-to value (as if they had been ``ref binding``).

Unneeded parts of a value can be discarded by use of
``_`` or ``..``.

Irrefutable patterns appear in ordinary ``let`` bindings
and function parameters
(it is not possible to define the different pattern matches
for a single function name separately like in Haskell or Ocaml;
use ``match``.)

Refutable patterns appear in ``if let``, ``match``
and ``matches!``.

``match`` is the most basic way to handle a value of a sum type.

::

  match variable { pat1 => ..., pat2 if cond =>, ... }

Here ``cond`` may refer to the bindings established by pat2.

Other features
---------------

``#[non_exhaustive]`` for reserving space to
non-breakingly extend types in your published API.

``#[derive]``, often ``#[derive(Trait)``, for many ``Trait``.
In particular, see:

 * ``#[derive(Debug)]``
 * ``#[derive(Clone,Copy)]``
 * ``#[derive(Eq,PartialEq,Ord,PartialOrd)]``
 * ``#[derive(Hash)``

It is conventional for libraries to promiscuously implement these for
their public types, whenever it would make sense.

Putting a ``PhantomData`` in your struct is sometimes necessary
to avoid unused type parameters.  See the documentation.
