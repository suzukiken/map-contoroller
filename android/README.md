# android-my-car-navi

車載向けナビゲーション Android アプリ（開発用リポジトリ: `android-my-car-navi`）。

[![Build Status](https://img.shields.io/badge/build-unknown-lightgrey)](https://github.com/<owner>/<repo>/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 目次
- [概要](#概要)
- [機能](#機能)
- [前提条件](#前提条件)
- [セットアップ](#セットアップ)
- [ビルドと実行](#ビルドと実行)
- [テスト](#テスト)
- [開発フロー](#開発フロー)
- [ディレクトリ構成](#ディレクトリ構成)
- [貢献](#貢献)
- [ライセンス](#ライセンス)
- [連絡先](#連絡先)

## 概要
このリポジトリは Android アプリ「android-my-car-navi」のソースコードを含みます。車載向けに設計されたナビアプリで、現在地表示、ルート案内、地図データの扱いなどの機能を計画・実装しています。

## 機能
- 現在地の取得と表示（GPS）
- ルート検索・表示（将来的に音声ナビ対応を予定）
- 地図タイルのキャッシュ管理
- 設定とユーザープロファイル（実装中）

（実装済み/未実装の詳細は Issue / プロジェクトボードを参照してください）

## 前提条件
- JDK 11 以上
- Android SDK（プロジェクトの `compileSdk` に合わせる）
- Android Studio（推奨）またはコマンドラインの Gradle ラッパー
- `local.properties` に Android SDK パスを設定（`local.properties.example` を参照）

重要: `local.properties` は環境依存のため通常コミットしません。リポジトリにある `local.properties.example` をコピーして利用してください。

## セットアップ
1. リポジトリをクローン:
   ```bash
   git clone <your-repo-url>
   cd android-my-car-navi
