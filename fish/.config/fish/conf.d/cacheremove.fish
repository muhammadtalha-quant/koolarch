function cacheremove --description "Delete unwanted cache of pacman, yay and flatpak."
    yay -Scc 
    paccache -rk0
    yay -Syy
    flatpak uninstall -y --unused
    for dir in (eza -1 --color=never ($HOME/.var/app))
        rm -rf $dir
    end
    cd ~
end
