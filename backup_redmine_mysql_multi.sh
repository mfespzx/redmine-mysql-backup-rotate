#!/usr/bin/env bash

#
# Redmine (MySQL) DB dump & rotation script for Podman containers
#
# 複数の Redmine インスタンス用コンテナを走査し、
# 各 DB のダンプ取得と世代管理（ローテーション）を行うサンプルスクリプト。
#

set -o pipefail

#======================================================================
# 設定（環境に合わせて変更）
#======================================================================

# コンテナ群のベースディレクトリ（インスタンスごとにサブディレクトリを持つ想定）
BASE_DIR=${BASE_DIR:-/opt/redmine_podman/}

# ダンプファイルの保持世代数
GEN=${GEN:-10}

# mysqldump コマンド
MYSQL_DUMP_CMD=${MYSQL_DUMP_CMD:-mysqldump}

echo "base dir: ${BASE_DIR}"

#======================================================================
# メインループ
#======================================================================

# BASE_DIR 配下の各サブディレクトリをインスタンスとして扱う
for dir in "${BASE_DIR}"*/; do
  # サブディレクトリが無い場合のガード
  [ -d "$dir" ] || continue

  instance_name=$(basename "$dir")
  echo "== instance: ${instance_name} =="

  # ジョブ情報
  BACKUP_DIR="${dir%/}/db_backup"
  LOG_DIR="${BACKUP_DIR}/log"
  LOG_FILE="${LOG_DIR}/$(basename "$0").log"

  # MySQL 情報（ここは環境に合わせて書き換え）
  DB_NAME="db_${instance_name}"
  DB_USER="${instance_name}"
  DB_PASS="${instance_name}"

  # コンテナ名の命名規則（例: foo_db_mysql_1）
  CONTAINER_NAME="${instance_name}_db_mysql_1"

  # バックアップファイル情報
  FILE_NAME="redmine_${instance_name}.gz"

  # その他
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  USERNAME=$(whoami)

  #====================================================================
  # ログディレクトリ作成 & ログヘッダ
  #====================================================================
  mkdir -p "$LOG_DIR" "$BACKUP_DIR"

  {
    echo "********************************************************"
    echo "${TIMESTAMP} ${USERNAME}"
    echo "instance    : ${instance_name}"
    echo "container   : ${CONTAINER_NAME}"
    echo "backup_dir  : ${BACKUP_DIR}"
  } >> "$LOG_FILE"

  #====================================================================
  # ダンプ実行
  #====================================================================

  TMP_FILE="${BACKUP_DIR}/${FILE_NAME}_tmp"

  echo "running mysqldump on container: ${CONTAINER_NAME}" >> "$LOG_FILE"

  if podman exec -i "$CONTAINER_NAME" \
      "$MYSQL_DUMP_CMD" "$DB_NAME" --single-transaction \
      -u"$DB_USER" -p"$DB_PASS" 2>>"$LOG_FILE" \
      | gzip > "$TMP_FILE"
  then
    echo "backup success: ${TMP_FILE}" >> "$LOG_FILE"
  else
    echo "[ERROR] dump failed for ${instance_name}" >> "$LOG_FILE"
    rm -f "$TMP_FILE"
    # 他インスタンスへの処理は継続
    continue
  fi

  #====================================================================
  # ダンプファイルの世代管理
  #====================================================================

  # 古い方から順に繰り上げ（GEN → GEN+1, ..., 1 → 2）
  for ((i=GEN; i>=1; i--)); do
    n=$((i+1))
    OLD="${BACKUP_DIR}/${FILE_NAME}_${i}"
    NEW="${BACKUP_DIR}/${FILE_NAME}_${n}"
    if [ -e "$OLD" ]; then
      mv "$OLD" "$NEW"
    fi
  done

  # 世代番号なしを _1 へ
  if [ -e "${BACKUP_DIR}/${FILE_NAME}" ]; then
    mv "${BACKUP_DIR}/${FILE_NAME}" "${BACKUP_DIR}/${FILE_NAME}_1"
  fi

  # 一時ファイルを世代番号なしへ
  mv "$TMP_FILE" "${BACKUP_DIR}/${FILE_NAME}"

  # 古い世代 (GEN+1) を削除
  RM_NAME="${BACKUP_DIR}/${FILE_NAME}_$((GEN+1))"
  if [ -e "$RM_NAME" ]; then
    rm -f "$RM_NAME"
  fi

done

exit 0
