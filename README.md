# Ahmed's dotfiles with auto setup script
- It contains all my dotfiles under /stow/
- It is not for general use. Heavily personal setup and opinionated. Backup your stuff if you trying it.

![Screenshot From 2024-10-22 18-34-11](https://github.com/user-attachments/assets/1af2c33f-3f20-4fe4-bcff-661846b50618)

## Things each option does : 
1. Detects package manager tweaks some stuff and then installs these packages `git fzf wget make gcc unzip openssh-clients openssl stow ripgrep fd-find fontconfig tldr fastfetch`
2. Sets up Github with SSH authintication. Its hardcoded for my email right now. Skip these if you are not me.
3. Clones this repo to ~/
4. Sets up dotfiles for all packages. Uses [GNU/Stow](https://www.gnu.org/software/stow/stow.html) to symlink them. Sets up my personal `bash`, `zsh`, `neovim`, `wezterm` configs.
5. Installs my needed of fonts. You can choose which font to install.
6. Installs [NVM](https://github.com/nvm-sh/nvm)
7. Installs Nirmala UI ( Windows's Bangla font ) and sets it the default Bangla font in the system.
8. Cleans up any downloads done during setup
9. Do everything above sequntially
10. Refresh and restarts the script
11. Exits

