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

```bash
# Linux
home-manager switch --flake '.#mince'

# macOS
sudo darwin-rebuild switch --flake '.#mince-mac'
```

## ディレクトリ構成

```
.
├── flake.nix
├── flake.lock
├── nix-darwin/              # nix-darwin システム設定 (macOS 専用)
│   ├── default.nix
│   └── homebrew.nix
├── home/                    # home-manager ユーザー設定
│   ├── common.nix           # 全環境共通 (claude, agent-skills, zsh, starship, zoxide, fzf, mise)
│   ├── linux.nix            # Linux 固有
│   └── darwin.nix           # macOS 固有
└── modules/
    ├── claude.nix           # 共通
    ├── agent-skills.nix     # 共通
    └── niri/                # Linux Wayland 環境
        ├── default.nix
        ├── common.nix
        ├── clock-rs.nix
        ├── inir.nix
        ├── noctalia-shell.nix
        ├── xremap.nix
        ├── zen-browser.nix
        └── shells/
            ├── inir.nix
            └── noctalia.nix
```

## モジュール

| モジュール | common | linux | darwin |
|---|---|---|---|
| `claude.nix` | ✅ | | |
| `agent-skills.nix` | ✅ | | |
| `niri/xremap.nix` | | ✅ | |
| `niri/clock-rs.nix` | | ✅ | |
| `niri/zen-browser.nix` | | ✅ | |
| `niri/` (compositor) | | ✅ | |
| `niri/noctalia-shell.nix` | | ✅ | |
| `niri/inir.nix` | | ✅ | |
