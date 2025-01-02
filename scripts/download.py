#!/bin/python3

import argparse
import os
import requests
import shutil
import tempfile
import zipfile

def download_logfile(tour_id, game_id, out_dir):

    print ('Downloading game #%d from %d' % (game_id - tour_id, tour_id))

    base_url = 'https://cccfiles.chess.com/archive/cutechess.debug-%d-%d.zip'
    response = requests.get(base_url % (tour_id, game_id))
    assert response.status_code == 200

    with tempfile.NamedTemporaryFile(delete=False) as temp_zip:
        temp_zip.write(response.content)

    with tempfile.TemporaryDirectory() as temp_dir:

        with zipfile.ZipFile(temp_zip.name, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)

        old_file_path = os.path.join(temp_dir, os.listdir(temp_dir)[0])
        working_dir   = os.path.dirname(os.path.abspath(__file__))
        new_file_path = os.path.join(working_dir, out_dir, '%d-%d.log' % (tour_id, game_id))
        shutil.copy(old_file_path, new_file_path)

def download_event(tour_id, games, out_dir, start=0):
    for f in range(start, games):
        download_logfile(tour_id, tour_id + 1 + f, out_dir)


if __name__ == '__main__':

    p = argparse.ArgumentParser()
    p.add_argument('--tour',  type=int, required=True)
    p.add_argument('--games', type=int, required=True)
    p.add_argument('--out',   type=str, default='data')
    args = p.parse_args()

    if not os.path.exists(args.out):
        os.makedirs(args.out)

    download_event(args.tour, args.games, args.out)
