#!/bin/bash 

# Configuring NeoVim 
if ! [[ -f ./nvim-linux-x86_64.tar.gz ]]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    
fi
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -rf *.tar.gz 

if [[ -f ~/.bashrc ]]; then
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.bashrc; then
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
    fi
elif [[ -f ~/.zshrc ]]; then
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.zshrc; then
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.zshrc
    fi
fi

if [[ ! -d ~/.local/share/nvim/lazy/lazy.nvim ]]; then
    git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
fi
cp -r nvim ~/.config/nvim


#Finally:  don't forget to run :Lazy 
nvim +Lazy +qall




# Installing php, mysql, laravel, composer, npm
chmod +x bash_bin/*
sudo cp -r bash_bin/* /usr/local/bin/

cp -r  templates /opt/.


# copying some bash commands to .rc files 
# determine the os 
if [[ -f ~/.bashrc ]]; then
    rcfile=~/.bashrc
elif [[ -f ~/.zshrc ]]; then
    rcfile=~/.zshrc
else
    rcfile=~/.bashrc   # fallback
fi

if ! grep -q 'mcd()' "$rcfile"; then
    cat >> "$rcfile" <<'EOF'
mcd() {
    dir=$1
    mkdir -p "$dir" && cd "$dir"
}
EOF
fi

