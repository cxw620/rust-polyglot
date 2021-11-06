# Copyright 2021 Ian Jackson and contributors
# SPDX-License-Identifier: MIT
# There is NO WARRANTY.

MDBOOK ?= mdbook
PANDOC ?= pandoc

PDFLATEX = pdflatex
LATEX_OPTIONS = --interaction=batchmode

CHAPTERS := 	intro syntax types ownership traits safety 		\
		errors macros async ffi rustdoc stability cargo 	\
		libs colophon

ifneq (,$(wildcard ../Cargo.nail))

NAILING_CARGO ?= nailing-cargo
CARGO ?= $(NAILING_CARGO)
BUILD_SUBDIR ?= ../Build
OUTPUT_DIR = $(BUILD_SUBDIR)/$(notdir $(PWD))/html
NAILING_CARGO_JUST_RUN ?= $(NAILING_CARGO) --just-run -q ---
MDBOOK_BUILD_NAILING_OPTS ?= -d $(OUTPUT_DIR) $(PWD)

endif # Cargo.nail

CARGO ?= cargo
OUTPUT_DIR ?= html

OUTPUT_PDF = polyglot.pdf

MD_SOURCES := $(addprefix src/, $(addsuffix .md, $(CHAPTERS)))
GIT_INFLUENCES := $(widlcard .git/HEAD .git/packed-refs) \
		$(wildcard .git/$(git symbolic-ref HEAD 2>/dev/null))
MDBOOK_INFLUENCES := $(shell find theme -type f -name '[a-z]*.*[^~]')

ifneq (,$(shell $(PANDOC) --help 2>&1 | egrep '^  *--chapters\b'))
PANDOC_CHAPTERS_OPTION = --chapters
else
PANDOC_CHAPTERS_OPTION = --top-level-division=chapter
endif

default: doc

doc:	html

html:	html.stamp
	@echo 'Documentation can now be found here:'
	@echo '  file://$(abspath $(OUTPUT_DIR)/index.html)'

pdf:	$(OUTPUT_PDF)

.PHONY: html pdf

html.stamp: book.toml mdbook/SUMMARY.md mdbook/conversions-table.html \
	massage-html \
		$(MD_SOURCES) $(MDBOOK_INFLUENCES)
	$(NAILING_CARGO_JUST_RUN) $(MDBOOK) build $(MDBOOK_BUILD_NAILING_OPTS)
	$(NAILING_CARGO_JUST_RUN) $(abspath massage-html) \
		$(addprefix html/, $(addsuffix .html, print $(CHAPTERS)))
	touch $@

mdbook/conversions-table.html: conversions-table
	./$< html >$@.tmp && mv -f $@.tmp $@

mdbook/SUMMARY.md: generate-inputs src/definitions.pl src/precontents.md \
		$(MD_SOURCES) $(GIT_INFLUENCES)
	./$< $(CHAPTERS)

latex/polyglot.tex:
	mkdir -p latex/
	ln -sf ../src/polyglot.tex latex/

TEX_INPUTS = $(foreach c,$(CHAPTERS) precontents,latex/$c.tex)
$(TEX_INPUTS): latex/%.tex: src/refs.md mdbook/SUMMARY.md hack-latex
	mkdir -p latex/
	$(PANDOC) $(PANDOC_CHAPTERS_OPTION) --columns=132 -tlatex -o$@.raw \
		$< pandoc/$*.md mdbook/autorefs.md
	./hack-latex $@.raw >$@

$(OUTPUT_PDF): $(TEX_INPUTS) latex/polyglot.tex latex/conversions-table.tex
	cd latex && \
		{ $(PDFLATEX) $(LATEX_OPTIONS) polyglot.tex && \
		  $(PDFLATEX) $(LATEX_OPTIONS) polyglot.tex && \
		  $(PDFLATEX) $(LATEX_OPTIONS) polyglot.tex || \
			{ cat polyglot.log; false; }; } && \
		mv polyglot.pdf ../

latex/conversions-table.tex: conversions-table
	./$< tex >$@.tmp && mv -f $@.tmp $@

clean:
	$(NAILING_CARGO_JUST_RUN) rm -rf $(abspath $(OUTPUT_DIR))
	rm -rf latex mdbook pandoc *.stamp
