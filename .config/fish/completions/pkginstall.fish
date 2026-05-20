complete -c pkginstall -f
complete -c pkginstall -s R -l repo    -d 'Browse and install <pkgs...> from pacman repos'
complete -c pkginstall -s A -l aur     -d 'Browse and install <pkgs...> from AUR'
complete -c pkginstall -s F -l flathub -d 'Browse and install <pkgs...> from Flathub'
complete -c pkginstall -s s -l single  -d 'Install <pkg> from the selected provider'
