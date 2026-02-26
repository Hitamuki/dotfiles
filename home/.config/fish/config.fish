if status is-interactive
    # OSを検知してパスを追加
    switch (uname)
        case Darwin
            # macOS
            fish_add_path /opt/homebrew/bin
        case Linux
            # Linux
            fish_add_path /home/linuxbrew/.linuxbrew/bin
    end

    # starshipの初期化
    if command -v starship >/dev/null 2>&1
        starship init fish | source
    end

    # すでにtmux内でなければtmuxを起動
    # if not set -q TMUX
    #     tmux attach-session -t default ^/dev/null; or tmux new-session -s default
    # end
end
