# DECISIONS

## 0001: 人間向け情報は日本語で運用する

詳細: `docs/decisions/0001-language-policy.md`

決定:

- 人間向けの会話と文書は日本語で書く。
- プログラム識別子は英語のままにする。
- 外部エラー出力は原文を保ち、日本語で意味を説明する。

## 0002: 第1マイルストーンは通常ゲーム基盤に限定する

文脈:

- 将来のゲームの核はバグ選択でルールが変わること。
- しかし、壊す対象である通常ゲームが先に成立していないと、破壊の面白さが出ない。

代替案:

- 先にバグ選択 UI を作る。
- 先に全バグファミリーのデータ構造を作る。

理由:

- 最初の60から90秒が普通に成立することは非交渉の原則。
- 過剰な抽象化より、テスト可能な通常ゲームを先に作るほうが安全。

影響:

- 現在は `FIX` / `WORKAROUND` / `EXPLOIT` を実装しない。
- `TEST RUNNER` も作らない。
- ルール基盤は小さく、本当に使う値だけから始める。

## 0003: PowerShell 検証入口と macOS 補助入口を併置する

文脈:

- 目標開発環境は Windows 11 / PowerShell。
- 現在の作業環境は macOS で、`pwsh` が見つからない。

決定:

- 公式入口として `tools/verify.ps1` を作る。
- 同じ検証内容を macOS で実行するため `tools/verify.sh` も作る。

影響:

- Windows では `./tools/verify.ps1` を使う。
- この作業環境では `./tools/verify.sh` で同等検証を実行する。

## 0004: project-level Codex agent 設定はまだ作らない

文脈:

- サブエージェント機能は利用できた。
- しかし、リポジトリ内 `.agents` や `.codex/agents` の具体的な設定形式は確認できなかった。

決定:

- 推測でプロジェクト固有 agent 設定ファイルを作らない。
- 必要な役割は文書に残す。

影響:

- 現時点では `architect` や `qa` の設定ファイルは作らない。
- 将来、公式形式が確認できた時点で追加する。

## 0005: 初期検証環境は Godot 4.6.2 headless を使う

文脈:

- 現在の作業環境で `/usr/local/bin/godot` が見つかった。
- `godot --version` は `4.6.2.stable.official.71f334935` を返した。
- `godot --headless --version` も同じバージョンを返した。

決定:

- 第1マイルストーンの自動検証は Godot 4.6.2 の headless 実行で行う。
- テストは `godot --headless --path . --script res://tests/test_runner.gd` で実行する。
- 起動確認は `res://tools/launch_check.gd` でメインシーンを短く生成して終了する。

影響:

- Godot editor を人間が手動で開かなくても、基本検証ができる。
- 目標環境の Windows / PowerShell では `tools/verify.ps1` を使う。
- 現在の macOS 環境では `pwsh` が見つからないため、同等検証として `tools/verify.sh` を使う。

## 0006: 最初の Pages 公開はローカル Web 書き出しで行う

文脈:

- 人間が GitHub リポジトリを作成した。
- スマホから遊ぶには Web export が必要である。
- GitHub Actions で自動書き出しする方法もあるが、Godot インストール用の追加 action やメンテナンス対象が増える。

決定:

- 最初はローカルの Godot で `tools/export_web.sh` または `tools/export_web.ps1` を実行し、`build/web/` を作る。
- `build/web/` の中身を Pages 公開用ブランチへ置く。
- Web export は thread support を無効にして、GitHub Pages で扱いやすい静的配信に寄せる。

影響:

- 初期公開の手順は単純になる。
- 自動デプロイは後のマイルストーンで必要になったら検討する。
- スマホ操作のため、最低限の touch controls を追加した。
