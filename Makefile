.DEFAULT_GOAL := run

SWIFT ?= swift
PACKAGE_DIR := Testbench
PRODUCT := Testbench
BINARY := $(PACKAGE_DIR)/.build/release/$(PRODUCT)

.PHONY: build run

build:
	$(SWIFT) build --package-path $(PACKAGE_DIR) -c release

run: build
	$(BINARY) xctest
