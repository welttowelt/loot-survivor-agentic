# loot-survivor-agentic

Agent tooling and research track for Loot Survivor on Starknet.

## Scope

- Build a practical MCP integration plan for Loot Survivor actions
- Ship a first implementation track in small, reviewable PRs
- Keep assumptions explicit and validate against contract ABIs

## Initial Deliverables

1. Research dossier with verified vs inferred facts
2. Tool surface draft for `starknet-loot-survivor` MCP integration
3. Week-by-week execution plan with acceptance criteria

## Next

- ABI extraction from `Provable-Games/death-mountain`
- Entrypoint map for player actions and read methods
- MCP tool schema draft and error taxonomy: `docs/MCP_TOOL_SURFACE.md`
- felt252 adventurer-state unpacking notes

## Research tooling

- Generate function signature tables from LS2 manifest:
  - `python3 scripts/extract_ls2_signatures.py`
- Current generated output:
  - `research/ls2-function-signatures.md`

## Cairo helpers

- Package: `cairo/`
- First artifact: deterministic Adventurer core codec (pack/unpack)
- Run tests:
  - `cd cairo && scarb test`
- Notes:
  - `docs/CAIRO-FIRST-ARTIFACT.md`
