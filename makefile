orbctlPath := /usr/local/bin/orbctl
machineName := nix-automation-test
image := nixos:unstable
srcCodeDir := /Users/cah/code
srcConfigDir := /Users/cah/code/github.com/dotfiles/nix
vmCodeDir := /home/cah/code  # Symlink will be created in the user's home directory
vmConfigDir := /etc/nixos

.PHONY: all createMachine removeMachine configureNixos

all: createMachine configureNixos

# Combine platform check, Orbstack check, and machine creation
createMachine:
	@if [ "$$(uname)" != "Darwin" ]; then \
		echo "Error: This script is intended to run on macOS only."; \
		exit 1; \
	fi
	@if command -v $(orbctlPath) >/dev/null 2>&1; then \
		echo "Orbstack is installed."; \
	else \
		echo "Error: Orbstack (orbctl) is not installed."; \
		exit 1; \
	fi
	@if $(orbctlPath) list | grep -q "$(machineName)"; then \
		echo "Error: Machine $(machineName) already exists."; \
		exit 1; \
	else \
		echo "Creating NixOS machine: $(machineName)..."; \
		$(orbctlPath) create $(image) $(machineName); \
		echo "Machine $(machineName) created successfully."; \
	fi

# Remove the machine
removeMachine:
	@if $(orbctlPath) list | grep -q "$(machineName)"; then \
		echo "Removing machine: $(machineName)..."; \
		$(orbctlPath) delete $(machineName) -f; \
		echo "Machine $(machineName) removed successfully."; \
	else \
		echo "Error: Machine $(machineName) does not exist."; \
	fi

# Configure NixOS by symlinking and running setup commands
configureNixos:
	@echo "Checking if /etc/nixos/configuration.nix exists in the VM..."
	$(orbctlPath) run sudo test -f $(vmConfigDir)/configuration.nix && \
		$(orbctlPath) run sudo mv $(vmConfigDir)/configuration.nix $(vmConfigDir)/configuration.nix.old || true
	@echo "Creating symlink for /Users/cah/code/ in the user's home directory on the VM..."
	$(orbctlPath) run sudo ln -sf $(srcCodeDir) $(vmCodeDir)
	@echo "Symlinking configuration files from $(srcConfigDir) to $(vmConfigDir)..."
	$(orbctlPath) run sudo ln -sf $(srcConfigDir)/configuration.nix $(vmConfigDir)/configuration.nix
	$(orbctlPath) run sudo ln -sf $(srcConfigDir)/global-apps.nix $(vmConfigDir)/global-apps.nix
	$(orbctlPath) run sudo ln -sf $(srcConfigDir)/cah-home.nix $(vmConfigDir)/cah-home.nix
	@echo "Applying NixOS configuration..."
	$(orbctlPath) run sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	$(orbctlPath) run sudo nix-channel --update
	$(orbctlPath) run sudo nixos-rebuild switch
	infocmp -x | ssh $(machineName)@orb -- tic -x -
	@echo "NixOS configuration completed."

