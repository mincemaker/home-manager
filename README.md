# home-manager

home-manager + nix-darwin によるモノレポ構成。Linux (CachyOS) と macOS (MacBook) を単一リポジトリで管理する。

## 構成

| ホスト | OS | アーキテクチャ | エントリ |
|---|---|---|---|
| Linux desktop | CachyOS (non-NixOS) | x86_64-linux | `homeConfigurations."mince"` |
| MacBook | macOS | aarch64-darwin | `darwinConfigurations."mince-mac"` |

## セットアップ

### Linux

Nix がインストール済みであること。

```bash
# home-manager のインストール（初回のみ）
nix run home-manager -- init --flake '.#mince'

# 適用
home-manager switch --flake '.#mince'
```

#### 新規マシンでのセットアップ（一度きり）

niri のシェルである iNiR と、home-manager が管理しないその他の dotfiles（dotfiles_new / chezmoi 管理）は home-manager の管轄外。新しい Linux マシンでは次の順で導入する（iNiR の `setup install` が niri の `config.d/*.kdl` を書き換えるため、dotfiles_new の chezmoi apply は必ず後に行う）。

```bash
mise run setup-linux-inir       # home-manager switch → iNiR clone + setup install
mise run setup-linux-dotfiles   # ↑ に続けて dotfiles_new clone + chezmoi apply
```

### macOS

#### 初回セットアップ

```bash
# 1. Nix のインストール（Determinate Systems 推奨）
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. nix-darwin のインストール
nix run nix-darwin -- switch --flake '/Users/mince/development/home-manager#mince-mac'

# 3. 以降は darwin-rebuild を使用
sudo darwin-rebuild switch --flake '.#mince-mac'
```

## 適用コマンド

[mise](https://mise.jdx.dev/) のタスクランナーを使うと簡単に実行できる。

```bash
# macOS
mise run switch-mac   # 設定を適用
mise run update-mac   # flake を更新して適用
mise run check-mac    # ドライラン（変更内容の確認のみ）

# Linux
mise run switch-linux  # 設定を適用
mise run update-linux  # flake を更新して適用

# Linux 新規マシンのみ（一度きり）
mise run setup-linux-inir       # iNiR (niri shell) の clone + install
mise run setup-linux-dotfiles   # dotfiles_new の clone + chezmoi apply

# 共通
mise run gc            # 古い世代を削除（7日以上前）
```

mise を使わない場合:

```bash
# Linux
home-manager switch --flake '.#mince'

# macOS
sudo darwin-rebuild switch --flake '.#mince-mac'
```

## AI Agent Skills

このリポジトリには AI エージェント Claude 向けの管理スキルが含まれています。
[APM (Agent Package Manager)](https://github.com/microsoft/apm) を使用して、プロジェクトスキルとしてインストールできます。

```bash
# スキルのインストール（初回および更新時）
apm install
```

これにより、`.claude/skills/` にこのリポジトリ専用の管理ガイドが配置され、エージェントがリポジトリの構造やルールを理解できるようになります。

## ディレクトリ構成

```
.
├── flake.nix
├── flake.lock
├── nix-darwin/              # nix-darwin システム設定 (macOS 専用)
│   ├── default.nix
│   └── homebrew.nix
├── home/                    # home-manager ユーザー設定
│   ├── common.nix           # 全環境共通シェル・CLI ツール設定
│   ├── linux.nix            # Linux 固有
│   └── darwin.nix           # macOS 固有
└── modules/
    ├── agent-skills.nix     # 共通（Linux は flake.nix 経由、macOS は darwin.nix 経由で有効化）
    ├── antigravity-cli.nix  # 共通
    ├── cage.nix             # 共通
    ├── claude.nix           # 共通
    ├── guard-and-guide.nix  # 共通
    ├── hunk.nix             # 共通
    ├── macskk.nix           # macOS 固有
    ├── plamo-translate.nix  # macOS 固有
    ├── tmux.nix             # 共通
    ├── yaskkserv2.nix       # Linux / macOS 個別 import（common.nix 経由ではない）
    └── niri/                # Linux Wayland 環境（niri 本体・iNiR の設定は dotfiles_new / iNiR 側が管理）
        ├── xremap.nix
        ├── clock-rs.nix
        ├── zen-browser.nix
        └── arto.nix
```

## モジュール

| モジュール | common | linux | darwin |
|---|---|---|---|
| `agent-skills.nix` | ✅ | | |
| `antigravity-cli.nix` | ✅ | | |
| `cage.nix` | ✅ | | |
| `claude.nix` | ✅ | | |
| `guard-and-guide.nix` | ✅ | | |
| `hunk.nix` | ✅ | | |
| `tmux.nix` | ✅ | | |
| `yaskkserv2.nix` | | ✅ | ✅ |
| `macskk.nix` | | | ✅ |
| `plamo-translate.nix` | | | ✅ |
| `niri/xremap.nix` | | ✅ | |
| `niri/clock-rs.nix` | | ✅ | |
| `niri/zen-browser.nix` | | ✅ | |
| `niri/arto.nix` | | ✅ | |
