# Homebrewパッケージ削除コマンドリスト

このドキュメントには、Nix/Home Managerに移行したため削除可能なHomebrewパッケージの削除コマンドを記載しています。

**注意**: これらのコマンドは実行前に、Nix/Home Managerの設定が正しく動作することを確認してください。

## 削除前の確認事項

1. Home Managerの設定が正しく適用されているか確認
   ```bash
   home-manager switch
   ```

2. 各ツールがNixで管理されていることを確認
   ```bash
   which git
   which go
   which yarn
   which aws
   which python3
   ```

3. zshプラグインが正しく動作しているか確認
   - zsh-autosuggestions
   - zsh-completions
   - syntax highlighting

## 削除コマンド

### zshプラグイン

```bash
brew uninstall zsh-autosuggestions
brew uninstall zsh-completions
brew uninstall zsh-git-prompt
```

### 開発ツール

```bash
# Git
brew uninstall git

# Go
brew uninstall go

# Yarn
brew uninstall yarn

# AWS CLI
brew uninstall awscli

# Python 3.13
brew uninstall python@3.13
```

### 一括削除コマンド

すべてのパッケージを一度に削除する場合：

```bash
brew uninstall zsh-autosuggestions zsh-completions zsh-git-prompt git go yarn awscli python@3.13
```

## 削除しないパッケージ

以下のパッケージは移行不要のため、Homebrewで継続管理します：

- `hugo` - 移行不要
- `imagemagick` - 移行不要
- `pyenv` - 移行不要
- `node` - NVMで管理するため移行不要
- `nodebrew` - NVMで管理するため移行不要
- `autoconf` - 開発ツール、移行不要
- `libtool` - 開発ツール、移行不要
- `m4` - 開発ツール、移行不要
- `pkgconf` - 開発ツール、移行不要

## 削除後の確認

削除後、以下のコマンドで動作確認を行ってください：

```bash
# 各ツールのバージョン確認
git --version
go version
yarn --version
aws --version
python3 --version

# zshプラグインの動作確認
# 新しいターミナルを開いて、自動補完と自動提案が動作するか確認
```

## トラブルシューティング

### ツールが見つからない場合

1. Home Managerの設定を再適用
   ```bash
   home-manager switch
   ```

2. シェルを再起動
   ```bash
   exec zsh
   ```

3. PATHを確認
   ```bash
   echo $PATH
   # ~/.nix-profile/bin が含まれていることを確認
   ```

### プラグインが動作しない場合

1. Home Managerのzsh設定を確認
   ```bash
   cat ~/.config/home-manager/home.nix
   ```

2. zshの設定を再読み込み
   ```bash
   source ~/.zshrc
   ```
