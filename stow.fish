#!/usr/bin/env fish

for dir in (eza --color=never --only-dirs)
	stow $dir
end
