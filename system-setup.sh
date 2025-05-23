#/bin/sh

echo "==============================================Performing updates=============================================="
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Press Enter to continue..."
read dummy

echo "==============================================Installing packages============================================="
xargs -a packages.txt sudo apt-get install -y

echo "Press Enter to continue..."
read dummy

echo "==============================================Copying dotfiles============================================="
cp zshrc/* ~
cp vimrc/* ~

echo "Press Enter to continue..."
read dummy

echo "==============================================Installing oh-my-zsh============================================="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Cloning oh-my-zsh with plugins"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	rm $HOME/.zshrc
	mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc

	# Plugins
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions	
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
else
	echo "oh-my-zsh already cloned, assuming its properly installed"
fi

echo "Press Enter to continue..."
read dummy

echo "==============================================Installing lazygit============================================="
if command -v lazygit &> /dev/null; then
	echo "Lazygit is already installed"
else
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit -D -t /usr/local/bin/
	rm lazygit*
fi

echo "Press Enter to continue..."
read dummy

echo "==============================================Git config============================================="
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global push.default current

# Submodule sorcery: https://github.com/vaul-ulaval/vaul-wiki/wiki/Utilisation-des-submodules
git config --global diff.submodule log # Après un git diff, affiche aussi les nouveaux commits des submodules
git config --global status.submodulesummary true # Après un git status, affiche un résumé des commits des submodules
git config --global submodule.recurse true # Fais en sorte que toutes les commandes git (sauf clone), auront le flag --recurse-submodules
git config --global push.recurseSubmodules on-demand # S'assure qu'on ne puisse pas pousser des changements sans que les submodules soient eux aussi poussés
git config --global alias.sdiff '!'"git diff && git submodule foreach 'git diff'" # Ajout de la commande 'git sdiff' pour voir un diff de chaque submodule
git config --global alias.supdate '!'"git submodule update --remote --merge" # Ajout de la commande 'git supdate' pour l'update de submodules

echo "Press Enter to continue..."
read dummy

echo "==============================================Setting default shell============================================"
chsh -s $(which zsh)

echo "Now restart restart your computer!"
