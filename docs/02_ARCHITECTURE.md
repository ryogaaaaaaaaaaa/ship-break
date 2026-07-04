# 02 ARCHITECTURE

## 基本方針

バグ選択は actor を直接書き換えない。バグはルールを変え、ゲームプレイシステムは解決済みルールを読む。

ルールの流れ:

```text
RuleState
-> RulePatch
-> RuleResolver
-> RuleSnapshot
-> RuleService
-> Gameplay systems
```

## 依存方向

- `RuleResolver` は pure function に近く保ち、SceneTree、UI、actor、Timer を触らない。
- `RuleSnapshot` は読み取り専用の現在ルール表として扱う。
- `RuleService` は現在のルールスナップショットを保持するだけに留める。
- `Game` はラン状態、スポーン、勝敗、リスタートを所有する。
- UI は表示だけを担当し、ゲームプレイ状態を所有しない。
- actor は必要な値を `RuleSnapshot` から読む。

## RNG

実行構造へ影響する乱数は `SeededRng` 経由にする。

対象:

- 敵スポーン位置の選択。
- 将来のバグ候補選択。
- 将来のウェーブ選択。
- 将来のボス echo 順。

Godot のグローバル乱数を、ラン構造に関わる場所で直接使わない。

## リスタート境界

リスタートは既存状態を細かく巻き戻すのではなく、新しいラン状態を構築する。

現在の実装では `Game.start_run()` が次を行う。

- 既存の session root を破棄する。
- `SeededRng` を seed から作り直す。
- `RuleService` を初期状態から作り直す。
- アリーナ、プレイヤー、敵、弾を作り直す。

この方針により、前回プレイの敵、弾、HP、タイマー、ルールが残るリスクを抑える。

## 増殖系の上限

現在の第1マイルストーンでは、敵数と発射体数に上限を置く。

- `enemy.max_active`
- `combat.max_projectiles`

将来の複製、死体、UI 漏れにも同じ考え方を適用する。
