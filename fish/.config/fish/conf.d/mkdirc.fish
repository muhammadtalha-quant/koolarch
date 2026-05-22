function mkdirc --description "Create directory and then switch to it"
    set -l path "$argv[1]"
    # @fish-lsp-disable-next-line 7001
    mkdir -p $path && cd $path
end