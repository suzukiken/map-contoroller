# PCB 設計エージェント向け指示

このファイルは `pcb/` ディレクトリの基板設計を Copilot などの AI エージェントに任せるための仕様書です。
プロジェクト全体の概要は [`../README.md`](../README.md) を参照してください。

## 目的

Seeed XIAO RP2040 と Alps RKJXT1F42001 を載せた、ナビアプリ用 USB コントローラー基板を設計する。
ファームウェアは QMK（[`../firmware/`](../firmware/)）で HID キーボードとして動作する。

## 部品

| 参照 | 部品 | 役割 |
| --- | --- | --- |
| U1 | [Seeed XIAO RP2040](https://wiki.seeedstudio.com/ja/XIAO-RP2040/) | USB 接続マイコン。QMK ファームウェアを書き込む |
| SW1 | [Alps RKJXT1F42001](https://tech.alpsalpine.com/j/products/detail/RKJXT1F42001/) | 4 方向スイッチ + プッシュ + ロータリーエンコーダ |

フットプリントは `footpritn/footpritn.pretty/` にある。

- `Xiao2040.kicad_mod`
- `RKJXT1F42001.kicad_mod`

## 製造制約（必須）

基板は **CNC 切削** で製作する（エンドミル 0.5 mm）。

- **片面基板のみ** — Bottom（裏面）の 1 層。2 層基板は使わない
- **GND はベタグラウンド不可** — GND もトレースで配線する
- **配線方向** — 垂直・水平・45° の直線のみ
- **配線幅** — 0.5 mm
- **配線間隔** — 0.5 mm
- **直角の折り返し禁止** — 方向を変えるときは 45° の折り返しを 2 回使う
- **45° 折り返しを連続させる場合** — 各線分は目視できる長さ（目安 0.5 mm 程度）にする

## 回路設計の制約

片面基板では配線が交差できないため、**すべての信号が交差せずに配線できる** 配置・配線案が必要。

スイッチ・エンコーダの共通端子（Com, Encoder Com, GND）は GND に接続する。
RP2040 の内蔵プルアップ（QMK の direct pins / encoder デフォルト）で読むため、**外付け部品は不要**。

## 配線（例）

XIAO RP2040 のシルク表記（P0, P6, P7 など）での割り当て案:

| 信号 | XIAO ピン |
| --- | --- |
| Switch A | P6 |
| Switch B | P27 |
| Switch C | P28 |
| Switch D | P0 |
| Encoder A | P7 |
| Encoder B | P26 |
| Push | P29 |
| Com | GND |
| Encoder Com | GND |
| GND | GND |

この配線案が実際に交差せず配線可能かは **未確認**。
設計時は上記を出発点とし、交差が発生する場合は配置変更または別のピン割り当てを検討すること。

## KiCad プロジェクト

| ファイル | 説明 |
| --- | --- |
| `encoder.kicad_pro` | プロジェクトファイル |
| `encoder.kicad_pcb` | 基板データ（編集対象） |
| `scripts/` | pcbnew スクリプト（参考・自動化用） |

KiCad 10 系を想定。

## 作業時の指針

1. 既存の `encoder.kicad_pcb` を確認し、製造制約（片面・CNC）に合わない部分があれば修正する
2. U1（XIAO RP2040）と SW1（RKJXT1F42001）の配置を決める
3. 上記配線案に基づき、交差しない配線を Bottom 層に引く
4. ネット名を付け、すべてのパッドを接続する
5. DRC を実行し、エラー 0 件・未配線 0 件を目指す

DRC コマンド例:

```bash
/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli pcb drc encoder.kicad_pcb
```

## 完了条件

- [ ] 片面基板（Bottom のみ）の配線になっている
- [ ] 製造制約（配線幅・間隔・折り返しルール）を満たしている
- [ ] 配線案の全信号が U1 と SW1 の間で接続されている
- [ ] DRC エラー 0 件
- [ ] 未配線アイテム 0 件

## 関連ドキュメント

- [`README.md`](README.md) — 現在の KiCad データの説明・検証手順
- [`../firmware/README.md`](../firmware/README.md) — QMK ファームウェアのピン割り当て・キー操作
