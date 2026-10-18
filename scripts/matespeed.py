#!/usr/bin/env python3

import argparse
import os
import re

from websockets.sync.client import connect

import audit

HEADER_PATTERN = re.compile(r'^\[(\w+)\s+"(.*)"\]\s*$')
TOKEN_PATTERN = re.compile(r'\{([^}]*)\}|(\S+)')
MOVE_NUMBER_PATTERN = re.compile(r'^\d+\.+$')
RESULTS = {'1-0', '0-1', '1/2-1/2', '*'}
MATE_PATTERN = re.compile(r'^[+-]M\d+')

def parse_pgn(path):
    # Returns (white, black, result, {engine: ply of first reported mate}), where
    # ply is 1-indexed, so white moves are odd plies and black moves are even
    headers = {}
    movetext = []

    with open(path, 'r', errors='replace') as f:
        for line in f:
            match = HEADER_PATTERN.match(line)
            if match:
                headers[match.group(1)] = match.group(2)
            else:
                movetext.append(line)

    white, black = headers.get('White'), headers.get('Black')
    if not white or not black:
        return None

    first_mate = {}
    ply = 0

    for match in TOKEN_PATTERN.finditer(' '.join(movetext)):
        comment, token = match.groups()

        if comment is not None:
            if ply and MATE_PATTERN.match(comment):
                engine = white if ply % 2 == 1 else black
                first_mate.setdefault(engine, ply)
        elif token not in RESULTS and not MOVE_NUMBER_PATTERN.match(token):
            ply += 1

    return white, black, headers.get('Result', '*'), first_mate

def load_games(event_id, game_nums):
    pgn_dir = os.path.join('pgn', str(event_id))
    games = []

    for game_nr in sorted(int(g) for g in game_nums):
        path = os.path.join(pgn_dir, f'{game_nr}.pgn')
        if not os.path.exists(path):
            continue

        try:
            game = parse_pgn(path)
        except Exception as error:
            print(f'Failed to parse game #{game_nr}: {error}')
            continue

        if game:
            games.append(game)

    return games

def summarize(games, engine_a, engine_b, winner=None):
    # Compare only games matching the winner filter (None means every game)
    first_a = first_b = both = 0
    lead_total = 0

    for white, black, result, first_mate in games:
        if winner is not None:
            game_winner = white if result == '1-0' else black if result == '0-1' else None
            if game_winner != winner:
                continue

        ply_a, ply_b = first_mate.get(engine_a), first_mate.get(engine_b)
        if ply_a is None and ply_b is None:
            continue

        if ply_b is None or (ply_a is not None and ply_a < ply_b):
            first_a += 1
        else:
            first_b += 1

        if ply_a is not None and ply_b is not None:
            both += 1
            lead_total += ply_b - ply_a

    return first_a, first_b, both, lead_total

def report_event(name, event_id, games):
    engines = sorted({engine for white, black, _, _ in games for engine in (white, black)})
    if len(engines) != 2:
        print(f'Skipping {name} (event {event_id}): expected 2 engines, found {len(engines)}')
        print()
        return

    engine_a, engine_b = engines

    scenarios = [
        ('All games', None),
        (f'{engine_a} wins', engine_a),
        (f'{engine_b} wins', engine_b),
    ]

    rows = []
    one_sided = 0
    for label, winner in scenarios:
        first_a, first_b, both, lead_total = summarize(games, engine_a, engine_b, winner)
        if first_a + first_b == 0:
            continue

        if winner is None:
            one_sided = first_a + first_b - both

        # Positive means engine A reported mate that many ply earlier on average
        lead = f'{lead_total / both:+.2f}' if both else 'n/a'
        rows.append([label, f'{first_a + first_b:,}', f'{first_a:,}', f'{first_b:,}', lead])

    print(f'Mate speed for {name} (event {event_id}): {engine_a} vs {engine_b}')

    if not rows:
        print('    No mate scores reported')
        print()
        return

    print_headers = ['Scenario', 'Mates', f'{engine_a} first', f'{engine_b} first', f'Avg ply lead ({engine_a})']
    audit.print_table(print_headers, rows)
    print()
    print(f'    Mates: games where either engine reported a mate score')
    if one_sided:
        print(f'    {one_sided:,} of those had only one engine report mate; they count toward "first" but not the average')
    print(f'    Avg ply lead: over games where both reported mate; positive means {engine_a} reported first,')
    print(f'    negative means {engine_b} did. "X wins" rows compare the winner against the loser.')
    print()

def run(event_pattern, debug=False):
    audit.DEBUG = debug
    pattern = re.compile(event_pattern)

    with connect('wss://ccc-api.gcp-prod.chess.com/ws', max_size=10 * 1024 * 1024) as websocket:
        audit.send_request(websocket, {'type': 'requestEventsListUpdate'})
        events = audit.wait_for_events_list(websocket)

        matching_events = audit.find_matching_events(events, pattern)
        matching_events.sort(key=lambda x: x[1])

        all_game_numbers = {}
        for name, event_id in matching_events:
            all_game_numbers[name] = audit.get_game_numbers_for_event(websocket, event_id)

        audit.download_pgns_for_events(websocket, matching_events, all_game_numbers)

    print()
    for name, event_id in matching_events:
        games = load_games(event_id, all_game_numbers.get(name, []))
        if games:
            report_event(name, event_id, games)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Compare which engine reports mate first in a two engine event')
    parser.add_argument('--event', required=True, help='Regex pattern to match event name(s)')
    parser.add_argument('--debug', action='store_true', default=False, help='Print all WebSocket requests')
    args = parser.parse_args()

    run(args.event, args.debug)
