#!/bin/python3

import argparse
import os
import requests
import subprocess
import sys
import time

NIDs = {
    'stockfish'   : 134798, 'dragon'      : 184247, 'igel'        : 194311, 'minic'       : 194313,
    'weiss'       : 194315, 'seer'        : 194319, 'berserk'     : 237525, 'revenge'     : 248822,
    'arasan'      :    263, 'booot'       :    266, 'ethereal'    :    274, 'winter'      :  27577,
    'rubi'        :  27766, 'wasp'        :    296, 'blackmarlin' : 298296, 'velvet'      : 298345,
    'tucano'      : 298351, 'stash'       : 304831, 'smallbrain'  : 305443, 'marvin'      : 305445,
    'uralochka'   : 305548, 'clover'      : 331673, 'caissa'      : 331675, 'torch'       : 345753,
    'svart'       : 352619, 'whitecore'   : 352620, 'carp'        : 352621, 'viridithas'  : 352622,
    'altair'      : 352623, 'stormphrax'  : 352624, 'stockdory'   : 352625, 'equisetum'   : 352627,
    'obsidian'    : 366189, 'midnight'    : 372997, 'willow'      : 372999, 'akimbo'      : 373001,
    'plentychess' : 376027, 'minitorch'   : 395059, 'minifish'    : 395060, 'halogen'     : 194321,
    'patricia'    : 396677, 'integral'    : 399594, 'clarity'     : 399596, 'renegade'    : 399598,
    'rofchade'    :  18526, 'heimdall'    : 422506,
}

def gather_secrets():
    return [f for f in os.listdir('../secrets') if not f.startswith('.')]

def build_command(args, engine):

    if not os.path.exists('../dockers/%s.Dockerfile' % (engine)):
        raise Exception('Dockerfile for %s does not exist in ../dockers/' % (engine))

    if args.sudo:
        base_command = 'DOCKER_BUILDKIT=1 sudo docker build'
    else:
        base_command = 'DOCKER_BUILDKIT=1 docker build'

    if args.verbose:
        base_command += ' --progress plain'

    secrets = ''
    for secret in gather_secrets():
        secrets += ' --secret id=%s,src=../secrets/%s' % (secret, secret)

    return base_command \
         + secrets \
         + ' --network=host' \
         + ' --build-arg CACHE_BUST=%d' % (int(time.time())) \
         + ' -t ccc-engines/%s' % (engine) \
         + ' -f ../dockers/%s.Dockerfile .' % (engine)

def get_version(args, engine):

    cmd = ['docker run --rm -i ccc-engines/%s' % (engine)]

    if args.sudo:
        cmd[0] = 'sudo ' + cmd[0]

    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, universal_newlines=True, shell=True)

    proc.stdin.write('uci\n')
    proc.stdin.flush()

    while 'id name' not in (line := proc.stdout.readline().rstrip()):
        pass

    proc.stdin.write('quit\n')
    proc.stdin.flush()
    proc.wait()

    return ' '.join(line.split()[3:])

def update_version(args, engine):

    if not os.path.exists('../secrets/.update_endpoint'):
        raise Exception('No known server update endpoint')

    params = {
        'id'      : NIDs[engine],
        'version' : get_version(args, engine),
    }

    with open('../secrets/.update_endpoint') as fin:
        url = fin.readline().rstrip()

    for ii in range(5):
        requests.post(url, data=params)

    print ('Updated version for %s to %s' % (engine, params['version']))

if __name__ == '__main__':

    # Always working relative to this script
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    p = argparse.ArgumentParser()
    p.add_argument('engine',    help='Engine Name')
    p.add_argument('--dry',     help='Print build command only'       , action='store_true')
    p.add_argument('--skip',    help='Skip building entirely'         , action='store_true')
    p.add_argument('--update',  help='Update the CCC server version'  , action='store_true')
    p.add_argument('--sudo',    help='Run docker commands with sudo'  , action='store_true')
    p.add_argument('--verbose', help='Use plain progress Docker style', action='store_true')
    args = p.parse_args()

    if args.dry:
        print (build_command(args, args.engine))
        sys.exit()

    if not args.skip:
        os.system(build_command(args, args.engine))
        print ('Built version %s for %s' % (get_version(args, args.engine), args.engine))

    if args.update:
        update_version(args, args.engine)
