# zoxide — smart cd replacement
# Overrides cd so 'cd <fuzzy>' navigates using zoxide's frecency database
if command -q zoxide
    zoxide init fish --cmd cd | source
end
