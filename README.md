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

![ナビアプリとコントローラー](image/IMG_0233.JPG)

セットアップ・ビルド手順は [`android/README.md`](android/README.md) を参照してください。

## ハードウェア

ナビアプリを操作する物理コントローラーです。次の部品を載せた基板で構成します。

![コントローラー試作](image/IMG_0234.JPG)

| 部品 | 説明 |
| --- | --- |
| [Alps RKJXT1F42001](https://tech.alpsalpine.com/j/products/detail/RKJXT1F42001/) | 4 方向スイッチ + プッシュ + ロータリーエンコーダ |
| [Seeed XIAO RP2040](https://wiki.seeedstudio.com/ja/XIAO-RP2040/) | USB 接続のマイコン（QMK ファームウェアを書き込む） |

基板データは [`pcb/`](pcb/) にあります。
基板の製造制約・配線ルール・回路設計の詳細は [`pcb/AGENTS.md`](pcb/AGENTS.md) を参照してください。

![基板レイアウト](image/22.png)

## ファームウェア

[QMK](https://qmk.fm) でビルドする HID キーボードファームウェアです。
XIAO RP2040 に書き込み、コントローラーの入力を Android 端末へ送ります。

ビルド・書き込み手順、キー割り当ては [`firmware/README.md`](firmware/README.md) を参照してください。
