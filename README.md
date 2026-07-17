# map-controllor

車載向けの地図ナビアプリと、それを操作する USB コントローラー一式です。
コントローラー（QMK キーボード）からのキー入力で、地図のスクロール・ズーム・目的地設定などを行います。

**ナビアプリ** は Android 版と iOS（iPad）版があります。いずれも同じキー操作に対応しています。

![ナビアプリとコントローラー](image/IMG_0233.JPG)

## リポジトリ構成

| ディレクトリ | 内容 |
| --- | --- |
| [`android/`](android/) | Google Maps ベースのナビ Android アプリ |
| [`ios/`](ios/) | 同上の iOS / iPad 版（MapKit + Google Routes/Places API） |
| [`firmware/`](firmware/) | QMK ファームウェア（HID キーボード） |
| [`pcb/`](pcb/) | KiCad 基板データ |
| [`enclosure/`](enclosure/) | ケース・エンコーダノブ（OpenSCAD） |

## 使い方の流れ

1. [`pcb/`](pcb/) の基板を製造・実装し、[`enclosure/`](enclosure/) のケースに組み込む
2. [`firmware/`](firmware/) をビルドして XIAO RP2040 に書き込む
3. コントローラーを Android 端末または iPad に USB 接続する
4. ナビアプリ（[`android/`](android/) または [`ios/`](ios/)）を起動する

## ナビアプリ

USB 接続の map-controllor から送られるキー入力で地図を操作します。

| 操作 | キー | 動作 |
| --- | --- | --- |
| パン | 方向キー（長押し） | 地図スクロール |
| ズームイン | Page Up | ズーム +1 |
| ズームアウト | Page Down | ズーム -1 |
| 目的地設定 | Enter | 画面中心を目的地に設定し、ルート表示 |
| 現在地へ | Space | 現在地を中心に表示 |
| 音声入力 | V | 音声 → 住所検索 → 目的地設定 |
| 駐車場 | P | 近くの駐車場表示トグル |

コントローラー側のキー割り当て（スティック・エンコーダ・プッシュ）は [`firmware/README.md`](firmware/README.md) を参照してください。

### Google Maps API キー

ルート案内・駐車場検索に Google Routes / Places API を使います。Android / iOS で同じ API キーを使えます。

| プラットフォーム | 設定ファイル |
| --- | --- |
| Android | `android/local.properties` の `MAPS_API_KEY`（[`local.properties.example`](android/local.properties.example) をコピー） |
| iOS | `ios/Secrets.xcconfig` の `MAPS_API_KEY`（[`Secrets.xcconfig.example`](ios/Secrets.xcconfig.example) をコピー） |

Google Cloud Console で **Routes API** と **Places API (New)** を有効化してください。

### Android

[Maps SDK for Android](https://developers.google.com/maps/documentation/android-sdk) を使ったキーボード操作対応アプリです。

セットアップ・ビルド手順は [`android/README.md`](android/README.md) を参照してください。

### iOS

iPad 向けアプリです。地図表示は **MapKit**、ルート・駐車場検索は Android 版と同じ REST API を使います。

```bash
cp ios/Secrets.xcconfig.example ios/Secrets.xcconfig
# MAPS_API_KEY を設定
```

Xcode で [`ios/Navi.xcodeproj`](ios/Navi.xcodeproj) を開き、実機（iPad）で Run してください。初回は iPad の **設定 → 一般 → VPNとデバイス管理** で開発者アプリを信頼する必要があります。

詳細は [`ios/README.md`](ios/README.md) を参照してください。

## ハードウェア

ナビアプリを操作する物理コントローラーです。

![コントローラー試作](image/IMG_0234.JPG)

| 部品 | 説明 |
| --- | --- |
| [Alps RKJXT1F42001](https://tech.alpsalpine.com/j/products/detail/RKJXT1F42001/) | 4 方向スイッチ + プッシュ + ロータリーエンコーダ |
| [Seeed XIAO RP2040](https://wiki.seeedstudio.com/ja/XIAO-RP2040/) | USB 接続のマイコン（QMK ファームウェアを書き込む） |

基板データは [`pcb/`](pcb/) にあります。製造制約・配線ルール・回路設計の詳細は [`pcb/AGENTS.md`](pcb/AGENTS.md) を参照してください。

![基板レイアウト](image/22.png)

## ファームウェア

[QMK](https://qmk.fm) でビルドする HID キーボード用のソースコードです。ここでいう **ファームウェア** は、工場出荷時に XIAO RP2040 に最初から入っているソフトではありません。利用者が自分でコンパイルして `.uf2` ファイルを生成し、USB 接続したハードウェアへ書き込むものです。

書き込み後、コントローラーの入力は USB 経由で接続先端末（Android または iPad）に送られます。ビルド・書き込み手順、キー割り当ては [`firmware/README.md`](firmware/README.md) を参照してください。

## ケース

基板と部品を収める 3D プリント用ケースです。[`enclosure/`](enclosure/) に OpenSCAD ソースと STL があります。

![ケース](image/case.png)

![エンコーダノブ](image/nob.png)

| ファイル | 内容 |
| --- | --- |
| [`case.scad`](enclosure/case.scad) | 下ケース（基板 cavity・USB 切り欠き・ネジピラー） |
| [`knob.scad`](enclosure/knob.scad) | RKJXT1F42001 用エンコーダノブ |
| [`case.stl`](enclosure/case.stl) | 下ケース（出力済み STL） |
| [`knob.stl`](enclosure/knob.stl) | ノブ（出力済み STL） |

### 寸法・設計

基板 [`pcb/encoder.kicad_pcb`](pcb/encoder.kicad_pcb) の外形（21 × 45.5 mm、板厚 1.6 mm、角 R1 mm）に合わせています。

| 項目 | 値 |
| --- | --- |
| 基板サイズ | 21 × 45.5 mm |
| 取付穴 | (2, 2)、(19.25, 2) mm、φ2 mm |
| エンコーダ（SW1）中心 | 基板下辺から 10 mm |
| ノブ外径 | 14 mm |
| シャフト穴 | Ø2.5 mm（D カット、RKJXT1F42001 内側シャフト） |

下ケースは XIAO RP2040 下に中央支柱を 1 本置き、ピンヘッダとの干渉を避けています。USB-C コネクタ用の切り欠きは基板上辺側にあります。

### 組み立て

1. 下ケースに基板を載せ、取付穴位置 `(2, 2)` / `(19.25, 2)` から **M2 ネジ**を下側から通す
2. 基板上面に **M2 ナット**を載せて固定する
3. [`knob.scad`](enclosure/knob.scad) で出力したノブをエンコーダシャフトに取り付ける

### STL の再出力

[OpenSCAD](https://openscad.org/) で各 `.scad` を開き、**F6**（レンダリング）→ **F7**（STL 出力）で `case.stl` / `knob.stl` を生成できます。ノブのシャフト穴が合わない場合は `knob.scad` の `shaft_d` を微調整してください。
