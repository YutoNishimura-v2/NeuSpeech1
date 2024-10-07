#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

EXP_NAME=evaluate_speech
python_command="
python evaluation_speech.py\
 --base_model=openai/whisper-base \
 --lora_model=output_models/${EXP_NAME} \
 --load_lora_model=False\
 --test_data=/home/andante/workspace/proj_meg_codec/dataset/gwilliams2023/split/test.jsonl \
 --modal='speech' --batch_size=4 --num_workers=4 --language=english \
 --timestamps=False --local_files_only=False --noise=False
"

ENV_NAME=neuspeech
SRC_PATH=/home/andante/workspace/NeuSpeech1
WANDB_API_KEY=390a430742158a6ae7883a0b165af4ce6781cae5

# 以下コード
source ~/miniconda3/etc/profile.d/conda.sh
conda activate ${ENV_NAME}

cd ${SRC_PATH}
export PYTHONPATH=${SRC_PATH}
export WANDB_API_KEY=${WANDB_API_KEY}
${python_command}

