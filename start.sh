#!/usr/bin/env bash
set -e

# ===========================
# 1. Install Neovim to /opt
# ===========================
if [[ ! -f ./nvim-linux-x86_64.tar.gz ]]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
fi

sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -f nvim-linux-x86_64.tar.gz

# ===========================
# 2. Add Neovim to PATH for the current user
# ===========================
SHELL_RC="$HOME/.bashrc"
if [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q '/opt/nvim-linux-x86_64/bin' "$SHELL_RC"; then
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> "$SHELL_RC"
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
fi

# ===========================
# 3. Configure Lazy.nvim
# ===========================
if [[ ! -d ~/.local/share/nvim/lazy/lazy.nvim ]]; then
    git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
fi

mkdir -p ~/.config/nvim
cp -r nvim/* ~/.config/nvim/


# Run Lazy setup
/opt/nvim-linux-x86_64/bin/nvim +Lazy! +qall


# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.20.0".

# Verify npm version:
npm -v # Should print "10.9.3".


# ===========================
# 4. Copy bash helper scripts and templates
# ===========================
chmod +x bash_bin/*
sudo cp -r bash_bin/* /usr/local/bin/
sudo cp -r templates /opt/.

# ===========================
# 5. Add mcd() helper function if not exists
# ===========================
if ! grep -q 'mcd()' "$SHELL_RC"; then
    cat >> "$SHELL_RC" <<'EOF'

mcd() {
    dir=$1
    mkdir -p "$dir" && cd "$dir"
}
EOF
fi

echo -e "\n✅ Neovim installation complete. Run 'nvim' to start."

