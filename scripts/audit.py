#!/usr/bin/env python3

import json
import argparse
import sys
import re
import os
import requests

from websockets.sync.client import connect

DEBUG = False

def send_request(websocket, request):
    if DEBUG:
        print(f'DEBUG: Sending {json.dumps(request)}')
    websocket.send(json.dumps(request))

def find_game_numbers(obj, game_numbers=None):
    if game_numbers is None:
        game_numbers = set()

    if isinstance(obj, dict):
        for key, value in obj.items():
            if key == 'gameNr':
                game_numbers.add(value)
            else:
                find_game_numbers(value, game_numbers)
    elif isinstance(obj, list):
        for item in obj:
            find_game_numbers(item, game_numbers)

    return game_numbers

def normalize_messages(messages):
    if not isinstance(messages, list):
        return [messages]
    return messages

def wait_for_events_list(websocket):
    while True:
        response = websocket.recv()
        messages = normalize_messages(json.loads(response))

        for message in messages:
            if message.get('type') == 'eventsListUpdate':
                return message.get('events', [])

def find_matching_events(events, pattern):
    matching = []
    for event in events:
        event_name = event.get('name', '')
        if pattern.search(event_name):
            event_id = event.get('id')
            matching.append((event_name, event_id))
    return matching

def wait_for_event_update(websocket):
    while True:
        response = websocket.recv()
        messages = normalize_messages(json.loads(response))

        for message in messages:
            if message.get('type') == 'eventUpdate':
                return message

def wait_for_game_update(websocket):
    while True:
        response = websocket.recv()
        messages = normalize_messages(json.loads(response))

        for message in messages:
            if message.get('type') == 'gameUpdate':
                return message

def get_game_numbers_for_event(websocket, event_id):
    event_request = {'type': 'requestEvent', 'eventNr': event_id}
    send_request(websocket, event_request)

    event_update = wait_for_event_update(websocket)
    return list(find_game_numbers(event_update))

def download_log(game_nr, event_id):
    game_nr = int(game_nr)
    logs_dir = os.path.join('logs', str(event_id))
    os.makedirs(logs_dir, exist_ok=True)

    log_path = os.path.join(logs_dir, f'{game_nr}.log')
    if os.path.exists(log_path):
        return True

    base_url = 'https://storage.googleapis.com/chess-1-prod-ccc/gamelogs/game-%d.log'
    response = requests.get(base_url % game_nr)
    assert response.status_code == 200

    with open(log_path, 'wb') as fout:
        fout.write(response.content)

    return True

def check_log_file(log_path, game_nr, event_name, min_game_nr):
    patterns = [
        r'Engine .* loses on time',
        r'Engine .* stalls',
        r'Engine .* disconnects'
    ]

    game_nr_int = int(game_nr)
    event_game_num = 1 + game_nr_int - min_game_nr

    with open(log_path, 'r') as f:
        content = f.read()
        for pattern in patterns:
            matches = re.finditer(pattern, content)
            for match in matches:
                print(f'{game_nr} (game #%4d): {event_name}, {match.group()}' % event_game_num)

def download_pgn(websocket, game_nr, event_id):
    game_nr = int(game_nr)
    pgn_dir = os.path.join('pgn', str(event_id))
    os.makedirs(pgn_dir, exist_ok=True)

    pgn_path = os.path.join(pgn_dir, f'{game_nr}.pgn')
    if os.path.exists(pgn_path):
        return True

    game_request = {'type': 'requestEvent', 'gameNr': game_nr}
    send_request(websocket, game_request)

    game_update = wait_for_game_update(websocket)
    pgn_content = game_update.get('gameDetails', {}).get('pgn', '')

    with open(pgn_path, 'w') as fout:
        fout.write(pgn_content)

    return True

def download_pgns_for_events(websocket, matching_events, all_game_numbers):
    for name, event_id in matching_events:
        game_nums = all_game_numbers.get(name, [])
        if not game_nums:
            continue

        game_nums_sorted = sorted([int(g) for g in game_nums])
        total = len(game_nums_sorted)

        print(f'Downloading PGNs for {name} (event {event_id}): 0/{total}', end='', flush=True)

        for idx, game_nr in enumerate(game_nums_sorted, 1):
            try:
                download_pgn(websocket, game_nr, event_id)
            except Exception as error:
                print(f'\nFailed to download PGN #{game_nr}: {error}')

            print(f'\rDownloading PGNs for {name} (event {event_id}): {idx}/{total}', end='', flush=True)

        print()

def check_logs_for_events(matching_events, all_game_numbers):
    for name, event_id in matching_events:
        game_nums = all_game_numbers.get(name, [])
        if not game_nums:
            continue

        logs_dir = os.path.join('logs', str(event_id))
        if not os.path.exists(logs_dir):
            continue

        game_nums_sorted = sorted([int(g) for g in game_nums])
        min_game_nr = game_nums_sorted[0]

        for game_nr in game_nums_sorted:
            log_path = os.path.join(logs_dir, f'{game_nr}.log')
            if os.path.exists(log_path):
                try:
                    check_log_file(log_path, game_nr, name, min_game_nr)
                except Exception as error:
                    pass

def download_logs_for_events(matching_events, all_game_numbers):
    for name, event_id in matching_events:
        game_nums = all_game_numbers.get(name, [])
        if not game_nums:
            continue

        game_nums_sorted = sorted([int(g) for g in game_nums])
        total = len(game_nums_sorted)

        print(f'Downloading logs for {name} (event {event_id}): 0/{total}', end='', flush=True)

        for idx, game_nr in enumerate(game_nums_sorted, 1):
            try:
                download_log(game_nr, event_id)
            except Exception as error:
                print(f'\nFailed to download game #{game_nr}: {error}')

            print(f'\rDownloading logs for {name} (event {event_id}): {idx}/{total}', end='', flush=True)

        print()

def print_all_messages(websocket):
    request = {'type': 'requestEventsListUpdate'}
    send_request(websocket, request)
    print(f'Sent: {json.dumps(request)}\n')

    while True:
        response = websocket.recv()
        messages = json.loads(response)
        print(json.dumps(messages, indent=2))
        print()

def process_events(websocket, pattern, download_logs=False, check_logs=False, download_pgns=False):
    request = {'type': 'requestEventsListUpdate'}
    send_request(websocket, request)

    # Step 1: Collect matching events
    events = wait_for_events_list(websocket)
    matching_events = find_matching_events(events, pattern)
    matching_events.sort(key=lambda x: x[1])

    print('Matching events:')
    for name, event_id in matching_events:
        print(f'{event_id}: {name}')
    print()

    # Step 2: Get game numbers for each event
    all_game_numbers = {}
    for name, event_id in matching_events:
        game_nums = get_game_numbers_for_event(websocket, event_id)
        all_game_numbers[name] = game_nums

    print('Game numbers by event:')
    for name, game_nums in all_game_numbers.items():
        if game_nums:
            min_game = min(game_nums)
            count = len(game_nums)
            print(f'{name}: min={min_game}, count={count}')
        else:
            print(f'{name}: min=None, count=0')

    # Step 3: Download logs if requested
    if download_logs:
        print()
        download_logs_for_events(matching_events, all_game_numbers)

    # Step 4: Check logs if requested
    if check_logs:
        print()
        check_logs_for_events(matching_events, all_game_numbers)

    # Step 5: Download PGNs if requested
    if download_pgns:
        print()
        download_pgns_for_events(websocket, matching_events, all_game_numbers)

def run(event_pattern=None, download_logs=False, check_logs=False, download_pgns=False, debug=False):
    global DEBUG
    DEBUG = debug

    uri = 'wss://ccc-api.gcp-prod.chess.com/ws'

    with connect(uri, max_size=10 * 1024 * 1024) as websocket:
        if not event_pattern:
            print_all_messages(websocket)
        else:
            pattern = re.compile(event_pattern)
            process_events(websocket, pattern, download_logs, check_logs, download_pgns)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Utility to pull logs based on the CCC WebSocket')
    parser.add_argument('--event', help='Regex pattern to match event name(s)')
    parser.add_argument('--logs', action='store_true', default=False, help='Download logs for matching events')
    parser.add_argument('--check', action='store_true', default=False, help='Check logs for issues')
    parser.add_argument('--pgn', action='store_true', default=False, help='Download PGNs for matching events')
    parser.add_argument('--debug', action='store_true', default=False, help='Print all WebSocket requests')
    args = parser.parse_args()

    run(args.event, args.logs, args.check, args.pgn, args.debug)
