if status is-interactive
    # Commands to run in interactive sessions can go here

    fish_add_path /opt/homebrew/bin

    # starshipの初期化
    starship init fish | source

    # すでにtmux内でなければtmuxを起動
    if not set -q TMUX
        tmux attach-session -t default ^/dev/null; or tmux new-session -s default
    end
end


# Added by Antigravity
fish_add_path $HOME/.antigravity/antigravity/bin

string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)
