Types and patterns
==================

Rust's type system is based on Hindley-Milter-style algebraic types,
as seen in languages like ML and Haskell.

The compiler will often infer the types of variables (including closures)
and also usually infer the correct types for a generic function.
Type inference is not supported everywhere,
notably in function signaturesa nd public interfaces.

When type inference is supported, it is not always successful;
if it isn't the compiler will say "type annotations needed".
In this case a ``let`` binding specifying a type can often help.

Types
-----

Type definitions for a nominal type ``N``.
Each of these defines a new type which is not the same as any other.

 +----------------------------+-------------------------------------+
 | Sum type                   | ``enum N { V0, V1(..), V2{..}``     |
 +----------------------------+-------------------------------------+
 | Product, named fields      | ``struct N { f: T, g: U };``        |
 +----------------------------+-------------------------------------+
 | Product, tuple-like        | ``struct N(T,U);``                  |
 +----------------------------+-------------------------------------+
 | Generic type               | e.g. ``struct N<F>{ f: F, g: U }``  |
 +----------------------------+-------------------------------------+

Types have their own syntax:

 Named type (see above)     | N
 Product type, typle        | (T,U)
 Array                      | [T; N]
 Slice                      | [T]
 References                 | &T, &mut T
 Raw pointers               | *const T, *mut T
 Primitive integers         | usize, isize, u8, u16 .. u128, i8 .. i128
 Primitives                 | bool, char, str
 Runtie trait despatch      | dyn Trait

Many important types are defined as nominal types
in the standard library, notably:

 Heap allocation                           | Box<T>
 Expanding vector (ptr/len/capacity)       | Vec<T>
 Expanding string (ptr/len/capacity)                        | String
 Reference-counted heap allocation (no GC, leask on cycles) | Arc<T>, Rc<T>
 Optional (aka Haskell ``Maybe``)          | Option<T>
 Faillible                                 | Result<T,E>

Patterns
--------
