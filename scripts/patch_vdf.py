#!/usr/bin/python3

import argparse
import os
import sys
from collections import deque

def nested_dicts_to_vdf(data):
    pass

def vdf_to_nested_dicts(vdf_file_path):
    with open(vdf_file_path, 'r') as fr:
        all_lines = fr.readlines()

    data = dict()
    dict_stack = deque()
    dict_stack.append(data)

    for line in all_lines:
        line_tokens = line.split()
        if len(line_tokens) == 1:
            token = line_tokens[0]
            if token not in ['{', '}']:
                # New nesting level and key
                new_data = dict()
                dict_stack[-1][token] = new_data
                dict_stack.append(new_data)
            elif token == '}':
                # Closing up this nesting level
                dict_stack.pop()
        elif len(line_tokens) == 2:        
            # Key-value pair in the current nesting level
            key, value = line_tokens
            dict_stack[-1][key] = value

    return data
        
def main(args):
    if not os.path.exists(args.vdf_file):
        print(f'Could not find VDF file: {args.vdf_file}', file=sys.stderr)
        exit(1)

    data = vdf_to_nested_dicts(args.vdf_file)
    print(data)

    exit(0) # for now !

    data_iter = data
    for data_path_token in args.data_path.split('.'):
        if data_path_token not in data_iter:
            print(f'Invalid data path: {args.data_path}', file=sys.stderr)
            exit(1)

        data_iter = data_iter[data_path_token]

    data_iter = args.data_value
    vdf_text = nested_dicts_to_vdf(data)
    
    # TODO: Write the vdf to disk
    print(vdf_text)

if __name__=="__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('vdf-file', help="Target VDF file to modify")
    parser.add_argument('data-path', help="VDF data path to modify")
    parser.add_argument('data-value', help="Data value to set")

    main(parser.parse_args())
