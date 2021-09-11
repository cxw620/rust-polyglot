fancy-pre markdown extension
============================

Some parts of `syntax.md` use a special extension, `fancy-pre`.

Syntax and semantics
--------------------

A fancy-pre block looks like this:

```
    %!fancy-pre
    ```
    content
    ```
    %/fancy-pre
```

The content is, broadly speaking, a code block.  But it is subject to
special formatting rules.

 * Within the code block, markdown escapes *are* rendered.  But the
   code *is* set in a fixed-width font.  Don't use backquotes within
   it (except after the `//`, in a note).

 * A `//` comment causes special rendering.  Everything after it is a
   note for the code which precedes the `//`.  The note is set as
   normal body text.  Ie, not fixed width.  In the note, you can
   use ` ` normally.

 * Within the whole of the fancy-pre (in code or in notes), `%...%`
   can be used to indicate a metasyntactic variable.  (`<var>` in HTML
   terms; it is rendered in italics)  The `%`s can contain precisely
   one of the following:
     - text matching `\w*\.*`:
       An optional identifier followed by optional ellipsis.
     - `[` or `]`:
       Optional parts of syntactic productions/examples should use
       `%[%` and `%]%`.

 * The special directive `%#.`_`N`_ or `%#.`_`N`_`:`_`TEXDIM`_, at the
   start of a note, indicates that the note applies to `N` rows,
   starting with the current one.  (`N` is an integer.)  `TEXDIM` (a
   TeX dimension specified as a factor followed by one of a limited
   set of units) forces the note column to be rendered in the PDF at
   that width, rather than its natural width.

 * If it is necessary to escape a literal `%`, say `%%`.

 * Blank lines still make paragraphs.  But they also make blocks:
   all the notes in a single block will be aligned.

Implementation
--------------

This is implemented by `generate-inputs`, a bespoke preprocessor which
generates both input for `mdbook` and `pandoc`, from the files in
`src/`.

A crazy scheme is used to smuggle HTML into mdbook's output, and TeX
into pandoc's output; the smuggled directives are translated into real
ones by `massage-html` and `hack-latex`.
