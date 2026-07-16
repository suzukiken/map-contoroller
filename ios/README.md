# iOS ナビアプリ

Android 版（`android/`）と同じキーボード操作対応の地図ナビアプリです。

## 機能

| 操作 | キー | 動作 |
| --- | --- | --- |
| パン | 方向キー（長押し） | 地図スクロール（120ms 間隔） |
| ズームイン | Page Up | ズーム +1 |
| ズームアウト | Page Down | ズーム -1 |
| 目的地設定 | Enter | 画面中心を目的地に設定 |
| 現在地へ | Space | 現在地を中心に表示 |
| 音声入力 | V | 音声 → 住所検索 → 目的地設定 |
| 駐車場 | P | 近くの駐車場表示トグル |

地図表示は MapKit、ルート・駐車場検索は Google Routes / Places API（Android と同じ REST API）を使います。

## セットアップ

1. API キーを設定（Android と同じキーで可）:
   ```bash
   cp Secrets.xcconfig.example Secrets.xcconfig
   # Secrets.xcconfig を編集して MAPS_API_KEY を設定
   ```
   キーは `AppInfo.plist` 経由でアプリに渡されます（`Secrets.xcconfig` → ビルド設定 `MAPS_API_KEY`）。
2. Xcode で `ios/Navi.xcodeproj` を開く
3. 実機（iPad）を接続し Run

### API キーの制限

Google Cloud Console で次の API を有効化してください。

- Routes API
- Places API (New)

iOS 向けに Maps SDK for iOS の制限は不要です（MapKit 使用）。REST API 用のキー制限を設定してください。

## キー操作

USB 接続の map-controllor コントローラー（QMK キーボード）を iPad に接続して使います。Android 版と同じキーマップです。

## プロジェクト構成

```
ios/
├── Navi.xcodeproj
├── AppInfo.plist          # MAPS_API_KEY を Info.plist へ渡す
├── Secrets.xcconfig.example
├── Secrets.xcconfig       # git 管理外（ローカル設定）
├── Navi/
│   ├── Models/
│   ├── Services/
│   ├── ViewModels/
│   └── Views/
├── NaviTests/
└── NaviUITests/
```
