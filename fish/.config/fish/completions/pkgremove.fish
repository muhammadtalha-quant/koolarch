complete -c pkgremove -f
complete -c pkgremove -s S -l system  -d 'Browse and remove system packages (pacman + AUR)'
complete -c pkgremove -s F -l flatpak -d 'Browse and remove installed Flatpak apps'
complete -c pkgremove -s s -l single  -d 'Uninstall <pkg> from the selected scope'