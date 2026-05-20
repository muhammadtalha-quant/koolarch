complete -c sysupdate -f
complete -c sysupdate -s s -l system      -d 'Update system packages and AUR via yay'
complete -c sysupdate -s f -l only-flatpaks -d 'Update Flatpak apps and remove unused runtimes'
complete -c sysupdate -s a -l all         -d 'Update everything: system, AUR, and Flatpaks'
 