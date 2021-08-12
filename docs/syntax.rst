Syntax
======

Rust distinguishes items, statements, and expressions.
Control flow statements tend to require block expressions (``{ }``).

Also very important are patterns,
which are used for variable binding
and sum type matching.

Comments are usually ``//`` but ``/*..*/`` is also supported.

The top level of a module may contain only items.
In particular, ``let`` bindings are not permitted outside code blocks.

Attributes
----------

Rust code is frequently littered with ``#[attributes]``.
These can be placed before the item or expression they refer to.
The semantics are very varied.
New attributes can be defined by libraries.

Notable is ``#[derive(...)]`` which invokes a procedural macro.
Many Rust libraries provide extremely useful derive macros
for structs and enums.

The syntax ``#![attribute]`` applies the attribute to
the thing the attribute placed inside.
Typically it is found only at the top of a whole module or crate,


Items
-----

::

    fn function(arg: T) -> ReturnValue { ... }
    type TypeAlias = (SomeType, OtherType); // type aliases equality structural
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

    { stmt0; stmt1; } // with semicolon, has type ( )
    { stmt0; stmt1 } // no semicolon, has type of stmt1
    if condition { statements... }
    if condition { value } else { other_value }
    'loopname: loop { ... } // 'loopname is optional, of course
    'loopname: while condition { }
    'loopname: while let pattern = expr { }
    'loopname: for loopvar in something_iterable { ... }
    return v; // at end of function, it is idiomatic to just write v
    continue; continue 'loop; break; break 'loop;
    break value; break 'loop value; // `loop` loops only, not for/while
    match value { ... } // see "Patterns", in "Types and Patterns"
    function(arg0,arg1)
    receiver.method(arg0,arg1,arg2) // see the section on "Methods"
    fallible? // see [error handling]
    *value // deref, see [methods]
    |arg0, arg1: Type1| -> Returns expression // closure
    WrappedCounter { counter: 42 } // constructor ("struct literal")

Note the odd semicolon rule,
which determines the type of block expressions.

Closure argument and return types an often be inferred.
Missing return type on a ``fn`` means ``()``;
missing return type on a closure means ``_``;


Other statements
-----------------

``let`` introduces a binding.

::

   let pattern = value;
   if let pattern = value { .... }

Variable names may be reused by rebinding;
this is often considered idiomatic.

In a block,
you can define any other kind of item,
which will have local scope.

Identifiers and scopes
----------------------

Rust's identifiers are in the form ``scope::scope::ident``.

Here ``scope`` can be a module, or an external library ("crate"),
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

``_`` can often be written when an identifier is espected.
For a type, it asks the compiler to infer the type.
For a binding, it assigns the value to an anonymous variable,
effectively discarding it.
