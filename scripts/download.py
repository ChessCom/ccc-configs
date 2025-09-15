#!/bin/python3

import argparse
import os
import requests
import shutil
import tempfile
import zipfile

def download_logfile(start_id, game_num, out_dir):

    working_dir   = os.path.dirname(os.path.abspath(__file__))
    new_file_path = os.path.join(working_dir, out_dir, '%d.log' % (start_id + game_num))

    if os.path.exists(new_file_path):
        return

    base_url = 'https://storage.googleapis.com/chess-1-prod-ccc/gamelogs/game-%d.log'
    response = requests.get(base_url % (start_id + game_num))
    assert response.status_code == 200

    with open(new_file_path, 'wb') as fout:
        fout.write(response.content)

    print ('Downloaded game #%d' % (game_num + 1))

def download_event(start_id, games, out_dir, start=0):
    for game_num in range(games):
        try:
            download_logfile(start_id, game_num, out_dir)
        except Exception as error:
            print ('Failed to download game #%d' % (game_num + 1))

if __name__ == '__main__':

    p = argparse.ArgumentParser()
    p.add_argument('--start',  type=int, required=True)
    p.add_argument('--games',  type=int, required=True)
    p.add_argument('--out',    type=str, default='data')
    args = p.parse_args()

    if not os.path.exists(args.out):
        os.makedirs(args.out)

    download_event(args.start, args.games, args.out)
