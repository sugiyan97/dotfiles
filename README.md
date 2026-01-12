# dotfiles

## リポジトリ構造

```text
dotfiles/
├── README.md
├── zsh/
│   ├── .zshrc
│   ├── .zprofile
│   └── .zshenv
└── git/
    └── .gitmessage
```

## セットアップ

### Nix のインストールと設定

```bash
# Nix のインストール
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# .nix-profile シンボリックリンクの作成
ln -sf /nix/var/nix/profiles/default ~/.nix-profile

# 設定ファイルをリンク後、動作確認
source ~/.zprofile
nix --version
```

> 注意: Nix の初期化スクリプトは `zsh/.zprofile` に含まれています。設定ファイルをリンクすれば自動的に読み込まれます。

### 設定ファイルのリンク

```bash
# リポジトリのパスを設定（適宜変更してください）
DOTFILES_DIR="$HOME/Desktop/work/repositories/dotfiles"

# 既存のファイルをバックアップ（必要に応じて）
[ -f ~/.zprofile ] && mv ~/.zprofile ~/.zprofile.bak
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak
[ -f ~/.zshenv ] && mv ~/.zshenv ~/.zshenv.bak

# シンボリックリンクを作成
ln -sf "$DOTFILES_DIR/zsh/.zprofile" ~/.zprofile
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/zsh/.zshenv" ~/.zshenv
ln -sf "$DOTFILES_DIR/git/.gitmessage" ~/.gitmessage

# Git の設定
git config --global commit.template ~/.gitmessage
```

### 参考

> https://github.com/KoharaKazuya/dotfiles/blob/17610bef860cf957b7219970b1a93dce98dadbfd/.gitmessage
