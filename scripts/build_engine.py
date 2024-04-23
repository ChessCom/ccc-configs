#!/bin/python3

import argparse
import os
import time

def gather_secrets():
    cwd     = os.path.dirname(os.path.realpath(__file__))
    secrets = os.path.join(cwd, '..', 'secrets')
    return [f for f in os.listdir(secrets) if not f.startswith('.')]

def build_command(engine):

    if not os.path.exists('../dockers/%s.Dockerfile' % (engine)):
        raise Exception('Dockerfile for %s does not exist in ../dockers/' % (engine))

    secrets = ''
    for secret in gather_secrets():
        secrets += ' --secret id=%s,src=../secrets/%s' % (secret, secret)

    return ' docker build' \
         + secrets \
         + ' --network=host' \
         + ' --build-arg CACHE_BUST=%d' % (int(time.time())) \
         + ' -t ccc-engines/%s' % (engine) \
         + ' -f ../dockers/%s.Dockerfile .' % (engine)

if __name__ == '__main__':

    p = argparse.ArgumentParser()
    p.add_argument('engine', help='Engine Name')
    p.add_argument('--dry', action='store_true', help='Print build command only')
    args = p.parse_args()

    if args.dry:
        print (build_command(args.engine))

    else:
        os.system(build_command(args.engine))
