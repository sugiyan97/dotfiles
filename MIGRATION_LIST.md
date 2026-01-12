# Nix移行対象一覧

インベントリファイル（`/Users/yoshiyukisugiyama3/nix_migration_inventory`）の内容を分析し、現在のdotfilesリポジトリに移行すべき項目を一覧化しました。

## 現在のdotfilesリポジトリの状態

現在管理されている設定：

- `zsh/.zshrc` - zsh設定（PATH、brew依存のプラグイン、プロンプト設定）
- `zsh/.zprofile` - 環境変数、brew、NVM、Nix初期化（OrbStackは移行不要）
- `zsh/.zshenv` - Cargo環境設定
- `git/.gitmessage` - Gitコミットメッセージテンプレート

## 移行すべき項目の一覧

### 1. Homebrewパッケージ

#### 主要な開発ツール（移行対象）

- `awscli` - AWS CLI
- `git` - Git
- `go` - Go言語
- `yarn` - Yarnパッケージマネージャー
- `nvm` - Node Version Manager（設定維持）
- `python@3.13` - Python 3.13

#### zsh関連プラグイン（現在brew依存、Nix移行対象）

- `zsh-autosuggestions` - `.zshrc`で使用中
- `zsh-completions` - `.zshrc`で使用中
- `zsh-git-prompt` - `.zshrc`で使用中

#### 移行不要（ユーザー指定）

- `hugo` - 移行不要
- `imagemagick` - 移行不要
- `pyenv` - 移行不要
- `node` - NVMで管理するため移行不要
- `nodebrew` - NVMで管理するため移行不要
- `autoconf` - 開発ツール、移行不要
- `libtool` - 開発ツール、移行不要
- `m4` - 開発ツール、移行不要
- `pkgconf` - 開発ツール、移行不要

#### その他の依存パッケージ

- 画像処理ライブラリ（aom, brotli, giflib等、imagemagick関連は移行不要）
- 言語ランタイム（go, python@3.13）
- 注意: `node`はNVMで管理するため移行不要
- 注意: 開発ツール（autoconf, libtool, m4, pkgconf）は移行不要

### 2. PATH設定の整理

#### 現在のPATH（`current_path.txt`より）

- `/Users/yoshiyukisugiyama3/.nix-profile/bin` - Nix
- `/Users/yoshiyukisugiyama3/.nvm/versions/node/v23.5.0/bin` - NVM
- `/Library/Frameworks/Python.framework/Versions/3.11/bin` - Python 3.11（3.13に変更予定）
- `/opt/homebrew/bin`, `/opt/homebrew/sbin` - Homebrew
- `/Users/yoshiyukisugiyama3/.local/bin` - ローカルbin
- `/Users/yoshiyukisugiyama3/.cargo/bin` - Cargo
- `/Users/yoshiyukisugiyama3/.orbstack/bin` - OrbStack（移行不要）

#### 現在の`.zshrc`と`.zprofile`のPATH設定との差分

- `.zprofile`にPython 3.11のPATHが記載されているが、Python 3.13に変更予定
- NVMのPATHが動的に追加されるが、`.zprofile`で管理されている
- `.nix-profile/bin`がPATHに含まれているが、`.zprofile`でNix初期化後に自動追加される
- OrbStackのPATHは移行不要（`.zprofile`から削除予定）

### 3. 環境変数とツール設定

#### NVM設定

- `.zprofile`でNVM_DIRとnvm.shの読み込みが設定済み
- `npm_global.txt`にグローバルパッケージ: `corepack@0.30.0`, `npm@10.9.2`, `pnpm@10.14.0`, `typescript@5.9.2`
- NVMの設定は維持（node/nodebrewはNVMで管理）

#### Cargo設定

- `.zshenv`でCargo環境が設定済み
- `Brewfile.backup`に`cargo "tauri-cli"`が記載

#### Python設定

- `.zprofile`にPython 3.11のPATH設定があるが、Python 3.13に変更予定
- `brew_formulas.txt`には`python@3.13`が記載
- `pyenv`は移行不要（ユーザー指定）

#### OrbStack設定

- `.zprofile`でOrbStackの初期化スクリプトが読み込まれているが、移行不要（ユーザー指定）

### 4. VSCode拡張機能（移行不要）

現時点では移行不要（ユーザー指定）

参考: `anthropic.claude-code`, `bradlc.vscode-tailwindcss`, `davidanson.vscode-markdownlint`, `dbaeumer.vscode-eslint`, `docker.docker`, `eamodio.gitlens`, `esbenp.prettier-vscode`, `github.copilot`, `github.copilot-chat`, `golang.go`, `gruntfuggly.todo-tree`, `ms-azuretools.vscode-containers`, `ms-azuretools.vscode-docker`, `ms-ceintl.vscode-language-pack-ja`, `ms-vscode-remote.remote-containers`, `ms-vscode.live-server`, `tomoki1207.pdf`

### 5. Goツール（移行しない）

Go installパッケージはNixに移行せず、従来通り`go install`で管理します。

元のリスト（参考）：
- `github.com/go-delve/delve/cmd/dlv`
- `github.com/golangci/golangci-lint/cmd/golangci-lint`
- `github.com/fatih/gomodifytags`
- `github.com/haya14busa/goplay/cmd/goplay`
- `golang.org/x/tools/gopls`
- `github.com/cweill/gotests/gotests`
- `github.com/josharian/impl`
- `honnef.co/go/tools/cmd/staticcheck`

### 6. 設定ディレクトリ（config_dirs.txtより）

- `~/.config/configstore` - アプリケーション設定ストア
- `~/.config/home-manager` - Home Manager設定（Nix）
- `~/.config/nix` - Nix設定
- `~/.config/raycast` - Raycast設定

### 7. シンボリックリンク（symlinks.txtより）

#### 既に管理されているもの

- `~/.gitmessage` → `dotfiles/git/.gitmessage` ✓

#### Nix関連

- `~/.nix-profile` → `/nix/var/nix/profiles/default` ✓（README.mdに記載済み）

#### その他

- `~/Dropbox` → `/Users/yoshiyukisugiyama3/Library/CloudStorage/Dropbox`（dotfiles管理外）

## 優先度別の移行推奨事項

### 高優先度（現在の設定に直接影響）

#### 1. zshプラグインのNix移行

- `zsh-autosuggestions`, `zsh-completions`, `zsh-git-prompt`をNixで管理
- `.zshrc`のbrew依存を削除

#### 2. PATH設定の整理

- Python 3.11から3.13への変更（`.zprofile`のPATH設定を更新）
- Nixで管理するパスと従来のパスの優先順位を明確化
- OrbStackのPATH設定を削除（移行不要）

#### 3. 開発ツールのNix移行

- `git`, `go`, `yarn`, `awscli`など主要ツールをNixで管理
- 除外: `hugo`, `imagemagick`, `node`, `nodebrew`, `autoconf`, `libtool`, `m4`, `pkgconf`（ユーザー指定、node/nodebrewはNVMで管理）

### 中優先度（機能追加）

#### 4. NVMの維持

- `node`と`nodebrew`はNVMで管理するため移行不要
- NVMの設定（`.zprofile`）は維持

#### 5. Python環境の整理

- Python 3.13に統一（`.zprofile`のPython 3.11のPATH設定を3.13に変更）
- `pyenv`は移行不要（ユーザー指定）

### 低優先度（参考情報）

#### 6. 設定ディレクトリ

- Home Manager設定はNix移行時に自動生成される可能性
- その他の設定は必要に応じて

## 次のステップ

1. 一覧化された項目を確認
2. Nix移行の範囲を決定（完全移行 vs 併用）
3. 優先度に基づいて段階的に移行
4. 各項目の移行方法を検討（Home Manager使用など）
