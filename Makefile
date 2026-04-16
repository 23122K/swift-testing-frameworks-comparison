.DEFAULT_GOAL := build

SWIFT ?= swift
PACKAGE_DIR := Testbench
PRODUCT := Testbench
BINARY := $(PACKAGE_DIR)/.build/release/$(PRODUCT)
INSTALL_DIR := $(HOME)/.local/bin

.PHONY: build remove

build:
	$(SWIFT) build --package-path $(PACKAGE_DIR) -c release
	mkdir -p $(INSTALL_DIR)
	ln -sf $(CURDIR)/$(BINARY) $(INSTALL_DIR)/$(PRODUCT)
	@if ! echo "$$PATH" | tr ':' '\n' | grep -qx "$(INSTALL_DIR)"; then \
		echo 'export PATH="$$HOME/.local/bin:$$PATH"' >> $(HOME)/.zshrc; \
		echo "Added $(INSTALL_DIR) to PATH in ~/.zshrc — restart your shell or run: source ~/.zshrc"; \
	fi
	$(INSTALL_DIR)/$(PRODUCT) --set-path $(CURDIR)

remove:
	@STORED_PATH=$$($(INSTALL_DIR)/$(PRODUCT) results --show-path) && \
		echo "Removing $$STORED_PATH" && \
		rm -rf "$$STORED_PATH" && \
		rm -f $(INSTALL_DIR)/$(PRODUCT) && \
		echo "Removed $$STORED_PATH and $(INSTALL_DIR)/$(PRODUCT)"
