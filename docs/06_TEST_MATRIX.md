# 06 TEST MATRIX

## 現在の自動テスト

`godot --headless --path . --script res://tests/test_runner.gd` で実行する。

現在の対象:

- `SeededRng` が同じ seed で同じ列を返す。
- `SeededRng` の範囲付き値が指定範囲に収まる。
- `RulePatch` の `SET`、`ADD`、`MULTIPLY`、`ENABLE`、`DISABLE` が期待通り動く。
- 無効な rule path がエラーになる。
- `RuleSnapshot` の外部取得が内部状態を汚さない。
- `Game` のリスタートで古い session root が残らない。
- `Game` が解決済みルールをプレイヤーとスポーン上限へ渡せる。
- Chaser の接触でプレイヤーがダメージを受ける。
- 弾で Chaser を倒せる。
- プレイヤー死亡で失敗状態になる。
- 制限時間到達で成功状態になる。
- Web 書き出しが `build/web/` に生成できる。

## 手動プレイテスト項目

- `W/A/S/D` または矢印キーで移動できる。
- マウス方向へ狙える。
- 左クリックで弾が出る。
- `Space` でダッシュできる。
- Chaser がプレイヤーへ近づく。
- 弾で Chaser を倒せる。
- 接触するとプレイヤーがダメージを受ける。
- 体力0で失敗状態になる。
- 60秒生存で成功状態になる。
- `R` で何度もリスタートできる。
- スマホでは左側仮想スティック、右側ドラッグ射撃、右下ダッシュで操作できる。

## 将来の優先テスト

- ルール解決順。
- 無効な content 参照。
- 決定論的なバグ候補生成。
- 100 seed の simulation。
- 複製上限。
- 発射体上限。
- 死体 lifecycle。
- boss echo 参照。
- 再起動後の stale state 検出。
