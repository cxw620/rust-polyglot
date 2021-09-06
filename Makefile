# Copyright 2021 Ian Jackson and contributors
# SPDX-License-Identifier: MIT
# There is NO WARRANTY.

MDBOOK ?= mdbook
PANDOC ?= pandoc

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

PANDOC_INPUTS = $(addprefix pandoc/, $(addsuffix .md, $(CHAPTERS)))

default: doc

doc:	$(OUTPUT_INDEX)
	@echo 'Documentation can now be found here:'
	@echo '  file://$(abspath $<)'

$(OUTPUT_INDEX): book.toml mdbook/SUMMARY.md $(MD_SOURCES) $(MDBOOK_INFLUENCES)
	$(NAILING_CARGO_JUST_RUN) $(MDBOOK) build $(MDBOOK_BUILD_NAILING_OPTS)

mdbook/SUMMARY.md: generate-inputs src/gendefs.pl \
		$(MD_SOURCES) $(GIT_INFLUENCES)
	./$< $(CHAPTERS)

$(OUTPUT_PDF): mdbook/SUMMARY.md
	pandoc -o $@ $(PANDOC_INPUTS)

clean:
	$(NAILING_CARGO_JUST_RUN) rm -rf $(abspath $(OUTPUT_DIR))
	rm -rf mdbook pandoc
