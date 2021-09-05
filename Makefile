# Copyright 2021 Ian Jackson and contributors
# SPDX-License-Identifier: MIT
# There is NO WARRANTY.

MDBOOK ?= mdbook

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

default: doc

doc:	$(OUTPUT_INDEX)
	@echo 'Documentation can now be found here:'
	@echo '  file://$(abspath $<)'

$(OUTPUT_INDEX): book.toml $(wildcard docs/*.md)
	$(NAILING_CARGO_JUST_RUN) $(MDBOOK) build $(MDBOOK_BUILD_NAILING_OPTS)
