import subprocess
import time
import sys

def get_gpu_memory():
    cmd = "nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits"
    output = subprocess.run(cmd, shell=True, text=True, capture_output=True)
    if output.stderr:
        print("Error:", output.stderr)
        return None, None
    try:
        # 余計なスペースや改行を除去してから最初のGPUのデータだけを取得
        memory_used, memory_total = map(int, output.stdout.split('\n')[0].split(','))
        return memory_used, memory_total
    except ValueError as e:
        print(f"Error processing output: {e}")
        return None, None

max_used = 0
try:
    while True:
        memory_used, memory_total = get_gpu_memory()
        if memory_used is None:
            continue
        if memory_used > max_used:
            max_used = memory_used
        sys.stdout.write(f"\rCurrent Memory: {memory_used} MB, Total Memory: {memory_total} MB, Max Used: {max_used} MB")
        sys.stdout.flush()
        time.sleep(0.01)
except KeyboardInterrupt:
    print("\nMonitoring stopped.")
