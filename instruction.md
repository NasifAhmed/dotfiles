# Plan

So this is my git repo for all my work. It will have a simple folder for all my
configs and other files in Desktop and other places in a stow format. Make a
simple script if I run it it will do these things. It will be such a script that
using this I can make any new Omarchy linux install mine or apply any new update
to my configs and take my storage stuff anywhere

- Check dependencies for the script like stow, git, fzf for example if not installed ask the user to install if yes then skip. Update and add hyprland-plugins repo to hyprpm and enable hyprscrolling if its not done beofore.
- Check if ~/.local/bin/ is in the path or in current shell .rc export if not
  only then add it
- Show visual confirmation or error for each step also show animation of
  indicators when something is loading
- The git repo will have folder called repo where files and folders will be in
  stow-able format mapping to home directory of user like stow needs.
- Do the ui with fzf all the listing and choosing nothing non-native
- Make sure I can go into nested option and back out without exiting the script.
  Should feel like a TUI app.
- Main script will have these options :
  1. Sync ( Pull and then push if there is conflict stash the local stuff and
     prefer the cloud changes)
  2. Stow all ( Stow all the packages in the repo folder. There maybe already files or folders there where stow will be resolve this conflict by removing the old stowd syminks if they are symlinks if they are fully files/folders then it will rename those with .bak and then do it.)
  3. Stow Selective ( List the available pacakges and let me choose one and stow
     that one only)
  4. Unstow all ( Remove all the stowed stuff )
  5. Unstow Selective ( Just like stow slective let me choose a package and unstow it)
  6. Add to repo ( List all the files and folders while folders appearing on top
     and let me choose a folder/file and map it accordingly in the repo folder
     and add as a new package also let me name the package myself )
  7. Remove from repo ( Let me choose a package and remove it. Put it in its right mapped place first then delete it )
  8. History : Git commit history in a list
  9. Exit : Exit the scirpt gracefully
