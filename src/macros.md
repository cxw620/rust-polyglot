Macros and metaprogramming
==========================

Overview
--------

Rust itself has two macro systems
and cargo has a hook for e.g. build-time code generation.
Each has its own section in this chapter:

 * ["Macros by example" `macro_rules!`](#macros-by-example-macro_rules)
 * [Procedural macros `proc_macro`](#procedural-macros-proc_macro)
 * [`build.rs`](#buildrs)

### Macro invocation syntax

Roughly orthogonally to the two macro implementation methods,
there are (broadly) three macro namespaces,
with different invocation syntaxes:

 * "function-like":
   Invoked as `macro!(...)`
   (where `macro` is the name of the macro).
   They can expand to expressions, blocks, types, items, etc.

   You can write `macro!{..}`, `macro!(..)` or `macro![..]`.
   Macros-by-example cannot distinguish these cases,
   but there is generally a conventional invocation style for each macro.
   proc_macros can distinguish them.

 * Attributes: `#[macro]` (before some language construct).
   The macro can filter/alter the decorated thing.

 * `#[derive(macro)]` before a struct, enum, or union.
   The macro does not modify the decorated data structure,
   but it takes it as input and can generate *additional* code.

You can qualify the macro name with a crate or module path.
The rules for macro name scope, export, import, etc. are odd,
and can be confusing in unusual cases.

"Macros by example" `macro_rules!`
----------------------------------

[`macro_rules!`](https://doc.rust-lang.org/reference/macros-by-example.html)
defines a (function-like) macro in terms of
template matches and and substitutions.

```
   macro_rules! name { { template1 } => { replacement1 }, ... }
   name!{ ... }
```

The contents of the macro invocation are matched against
the templates in turn,
stopping at the first one that matches.

Non-literal text in the template is introduced with `$`:

```
   $binding:syntaxtype     syntaxtype can be one of
       block expr ident item lifetime literal
       meta pat pat_param path stmt tt ty vis
   $( ... )?
   $( ... )*  $( ... ),*    could be other separators besides ,
   $( ... )+  $( ... ),+    could be other separators besides ,
```

In the replacement, write just `$binding` (without the syntax type).

Curious points:

 * `macro_rules!` macros are partially hygienic.

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
   to take `,` or `;` delimiters, whenever this problem arises.

 * Macros which are lexically in scope at, and precede, the call site
   do not need qualified names (and can be entirely local).
   To make a macro available elsewhere,
   write `#[macro_export]` before it.
   This will cause the macro to exist as a name in the toplevel
   of the current *crate* (not in the current module),
   from where it can be `use`d.
   (Rust 2015 has even odder scoping rules.)

There are many details which are too fiddly to go into here.

If you want to do something exciting in a `macro_rules!` macro,
the [`paste`](https://docs.rs/paste/latest/paste/) token pasting crate may be helpful.

Procedural macros `proc_macro`
------------------------------

Rust's 2nd macro system is very powerful and
forms the basis for many advanced library facilities.
The basic idea is: a
proc_macro
is a function
from a [`TokenStream`] to a [`TokenStream`].

The macro can arbitrarily modify the tokens as they pass through,
and/or generate new tokens.
There are libraries for parsing the token stream into
an AST representation of Rust,
and for quasiquoting.

proc_macros can be "function-like",
but they can also be
`#[attribute]`s
(often used for code and particularly function transformations),
or
`#[derive(macro)]`s.
Many important Rust facilities and libraries are derive macros.

`#[derive]` macros can define additional helper `#[attributes]`
to be sprinkled on the type or its fields,
to influence the generated code.
(These helper attributes are not namespaced.)

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


### Practicalities


For Reasons,
a proc_macro must be a separate crate,
and, in cargo terms, package.
Usually a proc_macro needs some non-macro support,
or is just an affordance to help use some non-macro Rust.
It is conventional to wrap a proc_macro
in a package containing the non-macro code,
and to use `use` to re-export the macro.

You should probably maintain the macro package as another
member of a cargo workspace,
alongside the non-macro facade/utilities.
The macro crate ends up as a separate package on `crates.io`.
It is conventional to call it `...-macros` or `...-derive`.

To write a proc_macro,
you will probably want to 
refer to the
[chapter in the Reference](https://doc.rust-lang.org/reference/procedural-macros.html)
and use some of these libraries:

  * [`syn`](https://docs.rs/syn/latest/syn/)
    for parsing a `TokenStream` into an AST.
  * [`proc-macro-error`](https://crates.io/crates/proc-macro-error)
    for providing pleasant error messages.
  * [`proc_macro2`](https://docs.rs/proc-macro2/1.0.29/proc_macro2/)
    to arrange that your main macro functionality
    can be tested outside of the rustc macro context.
  * [`quote`](https://docs.rs/quote/latest/quote/)
    for quasiquoting macro output.

proc_macros are entirely unhygienic.
In your macro output,
you must fully qualify the names of everything you use,
even things from std.
The [`Span`](https://docs.rs/proc-macro2/latest/proc_macro2/struct.Span.html)
of identifiers determines their hygiene context.


`build.rs`
----------

cargo supports running code at build-time,
by providing a file
[`build.rs`](https://doc.rust-lang.org/cargo/reference/build-scripts.html)
in the toplevel
containing appropriate functions.
This can run arbitrary code,
and includes the ability to generate `*.rs` files
to be included in the current crate build.

This is an awkward way to to organise build-time code generation,
because Rust is not an ideal language for writing build rules,
(although it can make a good language for generating Rust code).

`build.rs` can be the best choice
if you want very portable build-time code generation,
since it doesn't rely on anything but the Rust system
that you were depending on anyway.

[`TokenStream`]: file:///home/rustcargo/docs/share/doc/rust/html/proc_macro/struct.TokenStream.html
