---
name: merge-pr
description: "GitHub PR を安全にマージするワークフロー。「PR をマージする」「PR を取り込む」等の文脈でトリガーする。git worktree で隔離検証し、rebase 後に --merge フラグでマージする。"
allowed-tools: Bash
---

# merge-pr

## 使用方法

```
/merge-pr [PR番号]
```

- 数値のみ: そのPR番号を対象とする
- 無引数: `gh pr list` でオープンPRを一覧表示し、対話的に選択

## 動作フロー

1. PR情報取得 — `gh pr view <N>` でブランチ名・タイトル・差分を確認
2. worktree作成 — `git worktree add ../<repo>-pr<N> <branch>`
3. 検証 — プロジェクトの CLAUDE.md / README の指示に従う。環境やコマンドが不明な場合はユーザーに確認
4. rebase — `git rebase origin/main`、コンフリクトはプロジェクト慣習で解決し再検証
5. 記録 — `gh pr review --comment` で検証結果・rebase先・特記事項を PR に残す
6. マージ — ユーザーの承認を得てから `gh pr merge --merge <N>`
7. 後片付け — `git worktree remove` で隔離環境を削除、元ディレクトリで `git pull --rebase`

## 注意事項

- `gh pr merge --merge` のみ使用すること。`--squash` と `--rebase` は履歴を破壊するため禁止
- 不確実な状況では独断せずユーザーに確認する

