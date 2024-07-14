z ..
rm -rf Shows
z conf
z ~/.config/
z alacritty
ls
nvim alacritty.toml 
exit
zellij list
zellij list-session
zellij ls
zellij attach blossoming-cactus
zellij attach 
zellij attach cubic-piano
zellij 
zellij 
sudo nala update
ls
zellij 
sudo nala search gnome-shell-pomodoro
sudo nala install gnome-shell-pomodoro
z Documents/
ls
mkdir downloads
cd downloads/
sudo nala remove yt-dlp 
sudo nala install python3-pip
pip install yt-dlp
yt-dlp https://youtu.be/yBw67Fb31Cs
ping 1.1.1.1
mv .profile .profile.bak
sudo reboot
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
ssh -T git@github.com
sudo nala update -y
sudo dnf update -y
sudo dnf install neovim
sudo nvim V
sudo nvim /etc/environment
/sbin/lspci | grep -e VGA
sudo dnf install xorg-x11-drv-nvidia-470xx akmod-nvidia-470xx
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install xclip openssl
sudo nvim /etc/systemd/resolved.conf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
sudo nvim /etc/systemd/resolved.conf
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install xclip openssl
sudo nvim /etc/systemd/resolved.conf
sudo nvim /etc/systemd/resolved.conf
cd Downloads/
l
sudo cp zellij /usr/local/bin/
ls
ll
cd ..
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
sudo dnf install zoxide
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser
sudo dnf install adw-gtk3
sudo dnf search adw-gtk3
sudo dnf search adw-gtk3-theme
sudo dnf install adw-gtk3-theme
rm -rf .ssh/
ssh-keygen -t ed25519 -C "nasif2ahmed@gmail.com"
cat ~/.ssh/id_ed25519.pub
cat ~/.ssh/id_ed25519.pub | xclip 
cat ~/.ssh/id_ed25519.pub | xclip -i 
xclip -h
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
sudo dnf install syncthing
sudo systemctl enable syncthing@ahmed.service
sudo systemctl start syncthing@ahmed.service
sudo dnf search appimage
dnf search lazygit
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
dot
lazygit 
git add *
git commit -m "refresh"
git push
git staus
git status
nvim .gitignore 
git add *
git commit -m "update"
git push
lazygit 
sudo dnf install mpv
sudo dnf copr enable travrei/Zed-Git
sudo dnf install zed
ls
z Desktop/
ls
zed
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf check-update
sudo dnf install code # or code-insiders
ls
sudo dnf install neofetch
exit
nvim
sudo dnf copr search zed
sudo rpm --import 'https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/gpg.F8756541ADDA2B7D.key'
sudo dnf config-manager --add-repo https://repos.fedarovich.com/fedora/37/qbittorrent-cli.repo
sudo dnf config-manager --add-repo remove https://repos.fedarovich.com/fedora/37/qbittorrent-cli.repo
sudo dnf config-manager --remove-repo https://repos.fedarovich.com/fedora/37/qbittorrent-cli.repo
z /etc/yum.repos.d/
ls
rm qbittorrent-cli.repo 
sudo rm qbittorrent-cli.repo 
ll
dnf search qbittorrent
sudo dnf install qbittorrent-nox
qbittorrent-nox 
sudo nvim /etc/systemd/system/qbittorrent-nox.service
sudo systemctl daemon-reload
sudo adduser --system --group qbittorrent-nox
sudo groupadd qbittorrent-nox
sudo adduser --system --group qbittorrent-nox
z ~
sudo groupadd qbittorrent-nox
sudo adduser --system --group qbittorrent-nox
sudo adduser --system --gid qbittorrent-nox
sudo adduser --system --no-create-home --group qbittorrent-nox
grep qbittorrent-nox /etc/group
sudo systemctl start qbittorrent-nox.service
sudo systemctl status qbittorrent-nox.service
sudo rm /etc/systemd/system/qbittorrent-nox.service
sudo systemctl daemon-reload
sudo systemctl start qbittorrent-nox@ahmed.service
sudo systemctl status qbittorrent-nox@ahmed.service
sudo systemctl enable qbittorrent-nox@ahmed.service
z .config/mpv/
ls
nvim mpv.
nvim mpv.conf 
mpv https://www.youtube.com/watch?v=9JYFMMNYz60
sudo dnf install vlc
sudo nvim sudo nano /etc/X11/xorg.conf.d/20-nvidia.conf
sudo nvim /etc/X11/xorg.conf.d/20-nvidia.conf
ll
rm sudo 
ls
file /etc/X11/xorg.conf.d/20-nvidia.conf 
cat /etc/X11/xorg.conf.d/20-nvidia.conf 
sudo systemctl restart gdm.service    # for GNOME
mpv /mnt/hdd/Videos/Movies/The.Killing.Of.A.Sacred.Deer.1080p.BluRay.x265.HEVC.6CH-MRN.mkv 
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force 
sudo fwupdmgr get-updates 
sudo fwupdmgr update
sudo dnf groupupdate 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --env=GTK_THEME=my-theme
z mpv
nvim mpv.conf 
mpv /mnt/hdd/Videos/Movies/The Nice Guys 2016 BluRay 1080p Hindi 2.0 English 5.1 AC3 x264 ESub - mkvCinemas.mkv 
"mpv /mnt/hdd/Videos/Movies/The Nice Guys 2016 BluRay 1080p Hindi 2.0 English 5.1 AC3 x264 ESub - mkvCinemas.mkv"
mpv "/mnt/hdd/Videos/Movies/The Nice Guys 2016 BluRay 1080p Hindi 2.0 English 5.1 AC3 x264 ESub - mkvCinemas.mkv"
sudo nvim /etc/X11/xorg.conf.d/20-nvidia.conf
sudo systemctl restart gdm.service    # for GNOME
sudo nvim /etc/X11/xorg.conf.d/20-nvidia.conf
mpv https://youtu.be/pMX2cQdPubk
mpv --ytdl-format="best[height<=1080]"  https://www.youtube.com/channel/UCBJycsmduvYEL83R_U4JriQ
mpv --ytdl-format="best[height<=1080]" https://youtu.be/pMX2cQdPubk
mpv /mnt/hdd/Videos/Movies/The.Northman.2022.1080p.AMZN.WEB-DL.DDP5.1.H.264-CMRG.mkv 
mpv --ytdl-format="best[height=1080]" https://youtu.be/pMX2cQdPubk
yt-dlp -F https://youtu.be/pMX2cQdPubk
mpv --ytdl-format=137 https://youtu.be/pMX2cQdPubk
mpv --ytdl-format=248 https://youtu.be/pMX2cQdPubk
sudo dnf install jq 
sudo dnf install curl
z down
git clone https://github.com/pystardust/ytfzf
cd ytfzf/
sudo make install
ytfzf 
yt-dlp -F https://youtu.be/pMX2cQdPubk
mpv --ytdl-format=240 https://youtu.be/pMX2cQdPubk
mpv --ytdl-format=270 https://youtu.be/pMX2cQdPubk
mpv --ytdl-format=614 https://youtu.be/pMX2cQdPubk
mpv --ytdl-format=248 https://youtu.be/pMX2cQdPubk
mpv --ytdl-format=270+140 https://youtu.be/pMX2cQdPubk
yt-dlp -F https://youtu.be/pcSv22DTDUI
mpv --ytdl-format=312+251 https://youtu.be/pcSv22DTDUI
mpv --ytdl-format=299 https://youtu.be/pcSv22DTDUI
ls
free -h
z down
cd pfetch/
sudo make install
nvim .bashrc 
ls
nvim .bashrc 
ls
ll
sudo flatpak override --reset --filesystem=$HOME/.themes
sudo flatpak override --reset --env=GTK_THEME
zed
sudo dnf install gnome-pomodoro
ifnet
ip
ifconfig \
ifconfig 
sudo dnf update
z /etc/yum.repos.d/
ll
rm home_ahmed_remove.repo 
sudo rm home_ahmed_remove.repo 
ll
sudo dnf update
dnf search nvidia-smi
pip
z ~
dnf search pip
sudo dnf install python3-pip
z Desktop/
nvim chan_downloader.py
pip install requests beautifulsoup4
nvim chan_downloader.py 
ll
nvim chan_downloader.py 
python3 chan_downloader.py 
rm -rf 4chan_images/
nvim chan_downloader.py 
python3 chan_downloader.py 
ls
cd 4chan_images/
ls
ll
cd ..
python3 chan_downloader.py 
nvim chan_downloader.py 
python3 chan_downloader.py 
nvim chan_downloader.py 
python3 chan_downloader.py 
nvim chan_downloader.py 
python3 chan_downloader.py 
nvim chan_downloader.py 
python3 chan_downloader.py 
sudo dnf install gthumb
z ~
nvim .bashrc 
man ls
nvim .bashrc 
exit
man ls
exit
man ls
nvim .bashrc 
exit
source ~/.bashrc
exit
nvim .bashrc 
man df
nvim .bashrc 
man df
nvim .bashrc 
ls
nvim .bashrc
exit
man ls
nvim .bashrc
exit
man ls
rm -rf .bashrc
mv .bashrc.main .bashrc
ls
ll
sudo dnf install fastfetch
fastfetch
sudo dnf install zsh
nvim .zshrc
zsh
exit
zsh
exit
zellij 
chsh
man ls
mv .bashrc .bashrc.main
zsh
which zsh
chsh
nvim .bashrc 
curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
z ~/.config/alacritty/
ls
nvim alacritty.toml 
ls
zsh
ls
exit
man ls
ls
dot
which bash
chsh
nvim ~/.config/alacritty/
ls
ls --color
man ls
exit
ls
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm
exit
ls --color
man ls
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm
nvm install node
cd Downloads/
git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
sudo dnf install -y gcc make git ripgrep fd-find unzip neovim
nvim
cd ~/.config/
cd nvim/
ls
rm -rf .git
nvim init.lua 
nvim ~/.bashrc 
exit
nvim ~/.config/nvim/init.lua 
exit
l
ls
ll
nvim .zshrc 
exit
nvim ~/.bashrc 
exit
ls
sudo dnf history
sudo dnf distro-sync 
ls
nvim ~/.config/alacritty/
exit
ls
nvim ~/.config/alacritty/
exit
ls
fastfetch 
exit
lsblk
sudo nvim /etc/fstab 
lsblk
ntfsfix /dev/sdb
ntfsfix /dev/sdb2
sudo ntfsfix /dev/sdb
chkdsk /dev/sdb
dnf search chkdsk
sudo fsck.ext4 /dev/sda
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install jellyfin
sudo systemctl enable --now jellyfin
sudo systemctl start jellyfin
sudo systemctl status jellyfin
sudo chown -R jellyfin:jellyfin /mnt/collection/main
sudo chmod -R 755 /mnt/collection/main
CD /mnt/collection/
cd /mnt/collection/
ll
cd main/
ll
ionice 
dnf search iotop
sudo dnf install iotop -y
iotop 
sudo systemctl stop qbittorrent-nox@ahmed.service
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/Videos/Movies/ /mnt/collection/main/movies/
journalctl -u jellyfin -f
cd /mnt/
ls
cd collection/
ls
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/Videos/Series/ /mnt/collection/main/shows/
cd main/
ll
cd movies/
ll
cd ..
ll
sudo chown -R jellyfin:jellyfin /mnt/collection/main/movies/
sudo chmod -R 755 /mnt/collection/main/movies/
cd movies/
ll
sudo systemctl stop jellyfin
sudo systemctl start jellyfin
journalctl -u jellyfin -f
df -h | grep /mnt/collection
cd ..
ll
sudo setenforce 0
sudo systemctl restart jellyfin
journalctl -u jellyfin -f
sudo sestatus
sudo dnf install policycoreutils-python-utils
sudo semanage fcontext -a -t media_t "/mnt/collection(/.*)?"
sudo semanage fcontext -a -t public_content_rw_t "/mnt/collection(/.*)?"
sudo restorecon -Rv /mnt/collection
ls -Z /mnt
sudo dnf install policycoreutils-python-utils
sudo ausearch -c 'jellyfin' --raw | audit2allow -M jellyfin_custom
sudo semodule -i jellyfin_custom.pp
sudo ausearch -c 'jellyfin' --raw | audit2allow -M jellyfin_custom
sudo setenforce 0
sudo sestatus
sudo setenforce 0
sudo sestatus
sudo systemctl restart jellyfin
sudo systemctl status jellyfin
sudo ausearch -c 'jellyfin' --raw | audit2allow -M jellyfin_custom
sudo chown -R jellyfin:jellyfin /mnt/collection
sudo chmod -R 755 /mnt/collection
sudo ausearch -m avc -ts recent | grep jellyfin
sudo systemctl restart jellyfin
ls
cd shows/
ll
mv HOD "House Of Dragon"
sudo mv HOD "House Of Dragon"
ll
sudo nautilus
sudo systemctl start qbittorrent-nox@ahmed.service
sudo systemctl status qbittorrent-nox@ahmed.service
sudo groupadd media
sudo usermod -aG media jellyfin
sudo usermod -aG media qbittorrent
sudo usermod -aG media qbittorrent-nox
sudo usermod -aG media ahmed
getent passwd | cut -d: -f1
cat /etc/group
sudo chown -R :media /mnt/collection/
sudo chmod -R 775 /mnt/collection/
sudo iotop 
sudo usermod -aG media ahmed
getent passwd | cut -d: -f1
cat /etc/group
sudo chown -R :media /mnt/collection/
sudo chmod -R 775 /mnt/collection/
ll
mkdir backup
sudo mkdir backup
ls
cd back
cd backup/
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/Backup /mnt/collection/backup/
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/FLASH/ /mnt/collection/backup/
sudo rsync -rv /mnt/hdd/Pictures/ /mnt/collection/backup/
sudo rsync -rv /mnt/hdd/Seed/ /mnt/collection/backup/
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/Tutorials/ /mnt/collection/main/tutorials/
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/Videos/Archive /mnt/collection/backup/Backup/
iotop 
sudo ~~
sudo sudo ~~
sudo iotop 
nvim
nvim .bashr
nvim ~/.bashrc 
ls
ll
fastfetch 
nvim
killall alacritty
sudo dnf update
sudo systemctl start qbittorrent-nox@ahmed.service
sudo systemctl start qbittorrent-nox@ahmed.service
sudo dnf install xkill-1.0.6-5.fc40.x86_64 
xkill
sudo dnf update
sudo systemctl start qbittorrent-nox@ahmed.service
dnf search smartctl
dnf install gsmartcontrol-1.1.4-7.fc40.x86_64 
dnf install gsmartcontrol
sudo ~~
sudo dnf install gsmartcontrol-1.1.4-7.fc40.x86_64 
lsblk
smartctl --all /dev/sdb
sudo smartctl --all /dev/sdb
sudo smartctl --all /dev/sdb | less
cd .config/mpv/
nvim mpv.conf 
cd ~/Downloads/
ls
nvim trnmt1preset.json
nvim trnmt1preset.json 
nvim test.json
nvim test.json 
sudo dnf install iotop -y
iotop 
sudo find /mnt/collection/ -type d -exec chmod g+s {} +
sudo semanage fcontext -a -t public_content_rw_t "/mnt/collection(/.*)?"
sudo systemctl restart jellyfin
sudo systemctl restart qbittorrent
sudo systemctl restart qbittorrent-nox@ahmed.service 
lsblk
sudo umount /dev/sdb
sudo umount /dev/sdb1
sudo systemctl stop qbittorrent-nox@ahmed.service
sudo umount /dev/sdb2
sudo wipefs -a /dev/sdb
cd Desktop/x/
ls
yt-dlp -a all.txt 
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/Tutorials/ /mnt/collection/main/tutorials/
sudo rsync -rv --no-perms --no-owner --no-group /mnt/hdd/Videos/Archive /mnt/collection/backup/Backup/
iotop 
sudo ~~
sudo sudo ~~
sudo iotop 
nvim .bashr
nvim ~/.bashrc 
cd ~
dot
cd ~/dow
cd ~/Downloads/
unzip 
nvim
extract SoulseekQt-2018-1-30-64bit-appimage.tgz 
chmod +x SoulseekQt-2018-1-30-64bit.AppImage 
./SoulseekQt-2018-1-30-64bit.AppImage 
dnf search xcb
sudo dnf install libxcb libxkbcommon
ldd ./your_appimage_file.AppImage | grep "not found"
QT_DEBUG_PLUGINS=1 ./SoulseekQt-2018-1-30-64bit.AppImage 
dnf search soulseek
sudo dnf install nicotine+
waydroid 
waydroid -h
waydroid status 
cd ~/Desktop/
ls
cd ..
sudo chown -R :media ~/Desktop/x
ll
sudo chmod -R 775 ~/Desktop/x
cd x
python -m http.server 
sudo dnf install cmatrix
cmatrix
cd .config/mpv/
nvim mpv.
nvim mpv.conf 
ls
ll
exit
ls
npx create-next-app@latest
npm i -g pnpm
cd Documents/
ll
cd ..
cd Desktop/
ls
mkdir webdev
cd webdev/
pnpm dlx create-next-app@latest
code test-app/
code test-app/
ll
tree
ls
pnpm dev
code test-app/
cd ..
ls
mkdir learn
cd learn/
mkdir nextjs
cd nextjs/
npx create-next-app@latest nextjs-dashboard --example "https://github.com/vercel/next-learn/tree/main/dashboard/starter-example"
pnpm dlx create-next-app@latest nextjs-dashboard --example "https://github.com/vercel/next-learn/tree/main/dashboard/starter-example"
ll
cd nextjs-dashboard/
code .
ll
npx create-next-app@latest nextjs-dashboard --example "https://github.com/vercel/next-learn/tree/main/dashboard/starter-example"
pnpm dlx create-next-app@latest nextjs-dashboard --example "https://github.com/vercel/next-learn/tree/main/dashboard/starter-example"
cd nextjs-dashboard/
code .
dnf search appimaged
dnf copr -h
dnf copr search test
dnf copr search appimage
dnf copr enable eyecantcu/AppImageLauncher
sudo dnf install appimagelauncher
sudo dnf search appimage
sudo dnf copr enable eyecantcu/AppImageLauncher
sudo dnf update
dnf search appimage
sudo dnf copr remove eyecantcu/AppImageLauncher
cd Downloads/
wget https://github.com/GopeedLab/gopeed/releases/download/v1.5.7/Gopeed-v1.5.7-linux-x86_64.AppImage
ll
chmod +x Gopeed-v1.5.7-linux-x86_64.AppImage 
./Gopeed-v1.5.7-linux-x86_64.AppImage 
pnpm i
pnpm dev
cd Downloads/ytarchive_linux_amd64/
ls
chmod +x ytarchive 
cd ~/Videos/
ll
~/Downloads/ytarchive_linux_amd64/ytarchive https://www.youtube.com/watch?v=9PPfGwMZKuk
ping 1.1.1.1
sudo reboot
la
ls
ll
nvim
exit
ping 1.1.1.1
ping 1.1.1.1
nvim list.txt
cd
cd Downloads/
curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
sudo dnf install librewolf
ls
ll
rpm-ostree install librewolf
java
java --version
nvim
exit
ping 1.1.1.1
ls
ll
fastboot -w
sudo fastboot -w
fastboot flash boot boot.img 
sudo fastboot flash boot boot.img 
adb sideload lineage-20.0-20240208-nightly-taimen-signed.zip 
adb sideload NikGapps-core-arm64-13-20240420-signed.zip 
adb sideload NikGapps-Addon-13-DigitalWellbeing-20240420-signed.zip 
adb sideload NikGapps-Addon-13-GoogleSounds-20240420-signed.zip 
adb sideload NikGapps-Addon-13-GoogleClock-20240420-signed.zip 
adb sideload NikGapps-Addon-13-MarkupGoogle-20240420-signed.zip 
adb sideload Magisk-v27.0\ \(Copy\).zip 
adb sideload Magisk-v27.0\ \(Copy\).zip 
adb sideload NikGapps-Addon-13-GoogleMessages-20240420-signed.zip 
ls
neofetch 
fastfetch 
nvim
sudo pacman -Q git
pacman -Ss paru
pacman -Ss yay
git config --global credential.helper /mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
git clone https://github.com/NasifAhmed/dotfiles.git
cd 
cp -rv /mnt/c/Users/ahmed/dotfiles .
rm -rf .bashrc && ln -sv ~/dotfiles/bash/.bashrc .
rm -rf .bash_history && ln -sv ~/dotfiles/bash/.bash_history .
sudo pacman -S fzf ripgrep zoxide zellij
source .bashrc 
ll
ls
sudo -S neofetch
sudo pacman-S neofetch
sudo pacman -S neofetch
neofetch
exit
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
git clone git@github.com:NasifAhmed/dotfiles.git
fzf
sudo dnf install neovim zoxide zellij
sudo dnf install neovim zoxide
sudo dnf remove fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
mv .bashrc .bashrc.bak && ln -sv ~/dotfiles/bash/.bashrc .
rm -rf .bash_history && ln -sv ~/dotfiles/bash/.bash_history .
source .bashrc
ll
sudo dnf remove nodejs
cd Downloads/
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm 
exit
sudo dnf remove nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm 
exit
nvm
nvm install node
npm i -g pnpm
man ls
ln -sv ~/dotfiles/nvim ~/.config/
nvim
cd Downloads/
curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
sudo dnf install librewolf
git clone https://github.com/hl2guide/better-mpv-config.git
cd ..
cd better-mpv-config/
ll
mpv '/mnt/collection/main/movies/The.Fall.Guy.2024.1080p.AMZN.WEB-DL.DDP5.1.Atmos.H.264-FLUX.mkv' 
sudo dnf groupupdate 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing -y
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg -y
sudo dnf group upgrade --with-optional Multimedia
sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
sudo dnf update
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo dnf install lame\* --exclude=lame-devel
ls
sudo cp -rv Roboto /usr/share/fonts/
fc-cache -fv
nvim
sudo dnf install lame\* --exclude=lame-devel
ls
sudo dnf group upgrade --with-optional Multimedia
sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
dot
cd nvim/
cd ..
cd mpv/
ll
nvim mpv.conf 
rm -rf ~/.config/mpv
cd
ln -sv ~/dotfiles/mpv ~/.config/
mpv '/mnt/collection/main/movies/The.Fall.Guy.2024.1080p.AMZN.WEB-DL.DDP5.1.Atmos.H.264-FLUX.mkv' 
mpv '/mnt/collection/main/movies/Blade.Runner.2049.2017.1080p.BluRay.x265-RARBG/Blade.Runner.2049.2017.1080p.BluRay.x265-RARBG.mp4' 
code .bashrc
free -h
sudo dnf update
qbittorrent -h
ll
nvim ~/.config/alacritty/
exit
ll
nvim ~/.bashrc 
cd Downloads/zellij-x86_64-unknown-linux-musl/
ll
chmod +x zellij 
sudo cp zellij /usr/local/bin/
exi
exit
nvim ~/.bashrc 
exit
ln -sv /mnt/hdd/home/documents .
rm documents
ln -sv /mnt/hdd/home/documents ./Documents
ll
sudo rsync -rv ~/Downloads/ /mnt/hdd/home/downloads/
rm -rf Downloads
ln -sv /mnt/hdd/home/downloads ./Downloads
sudo rsync -rv /home/ahmed/Pictures/ /mnt/hdd/home/photos/
rm -rf Pictures
ln -sv /mnt/hdd/home/photos ./Pictures
sudo rsync -rv /home/ahmed/Videos/ /mnt/hdd/home/videos/
rm -rf Videos/
ln -sv /mnt/hdd/home/videos ./Videos
ll
rm -rf /mnt/hdd/home/documents
sudo rm -rf /mnt/hdd/home/documents
sudo dnf install android-tools-1:34.0.4-14.fc40.x86_64 
ll
sudo rsync -rv ./Documents/ /mnt/hdd/home/documents/
rm -rf Documents 
ll
nvim .config/mpv/mpv.conf 
cd /home/ahmed/Desktop/FLASH
adb reboot bootloader
fastboot oem unlock
sudo fastboot oem unlock
sudo fastboot flashing unlock
sudo fastboot erase avb_custom_key
sudo fastboot flash avb_custom_key avb_pkmd-device.bin
ls
sudo fastboot flash avb_custom_key avb_pkmd-taimen.bin
sudo fastboot erase avb_custom_key
sudo fastboot flash avb_custom_key avb_pkmd-taimen.bin
sudo fastboot reboot bootloader
sudo fastboot update divested-20.0-20240615-dos-taimen-fastboot.zip 
sudo fastboot reboot recovery
sudo fastboot flashing unlock
sudo fastboot reboot bootloader
sudo fastboot erase avb_custom_key
sudo fastboot flash avb_custom_key avb_pkmd-taimen.bin
sudo fastboot reboot bootloader
sudo fastboot update divested-20.0-20240615-dos-taimen-fastboot.zip
adb sideload divested-20.0-20240615-dos-taimen.zip
adb reboot bootloader
sudo fastboot flashing get_unlock_ability
sudo fastboot flashing lock
adb reboot recovery
adb sideload Magisk-v27.0.zip 
sudo fastboot flashing unlock
adb reboot recovery
adb kill-server
adb reboot recovery
adb sideload Magisk-v27.0.zip 
cd divested-20.0-20240615-dos-taimen/
../payload-dumper-go_1.2.2_linux_amd64/payload-dumper-go payload.bin 
adb reboot bootloader
sudo fastboot flash boot ../magisk_patched-27000_vBOHJ.img 
fastboot flash vbmeta --disable-verity --disable-verification ./extracted_20240630_020529/vbmeta.img 
sudo fastboot flash vbmeta --disable-verity --disable-verification ./extracted_20240630_020529/vbmeta.img 
cd Desktop/FLASH/
ll
adb reboot bootloader
sudo fastboot flashing unlock
sudo fastboot erase avb_custom_key
sudo fastboot flash avb_custom_key avb_pkmd-taimen.bin
sudo fastboot update divested-20.0-20240615-dos-taimen-fastboot.zip
sudo fastboot -w
sudo fastboot erase avb_custom_key
sudo fastboot flash avb_custom_key avb_pkmd-taimen.bin
sudo fastboot reboot bootloader
sudo fastboot update divested-20.0-20240615-dos-taimen-fastboot.zip
adb sideload divested-20.0-20240615-dos-taimen.zip
sudo fastboot oem lock
sudo fastboot flashing lock
adb devices
adb kill-server
adb devices
cd taimen-rp1a.201005.004.a1-factory-2f5c4987/
ll
cd taimen-rp1a.201005.004.a1/
ll
./flash-all.sh 
sudo ./flash-all.sh 
sudo fastboot flashing unlock
sudo ./flash-all.sh 
fastboot flash bootloader bootloader-taimen-tmz30m.img
sudo fastboot flash bootloader bootloader-taimen-tmz30m.img
sudo fastboot reboot-bootloader
sudo fastboot flash radio radio-taimen-g8998-00034-2006052136.img
sudo fastboot reboot-bootloader
sudo fastboot -w update image-taimen-rp1a.201005.004.a1.zip
sudo ./flash-all.sh 
adb kill-server
lsusb
sudo nvim /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo systemctl restart udev
dnf search udev
rm /etc/udev/rules.d/51-android.rules 
sudo rm /etc/udev/rules.d/51-android.rules 
sudo udevadm control --reload
sudo ln -s /usr/share/doc/android-tools/51-android.rules /etc/udev/rules.d/
sudo udevadm control --reload
fastboot devices
sudo fastboot devices
sudo groupadd plugdev
sudo usermod -aG plugdev $USER
sudo dnf install -y android-tools
sudo ln -s /usr/share/doc/android-tools/51-android.rules /etc/udev/rules.d
sudo nvim /etc/udev/rules.d/51-android.rules
lsusb
sudo nvim /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload
fastboot -l devices
sudo usermod -aG plugdev ahmed
fastboot -l devices
sudo systemctl restart udev
fastboot -l devices
cd ..
ll
cd ..
cd lineage/
fastboot devices
fastboot flash boot boot.img 
adb -d sideload lineage-21.0-20240627-nightly-taimen-signed.zip 
adb -d sideload MindTheGapps-14.0.0-arm64-20240612_135921.zip 
adb -d sideload ../Magisk-v27.0.zip 
fastboot -w
fastboot flash boot A13/boot.img 
fastboot -w
fastboot flash boot A13/boot.img 
adb -d sideload A13/lineage-20.0-20240208-nightly-taimen-signed.zip 
adb -d sideload A13/MindTheGapps-13.0.0-arm64-20231025_200931.zip 
adb -d sideload ../Magisk-v27.0.zip 
sudo dnf install qemu -y
egrep '^flags.*(vmx|svm)' /proc/cpuinfo 
sudo dnf install @virtualization
sudo dnf group install --with-optional virtualization
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
lsmod | grep kvm
sudo usermod -a -G libvirt $(whoami)
sudo chown -R ahmed:ahmed /mnt/collection/BCKUP/Win11\ 23H2\ English\ x64v2/Win11_23H2_English_x64v2.iso 
free -h
cd Videos/
/mnt/hdd/home/downloads/ytarchive_linux_amd64/ytarchive https://www.youtube.com/watch?v=mhTnYEUmYbk
cd Downloads/
ll
chown -R ahmed:ahmed torrents/
sudo chown -R ahmed:ahmed torrents/
dnf search win
dnf search windows
dnf search woeusb
sudo dnf install woeusb
sudo dnf install WoeUSB
woeusb 
lsblk
woesb --device /mnt/collection/BCKUP/Win11\ 23H2\ English\ x64v2/Win11_23H2_English_x64v2.iso /dev/sdd
sudo woeusb --device /mnt/collection/BCKUP/Win11\ 23H2\ English\ x64v2/Win11_23H2_English_x64v2.iso /dev/sdd
lsblk
sudo woeusb --device /mnt/collection/BCKUP/Win11\ 23H2\ English\ x64v2/Win11_23H2_English_x64v2.iso /dev/sdd
woeusb --device /mnt/collection/BCKUP/Win11\ 23H2\ English\ x64v2/Win11_23H2_English_x64v2.iso /dev/sdd
sudo woeusb --device /mnt/collection/BCKUP/Win11\ 23H2\ English\ x64v2/Win11_23H2_English_x64v2.iso /dev/sdd
lxblk
lsblk
sudo woeusb --device /mnt/collection/BCKUP/Win11\ 23H2\ English\ x64v2/Win11_23H2_English_x64v2.iso /dev/sdd
dot
sudo pacman zoxide fzf lazygit
sudo pacman -S zoxide fzf lazygit
git push
git clone https://github.com/NasifAhmed/dotfiles.git
nvim .bashrc 
rm -rf .bashrc && ln -sv ~/dotfiles/bash/.bashrc .
rm -rf .bash_history && ln -sv ~/dotfiles/bash/.bash_history .
source .bashrc 
ls
cat .bash_history | wc -l
cat .bash_history | fzf
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
cd ~
ls -alh
dot
git status
ls -alh
git status
history 
dot
git add .
git config --global user.email "nasif2ahmed@gmail.com"
git config --global user.name "Nasif Ahmed"
git commit -m "update"
git push
ls
ll
exit
lsblk
fastfetch 
sudo dnf install syncthing
sudo systemctl enable syncthing@ahmed.service
sudo systemctl start syncthing@ahmed.service
sudo systemctl status syncthing@ahmed.service
curl -s https://wallpapers.manishk.dev/install.sh | bash -s THEME_CODE
curl -s https://wallpapers.manishk.dev/install.sh | bash -s Catalina
curl -s https://wallpapers.manishk.dev/install.sh | bash -s Lakeside
free -h
ls
ll
neofetch 
fastfetch 
ssh-keygen -t ed25519 -C "nasif2ahmed@gmail.com"
at ~/.ssh/id_ed25519.pub
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
git clone git@github.com:NasifAhmed/dotfiles.git
rm -rf .bashrc && ln -sv ~/dotfiles/bash/.bashrc .
rm -rf .bash_history && ln -sv ~/dotfiles/bash/.bash_history .
sudo dnf install neovim
sudo dnf remove neovim
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc 
nvm
nvm install node
sudo dnf install nvim 
sudo dnf install neovim 
nvm list
nvim
nvim .bashrc 
xit
exit
For fzf : git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
[200~For fzf : git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
exit
pnpm install
npm i -g pnpm
pnpm install
nvim "Correction - 9. MAT215 ｜ See description for correction ｜ Complex or Contour Integral ｜｜ Part 2 ｜｜ on 1 Sep, 2020 ｜｜ [AcGRbUoOSXE]"
free -h
mpv "http://172.16.50.12/DHAKA-FLIX-12/TV-WEB-Series/TV%20Series%20%E2%99%A6%20%20S%20%20%E2%80%94%20%20Z/True%20Detective%20%28TV%20Series%202014%E2%80%932019%29%201080p%20%5BDual%20Audio%5D/Season%201/True%20Detective%20S01E01%20%201080p%20BluRay%20x265%20HEVC%20MSubs%20%5BDual%20Audio%5D%5BHindi%202.0%2BEnglish%205.1%5D%20-MsMod.mkv"
mpv http://fs.ebox.live/TV-Series/English/True%20Detective/Season%201/True%20Detective.S01E01__720p.WEBrip__E-BOX.mkv
