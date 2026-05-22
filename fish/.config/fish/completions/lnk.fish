complete -c lnk -f
complete -c lnk -s t -l target    -d 'File or directory the link will point to' -r -F
complete -c lnk -s d -l directory -d 'Directory where the link will be created' -r -F
complete -c lnk -s s -l soft      -d 'Create a symbolic link (default)'
complete -c lnk -s h -l hard      -d 'Create a hard link'
complete -c lnk      -l help      -d 'Show help'