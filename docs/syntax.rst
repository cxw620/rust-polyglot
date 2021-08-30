Syntax
======

..
    Copyright 2021 Ian Jackson and contributors
    SPDX-License-Identifier: MIT
    There is NO WARRANTY.

Rust distinguishes items, statements, and expressions.
Control flow statements tend to require block expressions (``{ }``).

Also very important are patterns,
which are used for variable binding
and sum type matching.

Comments are usually ``//`` but ``/*..*/`` is also supported.

The top level of a module may contain only items.
In particular, ``let`` bindings are not permitted outside code blocks.

Generally, a redundant trailing ``,`` is allowed at the end of lists
(of values, arguments, etc.).
But ``;`` is very significant and is usually either required, or forbidden.

Attributes
----------

Rust code is frequently littered with ``#[attributes]``.
These are placed before the item or expression they refer to.
The semantics are very varied.
New attributes can be defined as procedural macros in libraries.

Notable is ``#[derive(...)]`` which invokes a macro
to autogenerate code based on a data structure type.
Many Rust libraries provide extremely useful derive macros
for structs and enums.

The syntax ``#![attribute]`` applies the attribute to
the thing the attribute placed inside.
Typically it is found only at the top of a whole module or crate,

Attributes are used for many important purposes:
  * `Conditional compilation <https://doc.rust-lang.org/reference/conditional-compilation.html>`_ ``#[cfg(..)]``;
  * Denoting functions whose value should be checked ``#[must_use]``
    (and types which should not be simply discarded);
  * Suppressing warnings locally ``#[allow(dead_code)]`` or
    for a whole crate (at the toplevel) ``#![allow(dead_code)]``;
  * Enabling unstable features on Nightly
    ``#![feature(min_type_alias_impl_trait)]``;
  * Marking functions as tests ``#[test]``;
  * Request (hint) inlining ``#[inline]``.
  * Control a `type's memory layout <https://doc.rust-lang.org/reference/type-layout.html>`_ ``#[repr(...)]``.
  * Specify where to find the source for a module
    ``#[path="foo.rs"] mod bar;``.

Items
-----

::

    fn function(arg: T) -> ReturnValue { ... }
    type TypeAlias = OtherType; // type alias, structural equality
    pub struct WrappedCounter { counter: u64 } // nominal type equality
    trait Trait { fn trait_method(self); }
    const FORTY_TWO: u32 = 42;
    static TABLE: [u8; 256] = { 0x32, 0x26, 0o11, ...many entries };
    impl Type { ... }
    impl Trait for Type { ... }
    mod some_module; // causes some_module.rs to be read
    mod some_module { ... } // module source is right here

Expressions
-----------

Most of the usual infix and assigment operators are available.
Control flow "statements" are generally expressions:

::

    { stmt0; stmt1; }  // with semicolon, has type ( )
    { stmt0; stmt1 }   // no semicolon, has type of stmt1

    if condition { statements... }                // can only have type ()
    if condition { value } else { other_value }   // no ? :, use this
    if let pattern = value { .... } [else ...]    // pattern binding condition
    match value { pat0 if c0 => expr0,.. }        // see "Types and Patterns"

    'loopname: loop { ... }                              // 'loopname
    'loopname: while condition { }                       // is optional
    'loopname: while let pattern = expr { }              // of course
    'loopname: for loopvar in something_iterable { ... } //

    return v  // at end of function, it is idiomatic to just write v
    continue; continue 'loop; break; break 'loop
    break value; break 'loop value; // `loop` only; specifies value of `loop` expr

    function(arg0,arg1)
    receiver.method(arg0,arg1,arg2)  // see the section on "Methods"
    |arg0, arg1: Type1| -> ReturnType expression  // closure

    fallible?                      // see [error handling]
    *value                         // deref, see [methods]
    type as other_type             // type conversion (safe but maybe lossy)
    WrappedCounter { counter: 42 } // constructor ("struct literal")

    collection[index]        // usually panics if not found, eg array bounds check
    thing.field              // field of a struct with named fields
    tuple.0; tuple.1;        // fields of type or tuple struct    
    start..end; start..=end  // end-exclusive and -inclusive Range

Note the odd semicolon rule,
which determines the type of block expressions.

Missing return type on a ``fn`` item means ``()``;
missing return type on a closure means ``_``;


Other statements
-----------------

``let`` introduces a binding.

::

   let pattern = value;

Variable names may be reused by rebinding;
this is often considered idiomatic.

In a block,
you can define any other kind of item,
which will have local scope.

Identifiers and scopes
----------------------

Rust's identifiers are in the form ``scope::scope::ident``.

Here ``scope`` can be a module, type or trait,
or an external library ("crate"),
or special values like ``crate``, ``self``, ``super``.

Each Rust module
(file, or ``mod { }`` within a file)
has its own namespace.
Other names are imported using ``use``.
Items can be renamed during import using ``as``.

Rust has strong conventions about identifier case and spelling,
which the compiler will warn you about violating:

 * ``snake_case``: Variables, functions and modules.
 * ``StudlyCaps``: Types (including enum variant names)
 * ``SCREAMING_SNAKE_CASE``: Constants and global variables.

``-`` is not valid in identifier names in Rust source code
but when found in other places in the Rust world,
you may encounter its use described as ``kebab-case``.

Many items (including functions, types, fields of product types, etc.)
can be public (``pub``) or private to the module (the default).

``_`` can often be written when an identifier is expected.
For a type or lifetime, it asks the compiler to infer.
For a binding, it discards the value (droping it right away).
