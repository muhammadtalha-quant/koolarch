function lnk --description "Create symbolic or hard links"

    function _usage
        printf "Usage: lnk -t <target> [options]\n\n"
        printf "Creates a link to <target>. Defaults to a symbolic link in the current directory.\n\n"
        printf "Options:\n"
        printf "  -t, --target <path>      File or directory the link will point to (required)\n"
        printf "  -d, --directory <path>   Directory where the link is created (default: .)\n"
        printf "  -s, --soft               Create a symbolic link (default)\n"
        printf "  -h, --hard               Create a hard link\n"
        printf "  --help                   Show this help\n\n"
        printf "Examples:\n"
        printf "  lnk -t /etc/hosts                         Symlink in current dir\n"
        printf "  lnk -t /etc/hosts -d ~/links              Symlink in ~/links\n"
        printf "  lnk --hard -t /etc/hosts -d ~/links       Hard link in ~/links\n"
    end

    # ── parse flags ───────────────────────────────────────────────────────
    set -l options s/soft h/hard t/target d/directory help
    argparse $options -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -gt 0
        # no positional args expected; any argv means user is confused
        test (count $argv) -gt 0 && printf "lnk: unexpected argument '%s'\n\n" "$argv[1]"
        _usage
        functions -e _usage
        return 0
    end

    # ── target is required ────────────────────────────────────────────────
    if not set -q _flag_target
        printf "lnk: --target is required\n\n"
        _usage
        functions -e _usage
        return 1
    end

    # ── mutual exclusivity ────────────────────────────────────────────────
    if set -q _flag_soft; and set -q _flag_hard
        printf "lnk: --soft and --hard are mutually exclusive\n\n"
        _usage
        functions -e _usage
        return 1
    end

    # ── default to soft ───────────────────────────────────────────────────
    if not set -q _flag_hard
        set _flag_soft 1
    end

    set -l target "$_flag_target"
    set -l dir .
    set -q _flag_directory && set dir "$_flag_directory"

    # ── validate target exists ────────────────────────────────────────────
    if not test -e "$target"
        printf "lnk: target '%s' does not exist\n" "$target"
        functions -e _usage
        return 1
    end

    # ── hard links can't target directories ───────────────────────────────
    if set -q _flag_hard; and test -d "$target"
        printf "lnk: hard links to directories are not supported\n"
        functions -e _usage
        return 1
    end

    # ── create destination directory if needed ────────────────────────────
    if not test -d "$dir"
        mkdir -p "$dir"
        or begin
            printf "lnk: failed to create directory '%s'\n" "$dir"
            functions -e _usage
            return 1
        end
    end

    # ── derive link path ──────────────────────────────────────────────────
    set -l link_name (basename "$target")
    set -l link_path "$dir/$link_name"

    # ── guard against overwrite ───────────────────────────────────────────
    if test -e "$link_path"
        printf "lnk: '%s' already exists\n" "$link_path"
        functions -e _usage
        return 1
    end

    # ── create link ───────────────────────────────────────────────────────
    if set -q _flag_soft
        ln -s "$target" "$link_path"
        and printf "lnk: symlink '%s' -> '%s'\n" "$link_path" "$target"
    else
        ln "$target" "$link_path"
        and printf "lnk: hard link '%s' -> '%s'\n" "$link_path" "$target"
    end

    functions -e _usage
end