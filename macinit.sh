#!/usr/bin/env bash

# macinit.sh
# Brandon Freitag, 2016
# Inspired by Lapwing Labs
# https://github.com/lapwinglabs/blog/blob/master/hacker-guide-to-setting-up-your-mac.md

{
  # get user options
  echo "Name: "
  read -e name
  echo "Email: "
  read -e email
  echo "GitHub username: "
  read -e username
  echo "GitHub password: "
  read -es password
  echo "ssh key name: "
  read -e keyname
  echo "Dotfiles repo path: "
  read -e dotfiles


  # install brew
  # check for Homebrew,
  # install if we don't have it
  if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # install binaries
  echo "Installing binaries..."
  binaries=(
    coreutils
    findutils
    bash
    bash-completion
    caskroom/cask/brew-cask
    ffmpeg
    git
    homebrew/dupes/grep
    htop
    irssi
    leiningen
    mongodb
    nmap
    python
    python3
    screenfetch
    tmux
    vim
  )
  brew update
  brew tap homebrew/dupes
  brew install ${binaries[@]}
  brew cleanup

  # install Apps
  echo "Installing apps..."
  apps=(
    dropbox
    evernote
    firefox
    google-chrome
    iterm2
    sketch
    skype
    slack
    spotify
    transmission
    vlc
  )
  brew cask install --appdir="/Applications" ${apps[@]}

  # setup git
  echo "Setting up git..."
  git config --global user.name "${name}"
  git config --global user.email "${email}"

  # generate ssh key
  echo "Generating ssh key..."
  ssh-keygen -t rsa -b 4096 -C "${email}"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa

  # add key to github
  echo "Adding ssh key to GitHub..."
  curl -u "${username}:${password}" --data '{"title":"${keyname}","key":"$(cat ~/.ssh/id_rsa.pub)"}' https://api.github.com/user/keys

  # clone repos
  echo "Cloning dotfiles repo..."
  git clone https://github.com/${dotfiles} ~/src/dotfiles

  # link the dotfiles
  echo "Linking dotfiles..."
  if [ -f ~/src/dotfiles/bash_aliases ]; then
    ln -s ../../.bash_aliases ~/src/dotfiles/bash_aliases
  fi
  if [ -f ~/src/dotfiles/bash_colors ]; then
    ln -s ../../.bash_colors ~/src/dotfiles/bash_colors
  fi
  if [ -f ~/src/dotfiles/bashrc ]; then
    ln -s ../../.bash_profile ~/src/dotfiles/bashrc
  fi
  if [ -f ~/src/dotfiles/gitconfig ]; then
    ln -s ../../.gitconfig ~/src/dotfiles/gitconfig
  fi
  if [ -f ~/src/dotfiles/gitignore ]; then
    ln -s ../../.gitignore ~/src/dotfiles/gitignore
  fi
  if [ -f ~/src/dotfiles/tmux.conf ]; then
    ln -s ../../.tmux.conf ~/src/dotfiles/tmux.conf
  fi
  if [ -f ~/src/dotfiles/vimrc ]; then
    ln -s ../../.vimrc ~/src/dotfiles/vimrc
  fi

  # setup vim
  echo "Setting up vim..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall

  # install nvm
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
  source ~/.bash_profile
  nvm install stable
  nvm use stable
  nvm alias default stable

  # cleanup
  unset name
  unset email
  unset username
  unset password
  unset dotfiles

  # done
  echo "Done."
}
