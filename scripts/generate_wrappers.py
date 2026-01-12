#!/usr/bin/env python3

import os

# Set CWD to the Script's directory
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Paths
DOCKER_DIR  = '../dockers'
WRAPPER_DIR = '../wrappers'

# Make sure wrappers directory exists
os.makedirs(WRAPPER_DIR, exist_ok=True)

# CPU: Mount Syzygy; Disable Network; Enable sys_nice
SCRIPT_BUILDER  = '#!/bin/bash\n'
SCRIPT_BUILDER += 'docker run -v /data/tablebases:/data/tablebases -v /data/engines/weights:/weights \\\n'
SCRIPT_BUILDER += '    --cap-add=SYS_NICE --network none --rm -i ccc-engines/%s'

# GPU: Also set --gpus and --runtime=nvidia
GPU_SCRIPT_BUILDER  = '#!/bin/bash\n'
GPU_SCRIPT_BUILDER += 'docker run --gpus \'"device=0,1"\' \\\n'
GPU_SCRIPT_BUILDER += '    -v /data/tablebases:/data/tablebases -v /data/engines/weights:/weights \\\n'
GPU_SCRIPT_BUILDER += '    --runtime=nvidia --cap-add=SYS_NICE --network none --rm -i ccc-engines/%s'

for filename in os.listdir(DOCKER_DIR):

    if '.Dockerfile' not in filename:
        continue

    engine_name = filename.split('.Dockerfile')[0]
    wrapper_path = os.path.join(WRAPPER_DIR, f'{engine_name}.sh')

    if engine_name == 'lc0':
        content = GPU_SCRIPT_BUILDER % (engine_name)
    else:
        content = SCRIPT_BUILDER % (engine_name)

    with open(wrapper_path, 'w') as f:
        f.write(content)
