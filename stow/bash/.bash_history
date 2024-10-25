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
ssh -T git@github.com
git status
git log
cp ~/.config/nvim/init.lua .
rm -rf dotfiles
git clone git@github.com:NasifAhmed/dotfiles.git
cp init.lua ./dotfiles/nvim/
edit
cd .config/nvim/
cd ..
ls
ll
dot
git add .
git commit -m "update"
git push
jump
ls
nvim linkedlist.go 
ls
powershell
powershell.exe
exit
powershell.exe
exit
cd ~
cd dev/
nvim -u NONE
ls
ll
nvim array.go 
cd ~/dev/
ls
go run array.go 
powershell.exe
exit
nvim .wezterm.lua 
exit
nvim
exit
nvim
exit
ls
nvim
ls
nvim 
exit
powershell.exe
nvim .wezterm.lua 
nvim 
sudo pacman -Syyu
edit
nvim
cd ~
cd dev/
nvim array.go 
nvim .
nvim slicesExcercise.go
nvim wordCount.go
fastfetch 
ls
exit
nvim
nvim
jump
ls
edit
nvim 
nvim /mnt/c/Users/ahmed/.wezterm.lua 
o
go run array.go 
go run wordCount.go 
exit
cd dev/
ls
ll
cp defer.go array.go
nvim array.go 
edit
cd ~
cd go/bin/
./tour 
cd ~/dev/
go run array.go 
exit
cd dev/
cp defer.go array.go
nvim array.go 
cd ~
cd go/bin/
./tour 
cd ~/dev/
go run array.go 
fastfetch 
ll
edit
source ~/.bashrc 
ls
./tour 
cd ~/dev/
go run array.go 
source ~/.bashrc 
ls
ll
edit
nvim
nvim .wezterm.lua 
nvim 
powershell.exe
nvim .wezterm.lua 
nvim 
nvim .
nvim slicesExcercise.go
nvim wordCount.go
jump
nvim 
o
go run array.go 
go run wordCount.go 
cp defer.go array.go
cd go/bin/
./tour 
cd ~/dev/
go run array.go 
sudo pacman -Syu
sudo pacman -Su
sudo pacman -Sy
sudo pacman -S pacman-mirrors
sudo pacman -S reflector
sudo reflector --country Bangladesh --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo reflector --country Bangladesh --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo reflector --country Bangladesh,India,Singapore --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
nvim /etc/pacman.d/mirrorlist
sudo pacman -Syyu
wezterm -h
wezterm.exe ls-fonts
wezterm.exe -h
wezterm.exe imgcat
cd `
nvim /mnt/c/Users/ahmed/.wezterm.lua 
source ~/.bashrc 
fast
fastfetch 
dot
edit
nvim
cd ..
l
cd /mnt/c/Users/ahmed/
ll
cd ~
cd dev/
ls
nvim array.go 
exit
edit
nvim
cd ~/go/bin/
./tour&
jump
ls
go run array.go 
eixt
exit
nvim
cd ~
cd test/
pip
sudo pacman -Ss python-pi
sudo pacman -Ss python-pip
sudo pacman -S python-pop
sudo pacman -S python-pip
pip install openai
pacman -S python-openai
sudo pacman -S python-openai
python openapitest.py 
python openapitest.py > output.txt
python openapitest.py >> output.txt
python openapitest2.py >> output2.txt
exit
go run array.go 
source ~/.bashrc 
ll
edit
nvim
sudo pacman -S python
cd ~
mkdir test
cd test/
nvim openapitest.py
cat output.txt \
nvim output.txt 
> output.txt 
cat output.txt 
ls
cp openapitest.py openapitest2.py
nvim openapitest2.py 
exit
jump
ls
nvim openapitest2.py 
nvim output2.txt 
python openapitest.py >> output.txt 
exit
jump
nvim openapitest2.py 
nvim output2.txt 
python openapitest.py >> output.txt 
sudo -Syyu
sudo pacman -Syyu
sudo pacman -S --needed git base-devel
mkdir downloads
cd downloads/
git clone https://aur.archlinux.org/paru.git
cd paru/
makepkg -si
paru
fastfetch 
cd ..
cd !
cd ~
paru -Ss aqua
paru -Ss aqua | less
paru -S asciiquarium
mkdir wezterm
cd wezterm/
cp /mnt/c/Users/ahmed/.wezterm.lua .
ls
ll
dot
git add .
git commit -m "Misc. updates"
git push
paru -Ss "ascii fire" | less
paru -Ss fire | less
paru -Ss cmatrix
paru -S cmatrix
paru -S btop
btop
cmatrix 
asciiquarium 
clear
nvim 
nvim
exit
ls
exit
nvim
exit
asciiquarium 
nvim
exit
jump
go run array.go 
go run array.go  | less
exit
exit
exit
nvim
asciiquarium 
ascii
jump
ls
nvim worexit
exit
asciiquarium 
nvim
go run array.go 
go run array.go  | less
nvim
asciiquarium 
ascii
nvim worexit
jump
npm install -D tailwindcss
npx tailwindcss init
npx tailwindcss -i ./src/input.css -o ./src/output.css --watch
nvim main.jsx 
cd ..
l
nvim index.html 
rm tailwind.config.js 
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
nvim tailwind.config.js 
ll
cd src/
ls
nvim index.css 
exit
ascii
nvim worexit
jump
ls
npm i -g vite
npm install
npm run dev
exit
exit
asciiquarium 
ascii
jump
sudo paru -S paru
paru gem
paru -Ss gem
paru -Ss gem | less
paru ruby-gem
paru ruby
paru -S figlet toilet
nvim
rm ~/dotfiles/wezterm/.wezterm.lua 
cd wezterm/
cp /mnt/c/Users/ahmed/.wezterm.lua .
dot
git add .
git commit -m "update"
git push
npm
cd ~/dev/
mkdir react
cd react/
npm create vite@latest
cd refresh-project-react/
ls
nvim .
nvim 
sudo paru -S wget
code .
paru -S bat
bash
exit
nvim
asciiquarium 
ascii
jump
ls
nvim worexit
exit
asciiquarium 
nvim
go run array.go 
go run array.go  | less
nvim
asciiquarium 
ascii
nvim worexit
jump
npm install -D tailwindcss
npx tailwindcss init
npx tailwindcss -i ./src/input.css -o ./src/output.css --watch
nvim main.jsx 
cd ..
l
nvim index.html 
rm tailwind.config.js 
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
nvim tailwind.config.js 
ll
cd src/
ls
nvim index.css 
exit
export PS1="::: Terminal allocated for FindItFaster. Do not use. ::: "; clear
/home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_files.sh  '/home/ahmed/dev/react/refresh-project-react'
HAS_SELECTION=0 /home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_within_files.sh  '/home/ahmed/dev/react/refresh-project-react'
clear
HAS_SELECTION=0 /home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_files.sh  '/home/ahmed/dev/react/refresh-project-react'
HAS_SELECTION=0 /home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_files.sh  '/home/ahmed/dev/react/refresh-project-react'
cd src/
ls
touch box.jsx
code box.jsx 
LS
npm run dev
btop
top
nvim index.css 
exit
export PS1="::: Terminal allocated for FindItFaster. Do not use. ::: "; clear
/home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_files.sh  '/home/ahmed/dev/react/refresh-project-react'
HAS_SELECTION=0 /home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_within_files.sh  '/home/ahmed/dev/react/refresh-project-react'
clear
HAS_SELECTION=0 /home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_files.sh  '/home/ahmed/dev/react/refresh-project-react'
HAS_SELECTION=0 /home/ahmed/.vscode-server/extensions/tomrijndorp.find-it-faster-0.0.39/find_files.sh  '/home/ahmed/dev/react/refresh-project-react'
cd src/
touch box.jsx
code box.jsx 
LS
npm run dev
jump
cd react/
npm i -g deno
npm uninstall -g deno
curl -fsSL https://deno.land/install.sh | sh
source ~/.bashrc 
deno -h
npm i -g pnpm
pnpm create vite@latest
cd crud-app/
pnpm install
cd ..
mkdir crud-api
cd crud-ap
cd crud-api
ls
code .
curl localhost:3000
paru mongodb | less
paru mongodb
sudo reflector --country Bangladesh,India,Singapore --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo reflector --country Bangladesh,India,Singapore --sort rate --save /etc/pacman.d/mirrorlist
paru -S mongodb-bin
sudo systemctl status mongod
mongod -h
mongod -h | less
mongod
paru -Rsc mongodb-bin
paru 
paru -S mongodb
paru -S docker
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
docker pull mongo
sudo docker pull mongo
mkdir -p ~/db
docker run -d -p 27017:27017 -v ~/db:/data/db --name mongodb-container mongo
sudo docker run -d -p 27017:27017 -v ~/db:/data/db --name mongodb-container mongo
docker ps
sudo docker ps
curl localhost:27017
free -h
curl mongodb://localhost:27017/yourdbname
curl mongodb://localhost:27017
docker exec -it mongodb-container mongo
sudo docker exec -it mongodb-container mongo
winget search mongodb
pnpm install mongoose
pnpm install dotenv
node seed.js 
LS
npm run dev
pnpm init . 
pnpm create . 
npm init
pnpm install
pnpm install express
pnpm run dev
ls
code package.json 
pnpm install nodemon
pnpm dev
jum
jump
code .
asciiquarium 
ls
ll
fast
fastf`
fastfetch 
fast
fastfetch 
nvim
fastfetch 
nvim
sudo docker run -d -p 27017:27017 -v ~/db:/data/db --name mongodb-container mongo
docker ls
docker ps -a
docker run mongodb-container
docker start mongodb-container
docker s
docker ps
curl localhost:27017
curl localhost:27107
curl localhost:270107
curl localhost:27017
jump
cd ..
ls
code .
nvim
exit
fc-cache -fv
fc-list | grep "Jet"
 curl -sSL "github.com/NasifAhmed/dotfiles/raw/main/auto.sh" | bash
yay ssh_askpass
yay ssh-askpass
sudo pacman -S ssh-askpass
yay
yay -S ssh-askpass
yay ssh-askpass
 curl -sSL "github.com/NasifAhmed/dotfiles/raw/main/auto.sh" | bash
 curl -sSL "github.com/NasifAhmed/dotfiles/raw/main/auto.sh" | bash
nano auto.sh
chmod +x auto.sh 
./auto.sh 
source ~/.bashrc 
ls
yay wezterm
yay nvidia-inst
nvidia-inst
yay -Syu nvidia-470xx-dkms nvidia-470xx-utils nvidia-470xx-settings
sudo reboot now
nano /etc/environment 
sudo nano /etc/environment 
nvim /run/media/ahmed/HDD/BACKUP/BCKUP/Nvidia 470 driver setup for GT710.md
yay -S xclip
sudo nvim /etc/environment 
sudo reboot
nvim /run/media/ahmed/HDD/BACKUP/BCKUP/Nvidia 470 driver setup for GT710.md
cd .config/
yay -S gnome-backgrounds
nvim .bashr
nautilus .
nvim .wezterm.lua 
ls
yay -S fastfetch
fastfetch 
xdg-settings set default-terminal wezterm
xdg-terminal-exec
whereis wezterm
gsettings set org.gnome.desktop.default-applications.terminal exec '/usr/bin/wezterm'
nvim .wezterm.lua 
exit
xdg-terminal-exec
whereis wezterm
gsettings set org.gnome.desktop.default-applications.terminal exec '/usr/bin/wezterm'
yay -S luarocks go python
nvm install node
npm
yay clang
nvim
nvim .wezterm.lua 
exit
nvim .wezterm.lua 
ls
ls
yay -S asciiaquarium
sudo nvim /etc/systemd/resolved.conf 
yay
sudo reboot
free -h
fastfetch 
yay
sudo reboot
free -h
fastfetch 
cd ~
ls
ll
nvim .gitignore 
dot
git add .gitignore 
git config --global user.name "Nasif Ahmed"
git config --global user.email "nasif2ahmed@gmail.com"
git commit -m "update gitignore for new folder structure"
git push
nvim
exit
xdg-terminal-exec
whereis wezterm
gsettings set org.gnome.desktop.default-applications.terminal exec '/usr/bin/wezterm'
yay -S luarocks go python
nvm install node
npm
yay clang
nvim
nvim .wezterm.lua 
exit
nvim .wezterm.lua 
yay -S asciiaquarium
sudo pacman -Syyu
yay
sudo pacman -S asciiaquarium
sudo pacman -S --needed base-devel
cd Downloads/
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
paru
paru -S asciiquarium
asciiquarium 
cd stow/
mkdir wezterm
cd bash/
cd ..
cd wezterm/
cp ~/.wezterm.lua .
ll
git pull
sudo nvim /etc/systemd/resolved.conf 
git rm stow/nvim/.config/nvim/lazy-lock.json 
git rm -f stow/nvim/.config/nvim/lazy-lock.json 
git add .
git commit -m "..."
git push
curl https://test.nextdns.io/
wget https://test.nextdns.io/
cat index.html 
wget test.nextdns.io/
rm index.html 
ls
dot
yay -S btop
btop
yay -S htop
htop
yay -S gnome-software
sudo pacman -S packagekit gnome-software-plugin-flatpak
sudo pacman -S packagekit
sudo systemctl enable packagekit.service
sudo systemctl start packagekit.service
sudo systemctl status packagekit.service
sudo pacman -S flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
gnome-software -h
gnome-software --quit
yay -S easyeffects
yay -Rsc easyeffects
sudo reboot
yay -S adw-gtk-theme
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
sudo nvim /etc/X11/xorg.conf.d/20-nvidia.conf 
yay -S mpv
history
ls /mnt/
sudo reboot
yay -S qbittorrent
qbittorrent 
yay -Rcs qbittorrent
yay notion
yay -S python-nautilus
sudo nvim /etc/X11/xorg.conf.d/20-nvidia.conf 
yay -S mpv
history
ls /mnt/
sudo reboot
yay -S qbittorrent
qbittorrent 
yay -Rcs qbittorrent
yay notion
yay -S python-nautilus
yay -S visual-studio-code-bin
fastfetch 
fastfetch -h
fastfetch -h | less
stow -t ~/dotfiles/stow -S wezterm
stow -h
stow -t ~/dotfiles/stow -S wezterm -d ~/
stow -t ~/dotfiles/stow -S bash -d ~/
stow -t /home/ahmed/dotfiles/stow/ -S wezterm -d ~/
stow -t /home/ahmed/dotfiles/stow -S wezterm -d ~/
nvim auto.sh 
dot 
cd stow/
stow -v -t "$HOME" wezterm
stow --adopt -v -t "$HOME" wezterm
cd ~
ll
dot
yay update-alternative
sudo update-alternatives --config x-terminal-emulator
whereis wezterm
gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/wezterm
nvim ~/.bashrc 
source ~/.bashrc 
ls
sudo reboot
cd stow/
stow -v -t "$HOME" wezterm
stow --adopt -v -t "$HOME" wezterm
cd ~
ll
dot
yay update-alternative
sudo update-alternatives --config x-terminal-emulator
whereis wezterm
gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/wezterm
nvim ~/.bashrc 
source ~/.bashrc 
ls
sudo reboot
fastfetch 
htop
yay docker
sudo systemctl enable docker
sudo systemctl start docker
docker pull alpine
sudo docker pull alpine
docker run -it alpine /bin/sh
docker ps
sudo docker run -it alpine /bin/sh
docker ps -a
docker rm inspiring_clarke
sudo docker rm inspiring_clarke
docker -h
docker -h | less
sudo docker rename blissful_mclaren alpine-test
sudo docker start alpine-test
sudo docker start -it alpine-test
sudo docker attach alpine-test
sudo docker ps
sudo docker volume
sudo docker volume ls
sudo docker volume ls -a
docker -h | less 
sudo docker info
sudo docker info alpine-test
sudo docker ps 
sudo docker pull hello-world
sudo docker run -it hello-world
sudo docker ps -a
sudo docker ps -a --seize
sudo docker ps -a --size
sudo docker pull busybox
sudo docker run -it busybox
sudo docker volume ls -a
docker -h | less 
sudo docker info
sudo docker info alpine-test
sudo docker ps 
sudo docker pull hello-world
sudo docker run -it hello-world
sudo docker ps -a
sudo docker ps -a --seize
sudo docker ps -a --size
sudo docker pull busybox
sudo docker run -it busybox
yay
pkill qbittorrent 
qbittorrent -h
qbittorrent --webgui-port 4949
qbittorrent --webui-port 4949
qbittorrent --webui-port=4949
qbittorrent 
yay -Rcs qbittorrent
yay qbittorrent
touch /etc/systemd/system/qbittorrent-nox.service
ll .config
nvim
yay adduser
sudo adduser --system --group qbittorrent-nox
sudo useradd --system --group qbittorrent-nox
sudo useradd -r -s /usr/bin/nologin qbittorrent
sudo -u qbittorrent mkdir -p /home/qbittorrent/.cache/qBittorrent
mkdir -p qbittorrent
ll
rm -rf qbittorrent/
cd ..
mkdir qbittorrent
sudo mkdir qbittorrent
sudo chown -R qbittorrent:qbittorrent /home/qbittorrent
sudo -u qbittorrent qbittorrent-nox
cat /etc/group
cat /etc/group | grep "qbit"
sudo nvim /etc/systemd/system/qbittorrent-nox.service
sudo systemctl daemon-reload
sudo systemctl start qbittorrent-nox
sudo systemctl enable qbittorrent-nox
sudo systemctl status qbittorrent-nox
htop
edit
cd ~
nvim .wezterm.lua 
yay evince
fastfetch 
ls
cheat
sudo docker ps
sudo docker volume
sudo docker volume ls
sudo docker volume ls -a
docker -h | less 
sudo docker info
sudo docker info alpine-test
sudo docker ps 
sudo docker pull hello-world
sudo docker run -it hello-world
sudo docker ps -a
sudo docker ps -a --seize
sudo docker ps -a --size
sudo docker pull busybox
sudo docker run -it busybox
yay
pkill qbittorrent 
qbittorrent -h
qbittorrent --webgui-port 4949
qbittorrent --webui-port 4949
qbittorrent --webui-port=4949
qbittorrent 
yay -Rcs qbittorrent
yay qbittorrent
touch /etc/systemd/system/qbittorrent-nox.service
ll .config
nvim
yay adduser
sudo adduser --system --group qbittorrent-nox
sudo useradd --system --group qbittorrent-nox
sudo useradd -r -s /usr/bin/nologin qbittorrent
sudo -u qbittorrent mkdir -p /home/qbittorrent/.cache/qBittorrent
mkdir -p qbittorrent
ll
rm -rf qbittorrent/
cd ..
mkdir qbittorrent
sudo mkdir qbittorrent
sudo chown -R qbittorrent:qbittorrent /home/qbittorrent
sudo -u qbittorrent qbittorrent-nox
cat /etc/group
cat /etc/group | grep "qbit"
sudo nvim /etc/systemd/system/qbittorrent-nox.service
sudo systemctl daemon-reload
sudo systemctl start qbittorrent-nox
sudo systemctl enable qbittorrent-nox
sudo systemctl status qbittorrent-nox
htop
edit
nvim .wezterm.lua 
yay evince
fastfetch 
curl cheat.sh/ls
cheat
tldr useradd
builtin cd -- /home/ahmed/Desktop
builtin cd -- /home/ahmed/Desktop/dev/react/crud-api
ls
cd ~
yay gnome | fzf
pacman -Ss gnome
pacman -Ss gnome | fzf
nvim .bashrc 
source .bashrc 
pacs
nvim
source .bashrc 
mans
nvim
docker start alpine-test
sudo docker start alpine-test
sudo docker attach alpine-test
source .bashrc 
pacs
sudo reboot now
yay tldr
tldr ls
tldr go
curl wttr.in/Dhaka
curl wttr.in/khilgaon
ls
ifconfig
exit
asciiquarium 
curl wttr.in/Dhaka
curl wttr.in/khilgaon
ifconfig
asciiquarium 
pacs
mpv "https://www.youtube.com/watch?v=2ZJyx_DLnjU"
tldt mpv
tldr mpv
mpv ytdl-format="best[height<=1080]" "https://www.youtube.com/watch?v=2ZJyx_DLnjU"
yay -S zsh
mkdir .config/zsh
builtin cd -- /home/ahmed/.config/zsh
nvim 
ls
ll
ll ~/
cp ~/.config/zsh/.zshrc ~/
zsh
exit
curl wttr.in/Dhaka
curl cheat.sh/ls
curl cheat.sh/ls | fzf
tldr -h
tldr -s
tldr -l
tldr --print-completion
tldr --print-completion bash
pacs
edit
exit
yay -S qmplay2
free -h
yay firedragon
yay -Rcs firedragon
yay -Q firedragon- | fzf
yay -Rcs firedragon-bin
ps aux | grep -E 'clipman|clipster|copyq|parcellite|xclip|xsel'
sudo pacman -S copyq
copyq -h
tldr copyq
copyq clipboard 
sydo systemctl start copyq
sudo systemctl start copyq
copyq -h | less
sudo pacman -Rcs copyq
curl https://github.com/Evren-os/hyprblaze/raw/refs/heads/main/Configs/.config/mpv/mpv.conf | nvim
nvim
exit
exit
asciiquarium 
pkill mpv
nvtop
nvtop 
mpv "/mnt/01DAD673C89AC420/movies/A.Quiet.Place.Day.One.2024.1080p.WEB-DL.DDP5.1.Atmos.H.264-InMemoryOfEVO.mkv"
yay nvtop
nvtop
sudo nvtop
yay -S nvidia-utils
mpv "/mnt/01DAD673C89AC420/movies/Apocalypse.Now.1979.Final.Cut.1080p.BluRay.10.Bit.AAC.5.1.x265-ALiEN.mkv"
pacs
bash pacs
exit
