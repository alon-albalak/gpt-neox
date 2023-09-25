# GENERAL CONFIGS THAT WILL BE USED FOR ALL RUNS
CONFIGS="alon_configs/data/pile.yml alon_configs/init.yml alon_configs/models/1B_unnamed_train_datasets.yml alon_configs/eval_tasks.yml alon_configs/train_data_weights/doremi_120.yml"
# Doesn't include alon_configs/parallelism.yml

WANDB_GROUP="1B_doremi_120_unnamed_train_datasets"

# SEEDS=(1234 42 100 222)
SEEDS=( 42 100 )

# RUN SPECIFIC CONFIGS
for SEED in ${SEEDS[@]}; do
    RUN_NAME="${WANDB_GROUP}_seed${SEED}"
    ARGS="--seed ${SEED} --save outputs/${RUN_NAME} --wandb_group ${WANDB_GROUP} --wandb_run_name seed${SEED}"
    python3 tools/create_run_specific_config.py ${ARGS}
    RUN_SPECIFIC_CONFIG="alon_configs/run_specific/${RUN_NAME}.yml"
    echo "Running with configs: ${CONFIGS} ${RUN_SPECIFIC_CONFIG}"
    python3 deepy.py train.py ${CONFIGS} ${RUN_SPECIFIC_CONFIG} 2>&1 | tee outputs/${RUN_NAME}.log

    # evaluate 0-shot
    bash scripts/evaluate.sh outputs/${RUN_NAME}/global_step100000/configs/${RUN_NAME}.yml alon_configs/models/eval_1B_1gpu.yml
    # evaluate 5-shot
    bash scripts/evaluate.sh outputs/${RUN_NAME}/global_step100000/configs/${RUN_NAME}.yml alon_configs/models/eval_1B_1gpu.yml 5
done