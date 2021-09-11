Syntax
======

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Rust distinguishes items, statements, and expressions.
Control flow statements tend to require block expressions (`{ }`).

Also very important are patterns,
which are used for variable binding
and sum type matching.

Comments are usually `//` but `/*..*/` is also supported.

The top level of a module may contain only items.
In particular, `let` bindings are not permitted outside code blocks.

Generally, a redundant trailing `,` is allowed at the end of lists
(of values, arguments, etc.).
But `;` is *very significant* and is usually either required, or forbidden.

Attributes
----------

Rust code is frequently littered with [`#[attributes]`](https://doc.rust-lang.org/reference/attributes.html).
These are placed before the item or expression they apply to.
The semantics are very varied.
New attributes can be defined as procedural macros in libraries.

Notable is `#[derive(...)]` which invokes a macro
to autogenerate code based on a data structure type.
Many Rust libraries provide extremely useful derive macros
for structs and enums.

The syntax `#![attribute]` applies the attribute to
the thing the attribute is placed inside.
Typically it is found only at the top of a whole module or crate.

Attributes are used for many important purposes:

  * [Conditional compilation](https://doc.rust-lang.org/reference/conditional-compilation.html) `#[cfg(..)]`;
  * Denoting functions whose value should be checked
    (and types which should not be simply discarded):
    [`#[must_use]`][must_use];
  * [Suppressing warnings](https://doc.rust-lang.org/reference/attributes/diagnostics.html#lint-check-attributes) locally `#[allow(dead_code)]` or
    for a whole crate (at the toplevel) `#![allow(dead_code)]`;
  * Enabling [unstable features](https://doc.rust-lang.org/unstable-book/index.html) on Nightly
    `#![feature(exit_status_error)]`;
  * Marking functions as tests [`#[test]`](https://doc.rust-lang.org/reference/attributes/testing.html#the-test-attribute);
  * Request (hint) inlining `#[inline]`.
  * Control a type's [memory layout](https://doc.rust-lang.org/reference/type-layout.html) `#[repr(...)]`.
  * Specify where to find the source for a module
    `#[path="foo.rs"] mod bar;`.

Items
-----

[comment]: # ( This section uses a local Markdown extension:    )
[comment]: # ( the %!fancy-pre construct.  See fancy-pre.md.    )

%!fancy-pre
```
fn %function%(%arg0%: %T%, %arg1%: %U%) -> %ReturnValue% { %...% }
type %TypeAlias% = %OtherType%;         // Type alias, structural equality
pub struct %Counter% { %counter%: u64 } // Nominal type equality
trait %Trait% { fn %trait_method%(self); }
const %FORTY_TWO%: u32 = 42;
static %TABLE%: [u8; 256] = { 0x32, 0x26, 0o11, %entries...% };
impl %Type% { ... }
impl %Trait% for %Type% { ... }
mod %some_module%;                      // Causes `%some_module%.rs` to be read
mod %some_module% { ... }               // Module source is right here
```
%/fancy-pre

Expressions
-----------

Most of the usual infix and assignment operators are available.
Control flow "statements" are generally expressions:

%!fancy-pre
````
{ %stmt0%; %stmt1%; }  // With semicolon, has type `()`
{ %stmt0%; %stmt1% }   // No semicolon, has type of `%stmt1%`

if %condition% { %statements...% }                // Can only have type `()`
if %condition% { %value% } else { %other_value% }   // No `? :`, use this
if let %pattern% = %value% { %...% } %[%else %...%%]% // Pattern binding condition
match %value% { %pat0% %[% if %cond0% %]% => %expr0%, %...% } // See [Types and Patterns](types.md)

'%label%: loop { ... }   // %#.4:33mm `'%label%:` is optional of course
'%label%: while %condition% { }
'%label%: while let %pattern% = %expr% { }
'%label%: for loopvar in %something_iterable% { ... }

return %v%  // At end of function, it is idiomatic to just write `%v%`
break %value%; break '%label% %value%; // `loop` only; specifies value of `loop` expr
continue; continue '%label%; break; break '%label%;

%function%(%arg0%,%arg1%)
%receiver%.%method%(%arg0%,%arg1%,%arg2%)  // See [on Methods](traits.md#methods)
|%arg0%, %arg1%, %...%| %expression%  // %#.2 Closures
|%arg0%: %Type0%, %arg1%: %Type1%, %...%| -> %ReturnType% %expression%

%fallible%?                // See [in Error handling](errors.md#result--)
*%value%                   // [`Deref`], see [in Traits, methods](traits.md#deref-and-method-resolution)
%value% as %OtherType%      // Type conversion (safe but maybe lossy, see [in Safety](safety.md#integers-conversion-checking))
%Counter% { %counter%: 42 }  // Constructor ("struct literal")

%collection%[%index%]        // Usually panics if not found, eg array bounds check
%thing%.%field%              // Field of a struct with named fields
%tuple%.0; %tuple%.1;        // Fields of tuple or tuple struct
%start%..%end%; %start%..=%end%  // End-exclusive and -inclusive [`Range`]
```
%/fancy-pre

Note the odd semicolon rule,
which determines the type of block expressions.

Missing return type on a `fn` item means `()`;
missing return type on a closure means `_`;


Other statements
-----------------

`let` introduces a binding.
```
let pattern = value;
```

Variable names may be reused by rebinding;
this is often considered idiomatic.

In a block,
you can define any other kind of item,
which will have local scope.

Identifiers and scopes
----------------------

Names are
[paths](https://doc.rust-lang.org/reference/paths.html#types-of-paths)
like `scope::scope::ident`.

Here `scope` can be a module, type or trait,
or an external library ("crate"),
or special values like `crate`, `self`, `super`.

Each Rust module
(file, or `mod { }` within a file)
has its own namespace.
Other names are imported using `use path::to::thing;`.
`use` can also
[refer to other crates](https://doc.rust-lang.org/reference/names/preludes.html#extern-prelude) (i.e. your `Cargo.toml` dependencies).
Items can be renamed during import using `as`.

Rust has strong conventions about identifier case and spelling,
which the compiler will warn you about violating:

 * `snake_case`: Variables, functions and modules.
 * `StudlyCaps`: Types (including enum variant names and traits).
 * `SCREAMING_SNAKE_CASE`: Constants and global variables.

`-` is not valid in identifier names in Rust source code.
In other places in the Rust world,
you may see names in `kebab-case`.

Many items (including functions, types, fields of product types, etc.)
can be public (`pub`) or private to the module (the default),
or have [more subtle visibility](https://doc.rust-lang.org/reference/visibility-and-privacy.html).

`_` can often be written when an identifier is expected.
For a type or lifetime, it asks the compiler to infer.
For a binding, it discards the value (dropping it right away).
