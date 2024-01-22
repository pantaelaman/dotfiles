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

set -x CPATH $DEVKITPRO/libtonc/include \
    $DEVKITPRO/libgba/include \
    $CPATH

if status is-interactive
    source ~/.config/fish/themes/kanagawa.fish
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

    # ls utilities
    function ls
        exa $argv
    end
    function la
        exa -la $argv
    end
    function l
        exa -l $argv
    end

    # abbreviations
    abbr -a hx helix
    
    starship init fish | source

    function __hoard_list
        set hoard_command (hoard --autocomplete list 3>&1 1>&2 2>&3)
        commandline -j $hoard_command
    end

    if ! set -q HOARD_NOBIND
        bind -M insert \ch __hoard_list
        bind \ch __hoard_list
    end

    neofetch
end
