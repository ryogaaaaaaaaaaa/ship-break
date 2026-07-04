# 04 CONTENT SCHEMA

## 現在の状態

第1マイルストーンでは、バグ内容、ウェーブ、敵、boss echo の外部データファイルはまだ作らない。
ただし、将来のデータ化に備えてルールパッチの考え方を実装済みである。

## RulePatch の概念

将来のバグ変種は、既存ルール primitive で表現できる限り `RulePatch` として定義する。

サポートする初期 op:

- `SET`: 値を置き換える。
- `ADD`: 数値へ加算する。
- `MULTIPLY`: 数値へ乗算する。
- `ENABLE`: 真偽値を `true` にする。
- `DISABLE`: 真偽値を `false` にする。

初期ルール path:

- `player.movement_speed`
- `player.dash_speed`
- `player.dash_duration`
- `player.dash_cooldown`
- `player.attack_cooldown`
- `player.projectile_speed`
- `player.max_health`
- `enemy.max_active`
- `enemy.chaser_speed`
- `enemy.chaser_health`
- `enemy.chaser_surge_distance`
- `enemy.chaser_surge_multiplier`
- `enemy.contact_damage`
- `combat.max_projectiles`
- `combat.projectile_damage`
- `combat.projectile_lifetime`
- `debug.show_hitboxes`
- `run.duration_seconds`

## 検証ルール

- 存在しない path はエラーにする。
- `ADD` と `MULTIPLY` は数値にだけ適用する。
- `ENABLE` と `DISABLE` は真偽値を書き込む。
- Resolver は actor や SceneTree に触れない。

## 将来の content validation

データファイルを追加したら、次を検証する。

- path が存在する。
- op と値の型が合う。
- boss echo 参照が存在する。
- 複製、弾、死体、UI leak object などに上限がある。
- 同じ seed と同じ選択で、ラン構造が再現できる。
