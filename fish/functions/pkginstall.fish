function pkginstall --description "Browse and mark packages for installation"

    # ── inner helper, erased on exit ─────────────────────────────────────
    function _usage
        printf "Usage: pkginstall <provider> [option]\n\n"
        printf "Providers:\n"
        printf "  -R, --repo           Browse pacman repositories\n"
        printf "  -A, --aur            Browse the Arch User Repository\n"
        printf "                       ^B: preview PKGBUILD | M-B: package info\n"
        printf "  -F, --flathub        Browse Flathub\n\n"
        printf "Options:\n"
        printf "  -s, --single <pkg>   Install <pkg> directly from the <provider>, skip fzf menu\n"
        printf "  -h, --help           Show this help\n\n"
        printf "Keybinds (fzf):\n"
        printf "  TAB                  Mark/unmark package\n"
        printf "  ENTER                Install selected\n"
        printf "  Up/Down              Scroll list\n"
    end

    # ── parse ─────────────────────────────────────────────────────────────
    set -l fzf_opts --layout=reverse-list --multi --preview-window=down:60%
    set -l options R/repo A/aur F/flathub s/single h/help
    argparse $options -- $argv
    or return 1

    # ── help ──────────────────────────────────────────────────────────────
    if set -q _flag_help
        _usage
        functions -e _usage
        return 0
    end

    # ── require exactly one provider ──────────────────────────────────────
    set -l provider_count 0
    set -q _flag_repo    && set provider_count (math $provider_count + 1)
    set -q _flag_aur     && set provider_count (math $provider_count + 1)
    set -q _flag_flathub && set provider_count (math $provider_count + 1)

    if test $provider_count -eq 0
        printf "error: a provider is required\n\n"
        _usage
        functions -e _usage
        return 1
    end

    if test $provider_count -gt 1
        printf "error: only one provider may be specified at a time\n\n"
        _usage
        functions -e _usage
        return 1
    end

    # ── --single requires a package name in argv ──────────────────────────
    if set -q _flag_single
        if test (count $argv) -eq 0
            printf "error: --single requires a package name\n"
            functions -e _usage
            return 1
        end
    end

    # ── dispatch ──────────────────────────────────────────────────────────
    if set -q _flag_repo
        if not set -q _flag_single
            pacman -Slq \
                | fzf $fzf_opts \
                    --preview 'pacman -Sii {1}' \
                    --header 'ENTER: Install | TAB: Select | Up/Down: Scroll' \
                | xargs -ro sudo pacman -S --needed
        else
            sudo pacman -S --needed "$argv[1]"
        end

    else if set -q _flag_aur
        if not set -q _flag_single
            yay -Slq --aur \
                | fzf $fzf_opts \
                    --preview 'yay -Sii --aur {1}' \
                    --bind 'ctrl-b:preview(yay -Gp {1})' \
                    --bind 'alt-b:preview(yay -Sii {1})' \
                    --header 'ENTER: Install | TAB: Select | ^B: PKGBUILD | M-B: Info' \
                | xargs -ro yay -S --aur --needed
        else
            yay -S --aur --needed "$argv[1]"
        end

    else if set -q _flag_flathub
        if not set -q _flag_single
            flatpak remote-ls flathub --app --columns=application \
                | fzf $fzf_opts \
                    --preview 'flatpak remote-info flathub {1}' \
                    --header 'ENTER: Install | TAB: Select | Up/Down: Scroll' \
                | xargs -ro -n1 flatpak install flathub --or-update
        else
            flatpak install flathub --or-update "$argv[1]"
        end
    end

    functions -e _usage
end