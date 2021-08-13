Safety
======


Integers, conversion, checking
------------------------------

Arithmetic in Rust is always safe (so no UB).
However, in release builds, by default, integer overflow is not checked.
If you want to be extra careful you can use ``checked_*`` variants
of the arithmetic functions.

Conversions between numeric scalars are a little fraught.
``as`` is possibly lossy, and might panic (eg if a narrowing cast fails).
I avoid it.

I advise using the ``Into`` and ``TryInto`` implementations in the
``num_traits`` crate.

