set PATH $HOME/.cargo/bin \
    $HOME/.local/bin \
    $HOME/.ghcup/bin \
    $HOME/.cabal/bin \
    $HOME/.emacs.d/bin \
    $HOME/.uxn/scripts \
    /usr/local/opt/llvm/bin \
    /usr/local/bin/sbin \
    /usr/sbin \
    /sbin \
    $PATH

set -x CPATH $DEVKITPRO/libtonc/include \
    $DEVKITPRO/libgba/include \
    $CPATH

#set -x ROS_DOMAIN_ID 42
#bass source /opt/ros/iron/setup.bash

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

    # kakoune utility
    function kaki
        set -l sessions (kak -c)
        if test -z "$sessions"
            kak $argv
        else
            kak -c (echo $sessions | head -n 1) $argv
        end
    end

    # ls utilities
    function ls
        exa $argv
    end
    function la
        exa -la $argv
    end
    function lw
        exa -l -smodified $argv
    end
    function l
        exa -l $argv
    end
    function sl
        /usr/sbin/sl -ac2 | lolcat -F 0.001
    end

    function _navi_smart_replace
        set -l current_process (commandline -p | string trim)

        if test -z "$current_process"
            commandline -i (navi --print)
        else
            set -l best_match (navi --print --best-match --query "$current_process")

            if not test "$best_match" >/dev/null
                return
            end

            if test -z "$best_match"
                commandline -p (navi --print --query "$current_process")
            else if test "$current_process" != "$best_match"
                commandline -p $best_match
            else
                commandline -p (navi --print --query "$current_process")
            end
        end

        commandline -f repaint
    end

    function kakill
        echo kill | kak -p $ZELLIJ_SESSION_NAME
    end

    if test $fish_key_bindings = fish_default_key_bindings
        bind \cg _navi_smart_replace
    else
        bind -M insert \cn _navi_smart_replace
    end

    # abbreviations
    abbr -a hx helix
    abbr -a qt QT_QPA_PLATFORM=xcb
    abbr -a kaks kak -d -s \$ZELLIJ_SESSION_NAME \&
    abbr -a kak kak -c \$ZELLIJ_SESSION_NAME
    abbr -a kakn kak
    
    starship init fish | source

    function __hoard_list
        set hoard_command (hoard --autocomplete list 3>&1 1>&2 2>&3)
        commandline -j $hoard_command
    end

    if ! set -q DISPLAY
       set HOARD_NOBIND t
    end

    if ! set -q HOARD_NOBIND
        bind -M insert \ch __hoard_list
        bind \ch __hoard_list
    end

    fastfetch
end
