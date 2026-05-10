function sysupdate --description "Update all packages of the selected domain"

    function _usage
        printf "Usage: sysupdate [scope]\n\n"
        printf "Updates installed packages. Defaults to all scopes if none specified.\n\n"
        printf "Scopes:\n"
        printf "  -s, --system     Update system packages only (pacman + AUR via yay)\n"
        printf "  -f, --flatpak    Update Flatpak apps only, then purge unused runtimes\n\n"
        printf "Options:\n"
        printf "  -h, --help       Show this help\n\n"
        printf "Examples:\n"
        printf "  sysupdate              Update everything\n"
        printf "  sysupdate --system     Update pacman/AUR only\n"
        printf "  sysupdate --flatpak    Update Flatpaks only\n"
    end

    # ── parse flags ───────────────────────────────────────────────────────
    argparse h/help s/system f/flatpak -- $argv
    or return 1

    if set -q _flag_help
        _usage
        functions -e _usage
        return 0
    end

    # ── reject leftover positional arguments ──────────────────────────────
    if test (count $argv) -gt 0
        printf "sysupdate: unexpected argument '%s'\n\n" "$argv[1]"
        _usage
        functions -e _usage
        return 1
    end

    # ── mutual exclusivity ────────────────────────────────────────────────
    if set -q _flag_system; and set -q _flag_flatpak
        printf "sysupdate: --system and --flatpak are mutually exclusive\n\n"
        _usage
        functions -e _usage
        return 1
    end

    # ── helper functions ──────────────────────────────────────────────────
    function _update_system
        yay --noconfirm
    end

    function _update_flatpak
        flatpak update -y
        flatpak uninstall -y --unused
    end

    # ── dispatch ──────────────────────────────────────────────────────────
    if set -q _flag_system
        _update_system
    else if set -q _flag_flatpak
        _update_flatpak
    else
        # default: update everything
        _update_system
        and _update_flatpak
    end

    functions -e _usage _update_system _update_flatpak
end