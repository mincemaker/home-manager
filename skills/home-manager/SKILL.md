---
name: home-manager
description: >
  Configuration expert for THIS home-manager + nix-darwin repository (mincemaker/home-manager).
  USE THIS SKILL for any task touching this repo's code: adding home-manager modules (programs.*, services.*),
  modifying flake.nix inputs or outputs, understanding common.nix vs darwin.nix vs linux.nix structure,
  troubleshooting darwin-rebuild or home-manager switch errors, or asking where something is configured
  in this repo. Do NOT use for general Nix/NixOS questions outside this specific codebase.
---

# Home-Manager Repository Guide

## Directory Structure

```
flake.nix              # Raw outputs; dual-system (macOS darwinSystem + Linux homeManagerConfiguration)
home/
  common.nix           # Shared config — imported by darwin.nix and linux.nix
  darwin.nix           # macOS home-manager entry point
  linux.nix            # Linux (CachyOS x86_64) entry point
modules/               # Custom home-manager modules — all use programs.* namespace
  claude.nix           # Reference implementation of the module pattern
  agent-skills.nix
  macskk.nix
  yaskkserv2.nix
  niri/                # Linux-only (Niri compositor + related tools)
nix-darwin/
  default.nix          # macOS system entry (darwinSystem), embeds home-manager
  homebrew.nix         # Homebrew packages
```

## Flake Structure

Raw outputs, no flake-parts. All inputs follow `nixpkgs = github:nixos/nixpkgs/nixos-unstable`.

**macOS:**
```nix
darwinConfigurations."mince-mac" = nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs; };  # inputs available in nix-darwin modules only
  modules = [ ./nix-darwin/default.nix ];
};
```

**`nix-darwin/default.nix` の home-manager 設定:**
```nix
home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  sharedModules = [ inputs.agent-skills.homeManagerModules.default ];
  extraSpecialArgs = { inherit (inputs) slash-criticalthink anthropic-skills; };
  users.mince = ../home/darwin.nix;
};
```

**Linux:**
```nix
homeConfigurations."mince" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages."x86_64-linux";
  extraSpecialArgs = {
    inherit (inputs) zen-browser noctalia-shell inir slash-criticalthink anthropic-skills;
  };
  modules = [ ... ./home/linux.nix ];
};
```

## Module Pattern (必須)

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.<name>;
in {
  options.programs.<name> = {
    enable = lib.mkEnableOption "<description>";
    someOption = lib.mkOption {
      type = lib.types.str;
      default = "value";
      description = "...";
    };
  };

  config = lib.mkIf cfg.enable {
    # pkgs.foo と明示する。with pkgs; は使わない
  };
}
```

## Flake Inputs をモジュールで使う

**macOS home-manager モジュール**（`home/darwin.nix` 以下）で使える特殊引数：
```nix
{ config, lib, pkgs, slash-criticalthink, anthropic-skills, ... }:
```

**Linux home-manager モジュール**でさらに使える引数：
```nix
{ config, lib, pkgs, zen-browser, noctalia-shell, inir, ... }:
```

`inputs` 全体は nix-darwin モジュール（`nix-darwin/default.nix`）でのみ使える。home-manager モジュールには渡さない。Linux 専用 inputs（`zen-browser` 等）を macOS モジュールで参照しない。

## 新モジュール追加手順

1. `modules/<name>.nix` を上記パターンで作成
2. 適切なファイルに import を追加：
   - macOS + Linux 共通 → `home/common.nix`
   - macOS のみ → `home/darwin.nix`
   - Linux のみ → `home/linux.nix`
3. `programs.<name>.enable = true;` で有効化

## パッケージをどこに追加するか

| 対象       | 場所                                  | 注意点                                      |
|------------|---------------------------------------|---------------------------------------------|
| Linux      | `home/linux.nix` の `home.packages`   | `pkgs` 引数が既にある                       |
| Mac CLI    | `nix-darwin/homebrew.nix` の `brews`  | 追加前に既存リストを必ず確認                |
| Mac GUI    | `nix-darwin/homebrew.nix` の `casks`  | 同上                                        |
| 両OS共通   | `home/common.nix` の `home.packages`  | `darwin.nix` はデフォルトで `pkgs` なし     |

`darwin.nix` で `pkgs` を使う場合は引数を `{ pkgs, ... }:` に変更する。

## アンチパターン

- `with pkgs;` は使わない — 常に `pkgs.foo` と明示
- overlay はこのリポジトリにない — 必要なら flake.nix の nixpkgs レベルで追加
- `allowUnfree` はこのリポジトリで設定していない
- home-manager モジュールに `inputs` 引数を追加しない
- import を追加し忘れない — モジュールはオプトイン制
- Mac にパッケージを追加する前に必ず `nix-darwin/homebrew.nix` の `brews` / `casks` を確認する — Homebrew 経由で既にインストール済みの可能性がある
- `programs.git.enable = true` は `~/.config/git/config` を管理下に置く。`~/.gitconfig` が既存の場合は競合する。git バイナリをNix管理にしたくない場合は `home.packages = [ pkgs.delta ]` などパッケージのみ追加する

## よく使うコマンド

```bash
# macOS 適用
darwin-rebuild switch --flake ~/.config/home-manager#mince-mac

# Linux 適用
home-manager switch --flake ~/.config/home-manager#mince

# 全 inputs 更新
nix flake update

# 単一 input 更新
nix flake update nixpkgs

# 適用せず確認 (macOS)
darwin-rebuild check --flake ~/.config/home-manager#mince-mac
```
