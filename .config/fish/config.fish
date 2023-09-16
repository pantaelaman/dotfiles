set PATH $HOME/.cargo/bin \
    $HOME/.local/bin \
    $HOME/.ghcup/bin \
    $HOME/.cabal/bin \
    $HOME/.emacs.d/bin \
    /usr/local/opt/llvm/bin \
    /usr/local/bin/sbin \
    /usr/sbin \
    /sbin \
    $PATH

if status is-interactive
    # Commands to run in interactive sessions can go here

    set -g fish_key_bindings fish_vi_key_bindings
    # normal
    bind n backward-char
    bind e down-or-search
    bind i up-or-search
    bind o forward-char
    bind -m insert k repaint-mode
    bind h insert-line-under
    bind H insert-line-over
    # visual
    bind -M visual n backward-char
    bind -M visual e down-or-search
    bind -M visual i up-or-search
    bind -M visual o forward-char
   
    abbr -a hx helix
    starship init fish | source
end
