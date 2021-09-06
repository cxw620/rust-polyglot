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

OUTPUT_INDEX = $(OUTPUT_DIR)/index.html
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

html:	$(OUTPUT_INDEX)
	@echo 'Documentation can now be found here:'
	@echo '  file://$(abspath $<)'

pdf:	$(OUTPUT_PDF)

.PHONY: html pdf

$(OUTPUT_INDEX): book.toml mdbook/SUMMARY.md $(MD_SOURCES) $(MDBOOK_INFLUENCES)
	$(NAILING_CARGO_JUST_RUN) $(MDBOOK) build $(MDBOOK_BUILD_NAILING_OPTS)

mdbook/SUMMARY.md: generate-inputs src/gendefs.pl \
		$(MD_SOURCES) $(GIT_INFLUENCES)
	./$< $(CHAPTERS)

latex/polyglot.tex:
	mkdir -p latex/
	ln -sf ../src/polyglot.tex latex/

TEX_INPUTS = $(foreach c,$(CHAPTERS),latex/$c.tex)
$(TEX_INPUTS): latex/%.tex: src/refs.md mdbook/SUMMARY.md
	mkdir -p latex/
	pandoc $(PANDOC_CHAPTERS_OPTION) --columns=132 -o$@ $< src/$*.md mdbook/autorefs.md

$(OUTPUT_PDF): $(TEX_INPUTS) latex/polyglot.tex
	cd latex && \
		$(PDFLATEX) $(LATEX_OPTIONS) polyglot.tex && \
		$(PDFLATEX) $(LATEX_OPTIONS) polyglot.tex && \
		$(PDFLATEX) $(LATEX_OPTIONS) polyglot.tex && \
		mv polyglot.pdf ../

clean:
	$(NAILING_CARGO_JUST_RUN) rm -rf $(abspath $(OUTPUT_DIR))
	rm -rf latex mdbook pandoc
