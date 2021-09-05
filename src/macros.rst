Macros and metaprogramming
==========================

..
    Copyright 2021 Ian Jackson and contributors
    SPDX-License-Identifier: MIT
    There is NO WARRANTY.

Overview
--------

Rust itself has two macro systems,
and cargo has built-in support for
some build hooks including build-time code generation.

Many macros are "function-like":
invoked as ``macro!(...)``
(where ``macro`` is the name of the macro).
They can expand to expressions, blocks, types, items, etc.
You can write ``macro!{..}``, ``macro!(..)`` and ``macro![..]``,
as you please.
``macro_rules!`` macros cannot distinguish these cases,
but there is generally a conventional invocation style for each macro.

Rust also supports attribute macros and derive macros,
which are invoked as
``#[macro]`` (before some language construct)
and
``#[derive(macro)]`` (before a struct, enum, or union).

You can qualify the macro name with a crate or module path.

"Macros by example" ``macro_rules!``
------------------------------------

``macro_rules!`` defines a (function-like) macro in terms of
template matches and and substitutions.

::

   macro_rules! name { { template1 } => { replacement1 }, ... }
   name!{ ... }

The contents of the macro invocation are matched against
the templates in turn,
stopping at the first one that matches.

Non-literal text in the template is introduced with ``$``:

::

   $binding:syntaxtype     syntaxtype can be one of
       block expr ident item lifetime literal
       meta pat pat_param path stmt tt ty vis
   $( ... )?
   $( ... )*  $( ... ),*    could be other separators besides ,
   $( ... )+  $( ... ),+    could be other separators besides ,

In the replacement, write just ``$binding`` (without the syntax type).

Curious points:

 * ``macro_rules!`` macros are partially hygienic.

 * The repetition and optional constructs have funky rules
   to relate repetitions in the substitution to
   repetitions in the template,
   to find the the number of repetitions for the output.

 * Use of the syntax item bindings has a side effect of
   transfoming that part of the input from
   an unstructured token stream
   into a pseudo-token representing an AST node.
   This can cause trouble if the result is fed to further macros.

 * The syntax item bindings have annoying rules
   about what they can be followed by.
   These rules appear intended to remove shift/reduce conflicts
   and therefore remove ambiguity,
   but of course the first-match over the whole set of patterns
   provides the ability to parse ambiguous grammars.
   Additionally, the rules
   (and indeed precisely what these tokens match)
   have not 100% kept pace with Rust's language evolution.
   The usual way to deal with this is simply to define one's macro
   to take ``,`` or ``;`` delimiters, where this problem arises.

 * Macros which are lexically in scope at, and precede, the call site
   do not need qualified names (and can be entirely local).
   To make a macro available elsewhere,
   write ``#[macro_export]`` before it.
   This will cause the macro to exist as a name in the toplevel
   of the current *crate* (not in the current module),
   from where it can be ``use``\ d.
   (Rust 2015 has even odder scoping rules.)

There are many details which are too fiddly to go into here.

If you want to do something exciting in a ``macro_rules!`` macro,
the ``paste`` token pasting crate may be helpful.

Procedural macros ``proc_macro``
--------------------------------

Rust's 2nd macro system is very powerful and
forms the basis for many advanced library facilities.
The basic idea is: a proc_macro is a function
from a ``TokenStream`` to a ``TokenStream``.

It can arbitrarily modify the tokens as they pass through,
and/or generate new tokens.
There are libraries for parsing the token stream into
an AST representation of Rust,
and for quasiquoting.

proc_macros can be "function-like",
but they can also be
``#[attribute]``\ s which are prefixed to their input
(often used for code and particularly function transformations),
and the heavily used
``#[derive(macro)]``
which is applied to a struct, enum or union;
in this case the input (the struct) is retained unchanged,
and the tokenstream produced by the macro function is
inserted after its definition.

Many important Rust facilities and libraries are derive macros.

proc_macros operate at a syntactic, not semantic level.
They do not have access to compiler symbol tables, or
type information (other than types appearing lexically in the macro input).

Each macro invocation is independent.
There is no way to pass information
from one proc_macro invocation
to the proc_macro expansion code for another invocation.
However, it is usually possible to achieve the desired results
by writing independent syntactic macros,
that expand to
Rust code which causes the compiler
to correlate the relevant information, and calculate the implications,
after all the macros have been expanded.

It is possible to have macros generate other macro definitions,
at the cost of introducing some scoping/resolution order issues.
Broadly, a macro-defined macro can only be available, within its crate,
in lexically-subsequent code;
outside its crate it can be available anywhere.


Practicalities
~~~~~~~~~~~~~~

For Reasons,
a proc_macro must be a separate crate,
and, in cargo terms, package.
Usually a proc_macro needs some non-macro support,
or is just an affordance to help use some non-macro Rust.
It is conventional to wrap a proc_macro
in a package containing the non-macro code,
and to use ``use`` to re-export the macro.

You should probably maintain the macro package as another
member of a cargo workspace,
alongside the non-macro facade/utilities.

The macro crate ends up as a separate package on ``crates.io``.
It is conventional to call it ``...-macros`` or ``...-derive``.

To write a proc_macro,
you will probably want to use some of these libraries:

  * ``syn`` for parsing a ``TokenStream`` into an AST.
  * ``proc-macro-error`` for providing pleasant error messages.
  * ``proc_macro2`` to arrange that your main macro functionality
    can be tested outside of the rustc macro context.
  * ``quote`` for quasiquoting macro output.

proc_macros are entirely unhygienic.
In your macro output,
you must fully qualify the names of everything you use,
even things from std.

``build.rs``
------------

cargo supports running code at build-time,
by providing a file ``build.rs`` in the toplevel
containing appropriate functions.
This can run arbitrary code,
and includes the ability to generate ``*.rs`` files
to be included in the current crate build.

This is an awkward way to to organise build-time code generation,
because Rust is not an ideal language for writing build rules
(although it can make a good language for generating Rust code).

``build.rs`` can be the best choice
if you want very portable build-time code generation
since it doesn't rely on anything but the Rust system
that you were depending on anyway.
