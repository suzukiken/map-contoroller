# map-controllor firmware (QMK)

Seeed XIAO RP2040 + Alps RKJXT1F42001(4方向スイッチ + プッシュ + ロータリーエンコーダ)を
[QMK](https://qmk.fm) で HID キーボード化し、`android/` の地図アプリのコントローラーとして使う。

## ピン割り当て(pcb/encoder.kicad_pcb と対応)

| RKJXT1F42001 端子 | XIAO RP2040 ピン | 機能 |
| --- | --- | --- |
| A | GP6 (D4) | 下スクロール (↓) |
| B | GP27 (D1) | 右スクロール (→) |
| C | GP28 (D2) | 上スクロール (↑) |
| D | GP0 (D6) | 左スクロール (←) |
| Push | GP29 (D3) | Enter (目的地セット) |
| EA | GP7 (D5) | エンコーダ A相 |
| EB | GP26 (D0) | エンコーダ B相 |
| Com / ECom / GND | GND | 共通 |

## 操作と地図アプリの対応

| 操作 | 送信キー | アプリの動作 |
| --- | --- | --- |
| スティック上下左右 | ↑↓←→ | 地図スクロール |
| エンコーダ時計回り | PageUp | ズームイン |
| エンコーダ反時計回り | PageDown | ズームアウト |
| プッシュ | Enter | 画面中心を目的地にセット |

RKJXT1F42001 は方向を倒すと Push も同時に ON になる（部品仕様）。
`map_controllor.c` で方向入力中の Enter を無視している。

方向スイッチ A〜D の向きは実装の向きで変わるので、逆だったら
`keymaps/default/keymap.json` の `KC_UP/KC_DOWN/KC_LEFT/KC_RGHT` を入れ替える。

## ビルド

ビルド済みの `map_controllor_default.uf2` がこのディレクトリに入っている。
再ビルドする場合、リポジトリ直下の `.build/qmk_firmware` に QMK 環境をセットアップ済み
(`keyboards/map_controllor` がこのディレクトリへのシンボリックリンクになっている):

```bash
cd ~/qmk_firmware
qmk compile -kb map_controllor -km default
```

`map_controllor_default.uf2` が生成される。

`map_controllor.c` は Push フィルタ用。QMK が `keyboards/map_controllor/map_controllor.c` として自動でコンパイルする。
**`rules.mk` に `SRC += map_controllor.c` を書くと二重コンパイルでリンクエラーになるので不要。**

## 書き込み

1. XIAO RP2040 の **BOOT** ボタンを押しながら USB 接続(または BOOT を押しながら RESET)
2. マウントされた `RPI-RP2` ドライブに **`map_controllor_default.uf2`** をコピーすると自動で再起動して完了
