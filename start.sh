#!/bin/bash 

# Configuring NeoVim 
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -rf *.tar.gz 
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc 

git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
#Finally:  don't forget to run :Lazy 




# Installing php, mysql, laravel, composer, npm
chmod +x bash_bin/*
chmod +x bash_bin/bin/*
./bash_bin/php_installer 
./bash_bin/python_installer 
./bash_bin/tmux_installer 

sudo cp bash_bin/bin/* /bin/. 

