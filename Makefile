# Copyright 2021 Ian Jackson and contributors
# SPDX-License-Identifier: MIT
# There is NO WARRANTY.

MDBOOK ?= mdbook
PANDOC ?= pandoc

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

MD_SOURCES := $(wildcard src/*[^A-Z].md)
GIT_INFLUENCES := $(widlcard .git/HEAD .git/packed-refs) \
		$(wildcard .git/$(git symbolic-ref HEAD 2>/dev/null))

CHAPTERS := 	intro syntax types ownership traits safety 		\
		errors macros async ffi rustdoc stability cargo 	\
		libs colophon

default: doc

doc:	$(OUTPUT_INDEX)
	@echo 'Documentation can now be found here:'
	@echo '  file://$(abspath $<)'

$(OUTPUT_INDEX): book.toml mdbook/SUMMARY.md $(MD_SOURCES)
	$(NAILING_CARGO_JUST_RUN) $(MDBOOK) build $(MDBOOK_BUILD_NAILING_OPTS)

mdbook/SUMMARY.md: regenerate-inputs $(MD_SOURCES) $(GIT_INFLUENCES)
	./$< $(CHAPTERS)

$(OUTPUT_PDF):
	pandoc -o $@ $(addprefix src/, $(addsuffix .md, $(CHAPTERS)))

clean:
	$(NAILING_CARGO_JUST_RUN) rm -rf $(abspath $(OUTPUT_DIR))
