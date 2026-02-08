#!/usr/bin/env python3
import json
from pathlib import Path

MANIFEST = Path('/tmp/death-mountain/contracts/manifest_mainnet.json')
OUT = Path('research/ls2-function-signatures.md')

TARGET_CONTRACTS = {
    'ls_0_0_9-game_systems': {
        'start_game', 'explore', 'attack', 'flee', 'select_stat_upgrades', 'buy_items', 'equip', 'drop', 'get_game_state'
    },
    'ls_0_0_9-adventurer_systems': {
        'get_adventurer', 'get_adventurer_verbose', 'get_adventurer_packed', 'get_adventurer_health', 'get_adventurer_level', 'get_bag', 'get_bag_packed', 'unpack_adventurer'
    },
}


def fmt_params(params):
    if not params:
        return 'none'
    return ', '.join(f"{p.get('name')}: {p.get('type')}" for p in params)


def fmt_outputs(outputs):
    if not outputs:
        return 'none'
    return ', '.join(o.get('type') for o in outputs)


def main():
    data = json.loads(MANIFEST.read_text())
    rows = []

    for contract in data.get('contracts', []):
        tag = contract.get('tag')
        wanted = TARGET_CONTRACTS.get(tag)
        if not wanted:
            continue

        for abi_item in contract.get('abi', []):
            if abi_item.get('type') != 'interface':
                continue
            for item in abi_item.get('items', []):
                if item.get('type') != 'function':
                    continue
                name = item.get('name')
                if name not in wanted:
                    continue
                rows.append({
                    'contract': tag,
                    'name': name,
                    'mutability': item.get('state_mutability', 'external'),
                    'inputs': fmt_params(item.get('inputs', [])),
                    'outputs': fmt_outputs(item.get('outputs', [])),
                })

    rows.sort(key=lambda r: (r['contract'], r['name']))

    lines = [
        '# LS2 Function Signature Table (Mainnet Manifest)',
        '',
        'Source: `/tmp/death-mountain/contracts/manifest_mainnet.json`',
        '',
        '| Contract | Function | Mutability | Inputs | Outputs |',
        '|---|---|---|---|---|',
    ]

    for r in rows:
        lines.append(f"| `{r['contract']}` | `{r['name']}` | `{r['mutability']}` | `{r['inputs']}` | `{r['outputs']}` |")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text('\n'.join(lines) + '\n')
    print(f'wrote {OUT}')


if __name__ == '__main__':
    main()
