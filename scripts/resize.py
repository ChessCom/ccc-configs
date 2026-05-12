#!/bin/python3

import argparse
import os
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('--engine', required=True, nargs='+')
args = parser.parse_args()

def resize_image(in_file, out_file, new_size):
    with Image.open(in_file) as image:
        resized = image.resize(new_size, Image.LANCZOS)
        resized.save(out_file)

for engine in args.engine:
    input_file = '%s.png' % (engine)
    output_dir = 'images/%s' % (engine)

    desired = {
        '%s/lrg_%s.png'    % (output_dir, engine)  : ( 300, 300 ),
        '%s/lrg_%s@2x.png' % (output_dir, engine)  : ( 600, 600 ),
        '%s/sm_%s.png'     % (output_dir, engine)  : (  30,  30 ),
        '%s/sm_%s@2x.png'  % (output_dir, engine)  : (  60,  60 ),
        '%s/%s.png'        % (output_dir, engine)  : (  50,  50 ),
        '%s/%s@2x.png'     % (output_dir, engine)  : ( 100, 100 ),
    }

    os.makedirs(output_dir, exist_ok=True)

    for outname, dimensions in desired.items():
        resize_image(input_file, outname, dimensions)
