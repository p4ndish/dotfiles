#!/bin/bash 

# Configuring NeoVim 
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -rf *.tar.gz 
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc 

git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
cp nvim-lazy ~/.config/nvim
#Finally:  don't forget to run :Lazy 




# Installing php, mysql, laravel, composer, npm
chmod +x bash_bin/*
cp -r bash_bin/* /usr/local/bin/

cp templates /opt/.
