#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

EXP_NAME=gwilliams2023_base
python_command="
python finetune.py --per_device_train_batch_size=112 \
 --per_device_eval_batch_size=112 --output_dir='output_models/${EXP_NAME}' \
 --eval_steps=1000 --save_steps=1000 \
 --learning_rate=1e-3 --fp16=True \
 --num_train_epochs=500 --warmup_steps=500 --max_audio_len=30 \
 --use_8bit=False --num_workers=16 --modal='eeg' --eeg_ch=208 --sampling_rate=200 --orig_sample_rate=200 \
 --train_data='/home/acd13708uu/gcb50169/NeuSpeech1/dataset/gwilliams2023/preprocess/split1/train.jsonl' \
 --test_data='/home/acd13708uu/gcb50169/NeuSpeech1/dataset/gwilliams2023/preprocess/split1/val.jsonl' \
 --base_model='openai/whisper-base' --augment_config_path='configs/augmentation1.json' \
 --local_files_only=False --language='English' --device='cuda'
"

h_rt='20:00:00'  # 72, 72, 72, 168
node_name="rt_AG.small"  # rt_AG.small, rt_AF, rt_G.small, rt_F

EMAIL_ADDRESS=yutonishimurav20512@gmail.com
ABCI_GROUP=gcb50169
ENV_PATH=~/venv/neuspeech/bin/activate
SRC_PATH=/home/acd13708uu/gcb50169/NeuSpeech1
LOG_PATH=/home/acd13708uu/gcb50169/NeuSpeech1/logs/exp
WANDB_API_KEY=390a430742158a6ae7883a0b165af4ce6781cae5

# 以下コード

log_folder=${LOG_PATH}/${EXP_NAME}
mkdir -p ${LOG_PATH}/${EXP_NAME}
cd ${log_folder}

echo "job 生成を開始します．"

base_command="#!/usr/bin/env bash \n\
set -e \n\
set -u \n\
set -o pipefail \n\
source /etc/profile.d/modules.sh \n\
module load python/3.11/3.11.9 cuda/11.8/11.8.0 cudnn/8.9/8.9.7 gcc/13.2.0 \n\
source ${ENV_PATH} \n\
cd ${SRC_PATH} \n\
export PYTHONPATH=${SRC_PATH} \n\
export WANDB_API_KEY=${WANDB_API_KEY} \n\
${python_command} \n\
deactivate"

file_name=${EXP_NAME}
echo -e "${base_command}" > ${file_name}.sh
chmod +x ${file_name}.sh
# job_id=`qsub -g ${ABCI_GROUP} -j y -cwd -terse -M ${EMAIL_ADDRESS} -m sabe -l ${node_name}=1 -l h_rt=${h_rt} -o ${log_folder}/${file_name}.log ${file_name}.sh`
# echo "job_id: ${job_id} を生成しました."
# ps aux | grep gs |awk '{print $2}' | xargs kill
echo "nohup bash ${log_folder}/${file_name}.sh &> ${log_folder}/${file_name}.log &"
