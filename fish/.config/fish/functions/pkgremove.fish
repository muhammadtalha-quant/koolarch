function pkgremove --description "Browse and mark packages for deletion"

    function _usage
        printf "Usage: pkgremove <scope> [option]\n\n"
        printf "Scopes:\n"
        printf "  -S, --system     Browse and remove installed system packages (pacman + AUR)\n"
        printf "                   Uses 'yay -Rns' to also remove unneeded dependencies\n"
        printf "  -F, --flatpak    Browse and remove installed Flatpak apps\n"
        printf "                   Unused runtimes are cleaned up automatically\n\n"
        printf "Options:\n"
        printf "  -s, --single <pkg>   Remove <pkg> directly, skip fzf menu\n"
        printf "  -h, --help           Show this help\n\n"
        printf "Keybinds (fzf):\n"
        printf "  TAB                  Mark/unmark package\n"
        printf "  ENTER                Uninstall selected\n"
        printf "  Up/Down              Scroll list\n"
    end

    # ── parse flags ───────────────────────────────────────────────────────
    set -l fzf_opts --layout=reverse-list --multi \
        --header 'ENTER: Uninstall | TAB: Select | Up/Down: Scroll'
    set -l options S/system F/flatpak s/single h/help
    argparse $options -- $argv
    or return 1

    if set -q _flag_help
        _usage
        functions -e _usage
        return 0
    end

    # ── require exactly one scope ─────────────────────────────────────────
    set -l scope_count 0
    set -q _flag_system && set scope_count (math $scope_count + 1)
    set -q _flag_flatpak && set scope_count (math $scope_count + 1)

    if test $scope_count -eq 0
        printf "pkgremove: a scope is required\n\n"
        _usage
        functions -e _usage
        return 1
    end

    if test $scope_count -gt 1
        printf "pkgremove: only one scope may be specified at a time\n\n"
        _usage
        functions -e _usage
        return 1
    end

    # ── --single requires a package name ──────────────────────────────────
    if set -q _flag_single
        if test (count $argv) -eq 0
            printf "pkgremove: --single requires a package name\n"
            functions -e _usage
            return 1
        end
    end

    # ── dispatch ──────────────────────────────────────────────────────────
    if set -q _flag_system
        if not set -q _flag_single
            yay -Qq \
                | fzf $fzf_opts \
                | xargs -ro yay -Rns
        else
            yay -Rns "$argv[1]"
        end

    else if set -q _flag_flatpak
        if not set -q _flag_single
            flatpak list --app --columns=application \
                | fzf $fzf_opts \
                | xargs -ro -n1 flatpak uninstall
            # only purge unused runtimes if fzf pipeline succeeded
            if test $pipestatus[3] -eq 0
                flatpak uninstall -y --unused
            end
        else
            flatpak uninstall "$argv[1]"
            flatpak uninstall -y --unused
        end
    end

    functions -e _usage
end
