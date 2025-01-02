#!/bin/python3

import argparse
import re

def get_engines(lines):
    white = lines[0].split('>')[1].split('(')[0]
    black = lines[1].split('>')[1].split('(')[0]
    return white, black

def get_termination_info(lines):
    for line in reversed(lines):
        if 'Finished game' in line:
            return re.search(r':\s*(\S+).*?{([^}]+)}', line).group(1, 2)

def transform_engine_eval(score_type, score, is_white):

    assert score_type in [ 'cp', 'mate' ]

    if score_type == 'cp':
        return '%+.2f' % (float(score) * (1 if is_white else -1))

    if score_type == 'mate':
        dist = int(score) * (1 if is_white else -1)
        return '%cM%d' % ('+' if dist > 0 else '-', abs(dist))

def get_final_eval_info(lines, engine):
    for line in reversed(lines):
        if match := re.search(r'<%s.*\bscore\s+(mate|cp)\s+(-?\d+)' % (engine), line):
            return (match.group(1), match.group(2), 'tbhits' in line)


def check_log(file, tour_id, game_num):

    GOOD_REASONS = [
        'Black mates',
        'White mates',
        'Draw by 3-fold repetition',
        'Draw by adjudication',
        'Draw by adjudication: SyzygyTB',
        'Draw by fifty moves rule',
        'Draw by stalemate',
    ]

    BAD_REASONS = [
        'Black loses on time',
        'White loses on time',
        'Black\'s connection stalls',
        'White\'s connection stalls',
        'Black disconnects',
        'White disconnects',
    ]

    lines = file.readlines()
    white, black = get_engines(lines)
    result, reason = get_termination_info(lines)

    error = '\n[%s vs %s] %s %s (Game #%d, ie %d-%d)\n' % (
        white, black, result, reason, game_num, tour_id, tour_id+game_num)

    if reason in BAD_REASONS:
        print ('Bad Termination Reason', error)

    if reason not in GOOD_REASONS and reason not in BAD_REASONS:
        print ('Unknown Termination Reason', error)

    if reason == "Draw by adjudication: SyzygyTB":

        wdata = get_final_eval_info(lines, white) # type, score, has_tbhits
        bdata = get_final_eval_info(lines, black) # type, score, has_tbhits

        whigh = wdata[0] == 'mate' or (abs(int(wdata[1])) > 500 and wdata[2])
        bhigh = bdata[0] == 'mate' or (abs(int(bdata[1])) > 500 and bdata[2])

        if whigh or bhigh:
            white_eval = transform_engine_eval(*wdata[:2], True)
            black_eval = transform_engine_eval(*bdata[:2], False)
            print ('Syzygy Draw with White=%s Black=%s' % (white_eval, black_eval), error)


if __name__ == '__main__':

    p = argparse.ArgumentParser()
    p.add_argument('--tour',  type=int, required=True)
    p.add_argument('--games', type=int, required=True)
    args = p.parse_args()

    for n in range(args.games):
        with open('data/%d-%d.log' % (args.tour, args.tour+n+1)) as fin:
            x = check_log(fin, args.tour, n+1)
