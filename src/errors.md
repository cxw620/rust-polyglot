Error handling
==============

[comment]: # ( Copyright 2021 Ian Jackson and contributors  )
[comment]: # ( SPDX-License-Identifier: MIT                 )
[comment]: # ( There is NO WARRANTY.                        )

Rust has two parallel runtime error handling mechanisms:
panics, and `Result` / `?`.

Do not use panics for anything except
unrecoverable discovery of a programming error
(eg, assertion failure).

[`Result`](https://doc.rust-lang.org/std/result/), `?`
-------------

Rust has exceptionally good in-language support for functions which
either return successfully,
or return an error (such as an error code).
This is the usual error handling style in Rust programs.

The core is this type in the standard library

```
    pub enum Result<T,E> { Ok(T), Err(E) }
```

and a postfix operator [`?`](https://doc.rust-lang.org/reference/expressions/operator-expr.html#the-question-mark-operator).
`?` applied to an `Ok` simply unwraps the inner success value `T`.
`?` applied to an `Err`
causes the containing function to return `Err(E)`
after converting the error `E`
to the containing function's error return type (using [`From`]).

An unfortunate downside is that all the returns
from a fallible function
must be written `Ok(r)` (or `return Ok(r)`).
One must write
`Ok(())` at the end of a function which would otherwise fall off the end
implicitly returning `()`.

The [`fehler`] macro library addresses this problem;
due to language limitations it is not perfect,
but even so it greatly improves the ergonomics.
(For some reason `crates.io` has failed to render
[fehler's `README.md`](https://github.com/withoutboats/fehler).)

The compiler will tell you if you forget to write a needed `?`.
(If you tried to use the return value for something,
it would have the wrong type;
in case you don't, `Result` is marked
[`#[must_use]`][must_use],
generating a warning.)

(`?` can also be used with [`Option`].)

In quick-and-dirty programs it is common to call
[`unwrap`](https://doc.rust-lang.org/nightly/std/result/enum.Result.html#method.unwrap)
(or [`expect`](https://doc.rust-lang.org/nightly/std/result/enum.Result.html#method.expect)), on a `Result`; these panic on errors.
But, the return type from `main` can be a suitable `Result`.
This,
plus use of `?` and a portmanteau error type like
[`eyre::Report`](https://docs.rs/eyre/latest/eyre/struct.Report.html),
is usually better even in a prototype because it avoids writing
`unwrap` calls that should be removed later
to make the code production-ready.


### Error types


The error type in a `Result` is generic.

The available and useful range of error types is
too extensive to discuss here.
But, consider:

 * [`eyre`] (or [`anyhow`])
   for a boxed portmanteau error type;
   good for application programs which need to
   aggregate many kinds of error.

 * [`thiserror`] for defining your own error enum;
   good when you're writing a library.

 * Defining your own unit struct as the error type
   for a specific function or scenario.  (Perhaps several such.)

 * [`std::io::Error`](https://doc.rust-lang.org/nightly/std/io/struct.Error.html) if you primarily need to report OS errors.

In a sophisticated program errors often start out
near the bottom of this list,
and are progressively wrapped/converted into types
nearer the top of the list.

Panic
-----

A panic is a synchronous unrecoverable failure of program execution,
similar in some respects to a C++ exception.

Panics can be caused explicitly by
[`panic!()`](https://doc.rust-lang.org/nightly/std/macro.panic.html),
[`assert!`](https://doc.rust-lang.org/nightly/std/macro.assert.html), etc.
The language will sometimes generate panics itself:
for example,
on arithmetic overflow in debug builds,
or array bounds violation.
There are no null pointer exceptions because
references are never null --- an optional reference is `Option<&T>`.

Libraries will sometimes generate panics,
in cases of serious trouble.
This should be documented, usually in an explicit `Panics` heading.

Typically panics produce a program crash with optional stack trace.
Depending on the compilation settings, panics can perhaps be caught
and recovered from,
which involves unwinding
including destroying the local variables in the unwound stack frames.

It is highly unidiomatic and inadvisable to use panics for
handling of expectedly exceptional cases
(eg, file not found).
The very highest quality libraries offer completely panic-free
versions of their functionality.
