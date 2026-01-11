#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# run_attack.sh
# - Wrapper for: python run_attack.py ...
# - You can override defaults via:
#     1) environment variables (recommended), e.g.
#        DATA_DIR=/path LABEL_FILE=/path ./run_attack.sh
#     2) CLI options, e.g.
#        ./run_attack.sh --gpu 0 --batchsize 32
# ============================================================

# -----------------------------
# Defaults (edit here or override)
# -----------------------------
GPU="${GPU:-0}"

# ImageNet preprocessing
CROP_PCT="${CROP_PCT:-0.875}"
INPUT_SIZE="${INPUT_SIZE:-224}"
INTERP="${INTERP:-bilinear}"  # bilinear | bicubic

# Dataset
DATA_DIR="${DATA_DIR:-DATA_PATH}"
LABEL_FILE="${LABEL_FILE:-LABEL_PATH}"
DATASET="${DATASET:-imagenet}"   # imagenet | cifar10

# Dataloader
BATCHSIZE="${BATCHSIZE:-20}"
NUM_WORKERS="${NUM_WORKERS:-16}"

# Model / Attack
MODEL_NAME="${MODEL_NAME:-resnet50_at}"
ATTACK_NAME="${ATTACK_NAME:-pgd}"

# -----------------------------
# Simple CLI override parser
# -----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --gpu) GPU="$2"; shift 2 ;;
    --crop_pct) CROP_PCT="$2"; shift 2 ;;
    --input_size) INPUT_SIZE="$2"; shift 2 ;;
    --interpolation) INTERP="$2"; shift 2 ;;
    --data_dir) DATA_DIR="$2"; shift 2 ;;
    --label_file) LABEL_FILE="$2"; shift 2 ;;
    --dataset) DATASET="$2"; shift 2 ;;
    --batchsize) BATCHSIZE="$2"; shift 2 ;;
    --num_workers) NUM_WORKERS="$2"; shift 2 ;;
    --model_name) MODEL_NAME="$2"; shift 2 ;;
    --attack_name) ATTACK_NAME="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
Usage:
  ./run_attack.sh [options]

Options:
  --gpu <id>                 GPU id(s). Default: ${GPU}
  --crop_pct <float>         Center crop percent. Default: ${CROP_PCT}
  --input_size <int>         Input size after crop. Default: ${INPUT_SIZE}
  --interpolation <mode>     bilinear|bicubic. Default: ${INTERP}
  --data_dir <path>          Dataset root dir. Default: ${DATA_DIR}
  --label_file <path>        ImageNet label file. Default: ${LABEL_FILE}
  --dataset <name>           imagenet|cifar10. Default: ${DATASET}
  --batchsize <int>          Batch size. Default: ${BATCHSIZE}
  --num_workers <int>        DataLoader workers. Default: ${NUM_WORKERS}
  --model_name <name>        Model name in model zoo. Default: ${MODEL_NAME}
  --attack_name <name>       Attack name in registry. Default: ${ATTACK_NAME}

Env overrides (same keys): GPU, CROP_PCT, INPUT_SIZE, INTERP, DATA_DIR, LABEL_FILE,
                          DATASET, BATCHSIZE, NUM_WORKERS, MODEL_NAME, ATTACK_NAME
EOF
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      echo "        Run: ./run_attack.sh --help" >&2
      exit 1
      ;;
  esac
done

# -----------------------------
# Basic sanity checks
# -----------------------------
if [[ "${DATASET}" == "imagenet" ]]; then
  if [[ "${DATA_DIR}" == "DATA_PATH" || -z "${DATA_DIR}" ]]; then
    echo "[ERROR] DATA_DIR is not set. Provide --data_dir or env DATA_DIR." >&2
    exit 1
  fi
  if [[ "${LABEL_FILE}" == "LABEL_PATH" || -z "${LABEL_FILE}" ]]; then
    echo "[ERROR] LABEL_FILE is not set. Provide --label_file or env LABEL_FILE." >&2
    exit 1
  fi
fi

if [[ "${INTERP}" != "bilinear" && "${INTERP}" != "bicubic" ]]; then
  echo "[ERROR] interpolation must be bilinear or bicubic. Got: ${INTERP}" >&2
  exit 1
fi

echo "[INFO] Running attack with:"
echo "  GPU=${GPU}"
echo "  DATASET=${DATASET}"
echo "  DATA_DIR=${DATA_DIR}"
echo "  LABEL_FILE=${LABEL_FILE}"
echo "  MODEL_NAME=${MODEL_NAME}"
echo "  ATTACK_NAME=${ATTACK_NAME}"
echo "  BATCHSIZE=${BATCHSIZE}"
echo "  NUM_WORKERS=${NUM_WORKERS}"
echo "  CROP_PCT=${CROP_PCT}"
echo "  INPUT_SIZE=${INPUT_SIZE}"
echo "  INTERP=${INTERP}"
echo

# -----------------------------
# Run
# -----------------------------
python run_attack.py \
  --gpu "${GPU}" \
  --crop_pct "${CROP_PCT}" \
  --input_size "${INPUT_SIZE}" \
  --interpolation "${INTERP}" \
  --data_dir "${DATA_DIR}" \
  --label_file "${LABEL_FILE}" \
  --batchsize "${BATCHSIZE}" \
  --num_workers "${NUM_WORKERS}" \
  --model_name "${MODEL_NAME}" \
  --attack_name "${ATTACK_NAME}" \
  --dataset "${DATASET}"
