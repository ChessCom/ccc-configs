#!/bin/python3

import argparse
import os
import requests
import subprocess
import sys
import time

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

    cmd = ['docker run --cap-add=SYS_NICE --rm -i ccc-engines/%s' % (engine)]

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

if __name__ == '__main__':

    # Always working relative to this script
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    p = argparse.ArgumentParser()
    p.add_argument('engine',    help='Engine Name')
    p.add_argument('--dry',     help='Print build command only'       , action='store_true')
    p.add_argument('--skip',    help='Skip building entirely'         , action='store_true')
    p.add_argument('--sudo',    help='Run docker commands with sudo'  , action='store_true')
    p.add_argument('--verbose', help='Use plain progress Docker style', action='store_true')
    args = p.parse_args()

    if args.dry:
        print (build_command(args, args.engine))
        sys.exit()

    if not args.skip:
        os.system(build_command(args, args.engine))
        print ('Built version %s for %s' % (get_version(args, args.engine), args.engine))
