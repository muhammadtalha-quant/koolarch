set -U fish_greeting
if status is-interactive
    fastfetch
    load_prompt
end
