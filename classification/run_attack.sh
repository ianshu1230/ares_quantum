#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# =============== 使用者可調整參數（只改這裡） =================
# ============================================================

# --- device ---
GPU="0"                       # 使用哪張 GPU（0/1/2...）；沒 GPU 會自動用 CPU

# --- dataset ---
DATASET="cifar10"             # "cifar10" 或 "imagenet"
DATA_DIR="DATA_PATH"          # ImageNet 才需要；CIFAR-10 只是下載位置/快取位置
LABEL_FILE="LABEL_PATH"       # ImageNet 才需要（val label 對照檔）

# --- dataloader ---
BATCHSIZE="20"                # batch size（越大越快但更吃顯存）
NUM_WORKERS="16"              # dataloader workers（Linux 可拉高；太高可能反而卡）

# --- model / attack ---
MODEL_NAME="resnet50_at"      # 必須在 cifar_model_zoo / imagenet_model_zoo
ATTACK_NAME="pgd"             # 必須在 registry.get_attack() 支援的攻擊

# --- ImageNet preprocessing（DATASET=imagenet 才會用到） ---
CROP_PCT="0.875"              # resize -> center crop 的 crop 比例
INPUT_SIZE="224"              # 最終輸入尺寸（224x224）
INTERPOLATION="bilinear"      # "bilinear" 或 "bicubic"

if [[ "${DATASET}" != "cifar10" && "${DATASET}" != "imagenet" ]]; then
  echo "[ERROR] DATASET must be 'cifar10' or 'imagenet'. Got: ${DATASET}" >&2
  exit 1
fi

if [[ "${INTERPOLATION}" != "bilinear" && "${INTERPOLATION}" != "bicubic" ]]; then
  echo "[ERROR] INTERPOLATION must be 'bilinear' or 'bicubic'. Got: ${INTERPOLATION}" >&2
  exit 1
fi

if [[ "${DATASET}" == "imagenet" ]]; then
  if [[ "${DATA_DIR}" == "DATA_PATH" || -z "${DATA_DIR}" ]]; then
    echo "[ERROR] For ImageNet, you must set DATA_DIR in this .sh (currently: ${DATA_DIR})." >&2
    exit 1
  fi
  if [[ "${LABEL_FILE}" == "LABEL_PATH" || -z "${LABEL_FILE}" ]]; then
    echo "[ERROR] For ImageNet, you must set LABEL_FILE in this .sh (currently: ${LABEL_FILE})." >&2
    exit 1
  fi
fi

echo "[INFO] Running classification attack:"
echo "  GPU=${GPU}"
echo "  DATASET=${DATASET}"
echo "  DATA_DIR=${DATA_DIR}"
echo "  LABEL_FILE=${LABEL_FILE}"
echo "  BATCHSIZE=${BATCHSIZE}"
echo "  NUM_WORKERS=${NUM_WORKERS}"
echo "  MODEL_NAME=${MODEL_NAME}"
echo "  ATTACK_NAME=${ATTACK_NAME}"
echo "  CROP_PCT=${CROP_PCT}"
echo "  INPUT_SIZE=${INPUT_SIZE}"
echo "  INTERPOLATION=${INTERPOLATION}"
echo

# ============================================================
# ============================ 執行 ===========================
# ============================================================

python3 run_attack.py \
  --gpu "${GPU}" \
  --crop_pct "${CROP_PCT}" \
  --input_size "${INPUT_SIZE}" \
  --interpolation "${INTERPOLATION}" \
  --data_dir "${DATA_DIR}" \
  --label_file "${LABEL_FILE}" \
  --batchsize "${BATCHSIZE}" \
  --num_workers "${NUM_WORKERS}" \
  --model_name "${MODEL_NAME}" \
  --attack_name "${ATTACK_NAME}" \
  --dataset "${DATASET}"
