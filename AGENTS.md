# SHIP//BREAK 開発エージェント方針

## Mission

SHIP//BREAK の MVP を、将来の Codex セッションが安全に理解・拡張・検証できる形で作り、出荷可能な商用インディーゲームへ育てる。

## Human and Codex roles

Human:

- 意図を定義する。
- ゲームフィールを評価する。
- スコープを承認する。
- 観測した問題を報告する。
- 最終判断を行う。

Codex:

- 実装を書く。
- テストを書く。
- 検証ツールを書く。
- リポジトリ知識を更新する。
- 失敗や意思決定を記録する。

人間はソースコード、シーン、テスト、ツール、プロジェクトファイルを手動編集しない。実装変更は Codex が行う。

## Required read order

コード変更前に必ず次を読む。

1. `AGENTS.md`
2. `docs/01_MVP_CONTRACT.md`
3. 作業に関係する追加ドキュメントだけ
4. 既存実装

チャット履歴ではなく、リポジトリを真実の情報源にする。

## Language policy

- 人間への進捗報告、計画、説明、質問、警告、最終要約は必ず日本語で書く。
- 人間向けのリポジトリ文書は日本語で書く。
  - `AGENTS.md`
  - `README.md`
  - `docs/` 以下の全ファイル
  - 意思決定記録
  - 失敗記録
- プログラム上の識別子は英語のままにする。
  - class name
  - function name
  - variable name
  - signal name
  - file name
  - directory name
  - data key
- プロジェクト固有の意図を説明するコードコメントは日本語で書く。
- サードパーティのエラーメッセージやコマンド出力は翻訳しない。
  - 必要な場合は、出力の意味や対応方針を日本語で説明する。
- 技術英語が必要な場合は、日本語の説明を添える。

## Architecture invariants

- Godot 4.x と typed GDScript を使う。
- 実行構造に影響する乱数は `SeededRng` 経由にする。
- ルール変更は `RuleState -> RulePatch -> RuleResolver -> RuleSnapshot -> RuleService` の流れを通す。
- 可能な限り、バグ変種はデータ駆動の `RulePatch` で表現する。
- UI はゲームプレイ状態を所有しない。
- modifier は無関係な actor を直接書き換えない。
- 増殖・複製・発射体・死体・UI 漏れなどの乗算系システムには上限を設ける。
- MVP スコープを黙って拡張しない。

## Definition of done

タスクは次を満たすまで完了ではない。

1. 受け入れ条件を満たしている。
2. 関連テストが存在する。
3. 検証が通っている。
4. 未説明のエラーを導入していない。
5. 必要なドキュメントが更新されている。

通常は最後に次を実行する。

```powershell
./tools/verify.ps1
```

この macOS 作業環境に PowerShell がない場合は、同じ検証内容を次で実行する。

```sh
./tools/verify.sh
```

## Failure policy

- まず再現する。
- 実用的なら失敗テストを作る、または既存テストを改善する。
- 最小の責任層を直す。
- 3回同じ方向で失敗したら、前提を見直し、失敗記録へ残し、構造的に別の解法を選ぶ。
- 正当な理由なくテストを弱めて失敗を隠さない。

## Current milestone

現在のマイルストーンは `docs/01_MVP_CONTRACT.md` の「第1マイルストーン」を参照する。
