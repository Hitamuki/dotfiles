# 本体は .config/bash/.bashrc に配置（zshの ZDOTDIR 方式と統一するための薄いshim）
[ -f "$HOME/.config/bash/.bashrc" ] && source "$HOME/.config/bash/.bashrc"
