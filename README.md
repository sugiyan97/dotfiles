# dotfiles

## リポジトリ構造

```text
dotfiles/
├── README.md
├── flake.nix
├── home.nix
├── .gitignore
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

# .nix-profile シンボリックリンクの作成（ユーザー専用プロファイルを使用）
# 権限エラーを避けるため、ユーザー専用のプロファイルを使用します
mkdir -p /nix/var/nix/profiles/per-user/$(whoami)
ln -sfn /nix/var/nix/profiles/per-user/$(whoami)/profile ~/.nix-profile

# 設定ファイルをリンク後、動作確認
source ~/.zprofile
source ~/.zshrc
nix --version
```

> 注意: Nix の初期化スクリプトは `zsh/.zprofile` に含まれています。設定ファイルをリンクすれば自動的に読み込まれます。
> 
> **権限エラーが発生する場合**: `~/.nix-profile`が`/nix/var/nix/profiles/default`（root所有）を指している場合、上記のコマンドでユーザー専用プロファイルに変更してください。

### Home Manager のセットアップ（Flakeモード）

```bash
# リポジトリのパスを設定（適宜変更してください）
DOTFILES_DIR="$HOME/Desktop/work/repositories/dotfiles"

# 権限エラーが発生する場合は、まずユーザー専用プロファイルに変更
# （上記の「Nix のインストールと設定」セクションを参照）

# FlakeモードでHome Managerの設定を適用
cd "$DOTFILES_DIR"
nix run home-manager/master -- switch --flake .#default
```

**注意**: Flakeモードでは`home-manager`コマンドを直接インストールする必要はありません。`nix run`コマンドで直接実行します。

**初回実行時**: 初回実行時は、Flakeの依存関係をダウンロードするため時間がかかります。

**トラブルシューティング**: `Permission denied`エラーが発生する場合：

1. `~/.nix-profile`が正しく設定されているか確認：
   ```bash
   ls -la ~/.nix-profile
   # ユーザー専用プロファイルを指していることを確認
   # /nix/var/nix/profiles/per-user/$(whoami)/profile を指すべき
   ```

2. ユーザー専用プロファイルに変更：
   ```bash
   mkdir -p /nix/var/nix/profiles/per-user/$(whoami)
   ln -sfn /nix/var/nix/profiles/per-user/$(whoami)/profile ~/.nix-profile
   ```

3. プロファイルディレクトリの権限エラーが発生する場合：
   ```bash
   # ディレクトリの所有権を確認
   ls -la /nix/var/nix/profiles/per-user/$(whoami)
   
   # root所有の場合は、所有権を変更（sudoが必要）
   sudo chown -R $(whoami) /nix/var/nix/profiles/per-user/$(whoami)
   ```

4. `nix-env`でインストールしたパッケージが競合している場合：
   ```bash
   nix-env -q  # インストール済みパッケージを確認
   # 必要に応じて削除（ただし、Nix自体は削除しないでください）
   ```

#### Home Manager で管理されるパッケージ

以下のパッケージは Home Manager で管理されます：

**開発ツール:**
- `git`
- `go`
- `yarn`
- `awscli2`
- `python313`

**zshプラグイン:**
- `zsh-autosuggestions`
- `zsh-completions`
- `syntax-highlighting`

#### Home Manager の設定更新

設定を変更した後は、以下のコマンドで適用します：

```bash
cd "$DOTFILES_DIR"
nix run home-manager/master -- switch --flake .#default
```

**便利なエイリアス**: よく使う場合は、エイリアスを設定すると便利です：

```bash
# .zshrc に追加
alias hm-switch='cd ~/Desktop/work/repositories/dotfiles && nix run home-manager/master -- switch --flake .#default'
```

#### Homebrew パッケージの削除

Nix に移行したパッケージは、Homebrew から削除できます。削除コマンドは `REMOVAL_COMMANDS.md` を参照してください。

**注意**: 削除前に Home Manager の設定が正しく動作することを確認してください。

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
