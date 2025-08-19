#!/bin/python3

from PIL import Image

INPUT_FILE = 'integral.png'
ENGINE     = 'integral'

DESIRED = {
    'output/lrg_%s.png'    % (ENGINE)  : ( 300, 300 ),
    'output/lrg_%s@2x.png' % (ENGINE)  : ( 600, 600 ),
    'output/sm_%s.png'     % (ENGINE)  : (  30,  30 ),
    'output/sm_%s@2x.png'  % (ENGINE)  : (  60,  60 ),
    'output/%s.png'        % (ENGINE)  : (  50,  50 ),
    'output/%s@2x.png'     % (ENGINE)  : ( 100, 100 ),
}

def resize_image(in_file, out_file, new_size):
    with Image.open(in_file) as image:
        resized = image.resize(new_size, Image.LANCZOS)
        resized.save(out_file)

for outname, dimensions in DESIRED.items():
    resize_image(INPUT_FILE, outname, dimensions)
