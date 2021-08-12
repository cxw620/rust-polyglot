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


Types
-----

Type definitions for a nominal type ``N``.
Each of these defines a new type which is not the same as any other.


Defining new named types
~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
 :widths: 35 65

 * - Sum type
   - ``enum N { V0, V1(..), V2{..}, }``
 * - Product, named fields
   - ``struct N { f: T, g: U };``        
 * - Product, tuple-like
   - ``struct N(T,U);``
 * - Product, units
   - ``struct N0; struct N1{}; struct N2{}``
 * - Uninhabited type
   - ``enum Void { }`` // see `Infallible` in std; `void` crate
 * - Generic type
   - e.g. ``struct N<F>{ f: F, g: U }``

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

**``char``** is a Unicode Scalar Value.  See the documentation.

In Rust an **array** has a size fixed at compile time.
(Generic types can be parameterised by constant integers,
as well as other types,
so the same code can compile with a variety of different array sizes,
resulting in monomorphisation.)
Often a slice is better.

A **slice** is a contiguous sequence of objects of the same type.
The slice itself (``[T]``) means the actual data,
not a pointers to it - rather an abstract concept.
Normally one works with ``&[T]``, which is a reference to a slice.
This consists of a pointer to the start, and a length.

A slice is just an example of an **unsized** type:
a type whose size is not known at compile time.

Unsized values cannot be stack allocated,
nor passed as parameters or returned from functions.
But they can be heap allocated, and passed as references.
References to unsized types are "fat pointers":
they are two words wide - one for the data pointer, and one for the metadata.

**``dyn Trait``** is a **trait object**:
an object which implements ``Trait``,
with despatch done at run-time via a vtable.
``&dyn Trait`` is a pointer to the object,
plus a pointer to its vtable; ``dyn Trait`` itself is unsized.

**``str``** is identical to ``[u8]`` (ie, a slice of bytes),
except with the guarantee that it consists entirely of valid UTF-8.
As with ``[u8]``, usually one works with ``&str``.
Making a ``str`` containing invalid UTF-8 is UB
(and, therefore, not possible in Safe Rust).

**``usize``** is the type of array and slice indices.

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
 * - Fallible
   - ``Result<T,E>``



Integers, conversion, checking
------------------------------

     
Patterns
--------
