---
name: merge-pr
description: >-
  GitHub PR を安全にマージするワークフロー。「PR をマージする」「PR を取り込む」などの文脈でトリガーする。
  必ず --merge フラグ（マージコミット作成）を使う。--squash と --rebase は git graph を破壊するため絶対に使わない。
  PR 番号を引数として受け取るか、引数なしでオープン PR 一覧から対話的に選択する。
allowed-tools: Bash
---

# PR マージワークフロー

## 絶対ルール

`gh pr merge` には必ず `--merge` を使う。`--squash` と `--rebase` は **絶対に使わない**。

## 呼び出し形式

- **引数あり**: 指定された PR 番号を処理する
- **引数なし**: `gh pr list` でオープン PR 一覧を表示し、ユーザーに選択させる

## 処理ステップ

### Step 1: PR の情報確認

```bash
gh pr view <N> --json number,title,headRefName,state,mergeable
```

### Step 2: ユーザーに確認

マージ前に必ず確認を求める:

> PR #N「<タイトル>」を `--merge` でマージしてよいですか？

### Step 3: マージ

```bash
gh pr merge <N> --merge
```

### Step 4: 同期

```bash
git pull origin main
```
