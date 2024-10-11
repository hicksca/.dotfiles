orbctlPath := /usr/local/bin/orbctl
machineName := nix-automation-test2
image := nixos:unstable
srcCodeDir := /Users/cah/code
srcConfigDir := /Users/cah/code/github.com/dotfiles/nix
vmCodeDir := /home/cah/code  
vmConfigDir := /etc/nixos

.PHONY: all createMachine removeMachine configureNixos

all: createMachine configureNixos

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

removeMachine:
	@if $(orbctlPath) list | grep -q "$(machineName)"; then \
		echo "Removing machine: $(machineName)..."; \
		$(orbctlPath) delete $(machineName) -f; \
		echo "Machine $(machineName) removed successfully."; \
	else \
		echo "Error: Machine $(machineName) does not exist."; \
	fi

configureNixos:
	@echo "Checking if /etc/nixos/configuration.nix exists in the VM..."
	$(orbctlPath) run -m $(machineName) sudo test -f $(vmConfigDir)/configuration.nix && \
                $(orbctlPath) run -m $(machineName) sudo mv $(vmConfigDir)/configuration.nix $(vmConfigDir)/configuration.nix.old || true
	@echo "Creating symlink for /Users/cah/code in the user's home directory on the VM..."
	$(orbctlPath) run -m $(machineName) sudo -u cah ln -sfn /Users/cah/code /home/cah/code
	@echo "Symlinking configuration files from $(srcConfigDir) to $(vmConfigDir)..."
	$(orbctlPath) run -m $(machineName) sudo ln -sfn $(srcConfigDir)/configuration.nix $(vmConfigDir)/configuration.nix
	$(orbctlPath) run -m $(machineName) sudo ln -sfn $(srcConfigDir)/global-apps.nix $(vmConfigDir)/global-apps.nix
	$(orbctlPath) run -m $(machineName) sudo ln -sfn $(srcConfigDir)/cah-home.nix $(vmConfigDir)/cah-home.nix
	@echo "Verifying symlinks..."
	$(orbctlPath) run -m $(machineName) ls -l $(vmConfigDir)
	$(orbctlPath) run -m $(machineName) ls -l /home/cah
	@echo "Applying NixOS configuration..."
	$(orbctlPath) run -m $(machineName) sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	$(orbctlPath) run -m $(machineName) sudo nix-channel --update
	$(orbctlPath) run -m $(machineName) sudo nixos-rebuild switch
	@echo "Starting Tailscale..."
	@read -p "Enter your Tailscale auth key: " AUTH_KEY; \
	$(orbctlPath) run -m $(machineName) sudo tailscale up --ssh --authkey=$$AUTH_KEY
	infocmp -x | ssh $(machineName)@orb -- tic -x -
	@echo "NixOS configuration completed."
	@echo "Verifying installation..."
	$(orbctlPath) run -m $(machineName) which zsh nvim tailscale

