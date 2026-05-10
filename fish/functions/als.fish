function als --description "List archive contents"

    function _usage
        printf "Usage: als <archive>\n\n"
        printf "Lists archive contents without extracting.\n\n"
        printf "Supported formats:\n"
        printf "  *.tar              Uncompressed tape archive\n"
        printf "  *.tar.gz, *.tgz   Gzip-compressed archive\n"
        printf "  *.tar.bz2         Bzip2-compressed archive\n"
        printf "  *.tar.xz          XZ-compressed archive\n"
        printf "  *.tar.zst         Zstandard-compressed archive\n"
        printf "  *.gz              Single-file gzip\n"
        printf "  *.bz2             Single-file bzip2\n"
        printf "  *.zip             Zip archive\n"
        printf "  *.7z              7-Zip archive\n"
        printf "  *.rar             RAR archive\n\n"
        printf "Options:\n"
        printf "  -h, --help        Show this help\n\n"
        printf "Examples:\n"
        printf "  als archive.tar.gz\n"
        printf "  als project.zip\n"
    end

    # ── parse flags ───────────────────────────────────────────────────────
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        _usage
        functions -e _usage
        return 0
    end

    # ── argument count guard ──────────────────────────────────────────────
    if test (count $argv) -gt 1
        printf "als: too many arguments\n\n"
        _usage
        functions -e _usage
        return 1
    end

    set -l file "$argv[1]"

    # ── validate file ─────────────────────────────────────────────────────
    if not test -f "$file"
        printf "als: '%s' is not a file\n" "$file"
        functions -e _usage
        return 1
    end

    # ── list ──────────────────────────────────────────────────────────────
    switch "$file"
        case '*.tar'
            tar -tf "$file"
        case '*.tar.gz' '*.tgz'
            tar -tzf "$file"
        case '*.tar.bz2'
            tar -tjf "$file"
        case '*.tar.xz'
            tar -tJf "$file"
        case '*.tar.zst'
            tar --zstd -tf "$file"
        case '*.gz'
            printf "als: single-file gzip — compressed name: %s\n" "$file"
            gunzip -l "$file"
        case '*.bz2'
            printf "als: single-file bzip2: %s\n" (basename "$file" .bz2)
        case '*.zip'
            unzip -l "$file"
        case '*.7z'
            7z l "$file"
        case '*.rar'
            unrar l "$file"
        case '*'
            printf "als: unsupported format '%s'\n" "$file"
            functions -e _usage
            return 1
    end

    functions -e _usage
end