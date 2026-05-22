function compress --description "Make archives"

    function _usage
        printf "Usage: compress <archive> <source> [source ...]\n\n"
        printf "Arguments:\n"
        printf "  archive    Output filename — extension determines format\n"
        printf "  source     One or more files or directories to compress\n\n"
        printf "Supported formats:\n"
        printf "  *.tar             Uncompressed tape archive\n"
        printf "  *.tar.gz, *.tgz   Gzip-compressed archive\n"
        printf "  *.tar.bz2         Bzip2-compressed archive\n"
        printf "  *.tar.xz          XZ-compressed archive (best compression)\n"
        printf "  *.tar.zst         Zstandard-compressed archive (best speed)\n"
        printf "  *.zip             Zip archive\n"
        printf "  *.7z              7-Zip archive\n\n"
        printf "Options:\n"
        printf "  -v, --verbose     Show files as they are compressed\n"
        printf "  -h, --help        Show this help\n\n"
        printf "Examples:\n"
        printf "  compress backup.tar.gz file.txt myfolder/\n"
        printf "  compress project.zip src/ README.md\n"
        printf "  compress -v archive.tar.xz src/\n"
    end

    # ── parse flags ───────────────────────────────────────────────────────
    argparse h/help v/verbose -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        _usage
        functions -e _usage
        return 0
    end

    # ── require archive + at least one source ─────────────────────────────
    if test (count $argv) -lt 2
        printf "compress: at least one source required\n\n"
        _usage
        functions -e _usage
        return 1
    end

    set -l dest    "$argv[1]"
    set -l sources $argv[2..-1]

    # ── validate all sources exist before touching the filesystem ─────────
    set -l missing 0
    for src in $sources
        if not test -e "$src"
            printf "compress: source not found: '%s'\n" "$src"
            set missing 1
        end
    end
    if test $missing -eq 1
        functions -e _usage
        return 1
    end

    # ── verbose flag ──────────────────────────────────────────────────────
    set -l v ""
    set -q _flag_verbose && set v v

    # ── compress ──────────────────────────────────────────────────────────
    switch "$dest"
        case '*.tar'
            tar -c{$v}f "$dest" $sources
        case '*.tar.gz' '*.tgz'
            tar -c{$v}zf "$dest" $sources
        case '*.tar.bz2'
            tar -c{$v}jf "$dest" $sources
        case '*.tar.xz'
            tar -c{$v}Jf "$dest" $sources
        case '*.tar.zst'
            tar -c{$v} --zstd -f "$dest" $sources
        case '*.zip'
            set -l zip_v ""
            set -q _flag_verbose && set zip_v "-v"
            zip -r $zip_v "$dest" $sources
        case '*.7z'
            set -l sz_v "-bd"
            set -q _flag_verbose && set sz_v ""
            7z a $sz_v "$dest" $sources
        case '*'
            printf "compress: unsupported format '%s'\n\n" "$dest"
            _usage
            functions -e _usage
            return 1
    end

    functions -e _usage
end