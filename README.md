# Redmine MySQL Backup & Rotation Script  
複数の Redmine（MySQL）インスタンスを運用する環境向けに、  
Podman コンテナ内の DB を自動でダンプ取得し、世代管理（ローテーション）まで行うサンプルスクリプトです。

実務では、Redmine を複数テナント運用しているケースや、  
Podman/Docker で Redmine + DB を個別に構築している環境で使用することを想定しています。

---

## ■ 機能概要

- BASE_DIR 配下の各 Redmine インスタンスを自動走査  
- 対応する MySQL コンテナへ `mysqldump` を実行  
- ダンプを gzip 圧縮して保存  
- 指定した世代数でローテーション  
- pipefail によるエラー検知  
- インスタンスごとにログを残す仕組みを備えた、運用向けスクリプト

---

## ■ スクリプト名

`backup_redmine_mysql_multi.sh`

---

## ■ 想定環境

- Linux (CentOS / Rocky / Ubuntu など)
- Podman  
- Redmine（Rails）
- MySQL / MariaDB
- Shell (bash)

---

## ■ ディレクトリ構成例




2. BASE_DIR など必要な設定を編集  
スクリプト先頭周辺にある定数を環境に合わせて変更してください。

例：

```bash
BASE_DIR=/opt/redmine_podman/
GEN=10


./backup_redmine_mysql_multi.sh
