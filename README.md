# map-controllor

車載向けの地図ナビ Android アプリと、それを操作するハードウェア一式です。
USB 接続のコントローラーからキー入力を送り、アプリ側で地図のスクロール・ズーム・目的地設定などを行います。

## リポジトリ構成

| ディレクトリ | 内容 |
| --- | --- |
| [`android/`](android/) | Google Maps ベースのナビ Android アプリ |
| [`firmware/`](firmware/) | QMK ファームウェア（HID キーボード） |
| [`pcb/`](pcb/) | KiCad 基板データ |
| [`enclosure/`](enclosure/) | ケースデータ（未作成） |

## Android アプリ

[Maps SDK for Android](https://developers.google.com/maps/documentation/android-sdk) を使った、キーボード操作対応の Android アプリです。
車載してナビとして使うことを想定しており、本 README では **ナビアプリ** と呼びます。

セットアップ・ビルド手順は [`android/README.md`](android/README.md) を参照してください。

## ハードウェア

ナビアプリを操作する物理コントローラーです。次の部品を載せた基板で構成します。

| 部品 | 説明 |
| --- | --- |
| [Alps RKJXT1F42001](https://tech.alpsalpine.com/j/products/detail/RKJXT1F42001/) | 4 方向スイッチ + プッシュ + ロータリーエンコーダ |
| [Seeed XIAO RP2040](https://wiki.seeedstudio.com/ja/XIAO-RP2040/) | USB 接続のマイコン（QMK ファームウェアを書き込む） |

基板データは [`pcb/`](pcb/) にあります。

## ファームウェア

[QMK](https://qmk.fm) でビルドする HID キーボードファームウェアです。
XIAO RP2040 に書き込み、コントローラーの入力を Android 端末へ送ります。

ビルド・書き込み手順、キー割り当ては [`firmware/README.md`](firmware/README.md) を参照してください。

## 基板の製造制約

基板は CNC で切削します（エンドミル 0.5 mm）。

- **片面基板のみ** — Bottom（裏面）の 1 層。2 層基板は使わない
- **GND はベタグラウンド不可** — GND もトレースで配線する
- **配線方向** — 垂直・水平・45° の直線のみ
- **配線幅** — 0.5 mm
- **配線間隔** — 0.5 mm
- **直角の折り返し禁止** — 方向を変えるときは 45° の折り返しを 2 回使う（角を丸めるイメージ）
- **45° 折り返しを連続させる場合** — 各線分は目視できる長さ（目安 0.5 mm 程度）にする

## 回路設計（交差しない配線案）

片面基板では配線が交差できないため、信号同士がぶつからない配線案が必要です。
以下は交差しない可能性がある配線例です（**実際に配線可能かは未確認**）。

| 信号 | XIAO ピン |
| --- | --- |
| Switch A | P7 |
| Switch B | P27 |
| Switch C | P28 |
| Switch D | P6 |
| Encoder A | P29 |
| Encoder B | P26 |
| Push | P0 |
| Com | GND |
| Encoder Com | GND |
| GND | GND |

確定した配線・KiCad データは [`pcb/README.md`](pcb/README.md) を参照してください。
