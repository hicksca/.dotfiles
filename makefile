# Makefile to create a NixOS machine in Orbstack

# Variables
ORBCTL_PATH := /usr/local/bin/orbctl
MACHINE_NAME := nix-automation-test
IMAGE := nixos:unstable


.PHONY: all check_platform check_orbstack create_machine

all: check_platform check_orbstack create_machine

check_platform:
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Running on macOS."; \
	else \
		echo "Error: This script is intended to run on macOS only."; \
		exit 1; \
	fi

check_orbstack:
	@if [ -x "$(ORBCTL_PATH)" ]; then \
		echo "Orbstack is installed."; \
	else \
		echo "Error: Orbstack (orbctl) is not installed."; \
		exit 1; \
	fi

create_machine:
	@if $(ORBCTL_PATH) list | grep -q "$(MACHINE_NAME)"; then \
		echo "Error: Machine $(MACHINE_NAME) already exists."; \
		exit 1; \
	else \
		echo "Creating NixOS machine: $(MACHINE_NAME)..."; \
		$(ORBCTL_PATH) create $(IMAGE) $(MACHINE_NAME); \
		echo "Machine $(MACHINE_NAME) created successfully."; \
	fi

remove_machine:
	@if $(ORBCTL_PATH) list | grep -q "$(MACHINE_NAME)"; then \
		echo "Removing machine: $(MACHINE_NAME)..."; \
		$(ORBCTL_PATH) delete $(MACHINE_NAME) -f; \
		echo "Machine $(MACHINE_NAME) removed successfully."; \
	else \
		echo "Error: Machine $(MACHINE_NAME) does not exist."; \
	fi
