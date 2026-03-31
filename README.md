# Hatake API

Rails 8 API モード で構築した、圃場状態共有アプリのバックエンドです。

## 技術スタック
- Ruby 3.4 / Rails 8（API モード）
- PostgreSQL
- Devise + devise-jwt（JWT認証）
- rack-cors

## エンドポイント一覧
| メソッド | パス | 説明 |
|---|---|---|
| POST | /api/v1/users/sign_up | ユーザー登録 |
| POST | /api/v1/users/sign_in | ログイン |
| DELETE | /api/v1/users/sign_out | ログアウト |
| POST | /api/v1/groups | グループ作成 |
| GET | /api/v1/groups/:id | グループ詳細 |
| POST | /api/v1/groups/:id/join | 招待トークンで参加 |
| GET | /api/v1/groups/:group_id/fields | 圃場一覧（最新ログ付き） |
| POST | /api/v1/groups/:group_id/fields | 圃場作成 |
| PATCH | /api/v1/groups/:group_id/fields/:id | 圃場更新 |
| DELETE | /api/v1/groups/:group_id/fields/:id | 圃場削除 |
| GET | /api/v1/field_logs?field_id=X | ログ一覧 |
| POST | /api/v1/field_logs | ログ作成 |

## ローカル起動
```bash
bundle install
cp .env.example .env.development
rails db:create db:migrate
rails s -p 3001
```

## 設計のポイント
- JWT認証はJTIマッチャーでトークン無効化を実装
- 無料プランの圃場10件制限をAPIレベルで制御
- field_logsを積み上げ式にすることで更新履歴が自動的に生育ログとして機能
- 写真はAWS S3（Active Storage）に保存。最大3枚まで添付可能

## Renderデプロイ時の環境変数
Renderのダッシュボード（Environment → Environment Variables）に以下を追加してください：

| 変数名 | 説明 |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWSアクセスキーID |
| `AWS_SECRET_ACCESS_KEY` | AWSシークレットアクセスキー |
| `AWS_REGION` | `ap-northeast-1` |
| `AWS_BUCKET` | `hatake-field-photos` |

また、デプロイ時に `rails db:migrate` が実行されるため、Active Storageのマイグレーション（`create_active_storage_tables`）も自動で適用されます。
