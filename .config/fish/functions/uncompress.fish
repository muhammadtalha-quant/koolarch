function uncompress --description "Extract archives"

    function _usage
        printf "Usage: uncompress <archive> [destination]\n\n"
        printf "Arguments:\n"
        printf "  archive      Path to the archive file to extract\n"
        printf "  destination  Optional folder to extract into (created if missing)\n"
        printf "               Defaults to current directory if not specified\n\n"
        printf "Supported formats:\n"
        printf "  *.tar             Uncompressed tape archive\n"
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
        printf "  -v, --verbose     Show files as they are extracted\n"
        printf "  -h, --help        Show this help\n\n"
        printf "Examples:\n"
        printf "  uncompress archive.tar.gz\n"
        printf "  uncompress archive.zip ~/projects/myfolder\n"
        printf "  uncompress -v archive.tar.xz /tmp/out\n"
    end

    # ── parse flags ───────────────────────────────────────────────────────
    argparse h/help v/verbose -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        _usage
        functions -e _usage
        return 0
    end

    # ── validate argument count ───────────────────────────────────────────
    if test (count $argv) -gt 2
        printf "uncompress: too many arguments\n"
        functions -e _usage
        return 1
    end

    set -l file "$argv[1]"
    set -l dest .
    if test (count $argv) -eq 2
        set dest "$argv[2]"
    end

    # ── validate archive first, before touching the filesystem ───────────
    if not test -f "$file"
        printf "uncompress: '%s' is not a file\n" "$file"
        functions -e _usage
        return 1
    end

    # ── verbose flag ──────────────────────────────────────────────────────
    set -l v ""
    set -q _flag_verbose && set v v

    # ── create destination only after all validation passes ───────────────
    if test "$dest" != .
        mkdir -p "$dest"
    end

    # ── extract ───────────────────────────────────────────────────────────
    switch "$file"
        case '*.tar'
            tar -x{$v}f "$file" -C "$dest"
        case '*.tar.gz' '*.tgz'
            tar -x{$v}zf "$file" -C "$dest"
        case '*.tar.bz2'
            tar -x{$v}jf "$file" -C "$dest"
        case '*.tar.xz'
            tar -x{$v}Jf "$file" -C "$dest"
        case '*.tar.zst'
            tar -x{$v} --zstd -f "$file" -C "$dest"
        case '*.gz'
            # gunzip extracts in-place; copy to dest first if needed
            if test "$dest" != .
                cp "$file" "$dest/"
                gunzip "$dest/"(basename "$file")
            else
                gunzip "$file"
            end
        case '*.bz2'
            if test "$dest" != .
                cp "$file" "$dest/"
                bunzip2 "$dest/"(basename "$file")
            else
                bunzip2 "$file"
            end
        case '*.zip'
            set -l zip_v ""
            set -q _flag_verbose && set zip_v "-v"
            unzip $zip_v "$file" -d "$dest"
        case '*.7z'
            set -l sz_v "-bd"
            set -q _flag_verbose && set sz_v ""
            7z x $sz_v "$file" -o"$dest"
        case '*.rar'
            set -l rar_v "-idq"
            set -q _flag_verbose && set rar_v ""
            unrar x $rar_v "$file" "$dest/"
        case '*'
            printf "uncompress: unsupported format '%s'\n" "$file"
            functions -e _usage
            return 1
    end

    functions -e _usage
end