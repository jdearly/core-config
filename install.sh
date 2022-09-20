#!/bin/bash
echo Upgrading and installing ansible and git
sudo dnf upgrade && sudo dnf autoremove && sudo dnf install ansible git
echo Configuring git locally..
read -p 'Github user: ' gituser
read -p 'Github email: ' gitemail
git config --global user.email "$gitemail"
git config --global user.name "$gituser"
echo Setting up SSH key, using github email
ssh-keygen -t ed25519 -C "$gitemail"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo Copy and add new public key to github
cat ~/.ssh/id_ed25519.pub
echo PRESS ANY KEY TO CONTINUE SETUP
read -n 1 -s
echo Pulling ansible config
ansible-pull -U https://github.com/jdearly/core-config.git
