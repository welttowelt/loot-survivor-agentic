# MCP Tool Surface Draft (Issue #2)

Date: 2026-02-09

## Source basis

- [VERIFIED] `research/ls2-function-signatures.md` generated from `/tmp/death-mountain/contracts/manifest_mainnet.json`
- [VERIFIED] `/tmp/death-mountain/contracts/dojo_sepolia.toml`
- [INFERRED] Tool response envelope shape and error taxonomy below (to stabilize client UX)

## Tool schema table (8 tools)

| Tool | Contract function(s) | Mutability | Request (minimum) | Response (proposed) |
|---|---|---|---|---|
| `ls_new_game` | `game_systems.start_game` | write | `adventurer_id: u64`, `weapon: u8` | `{ ok: true, tx_hash }` |
| `ls_explore` | `game_systems.explore` | write | `adventurer_id: u64`, `till_beast: bool=false` | `{ ok: true, tx_hash }` |
| `ls_attack` | `game_systems.attack` | write | `adventurer_id: u64`, `to_the_death: bool=false` | `{ ok: true, tx_hash }` |
| `ls_flee` | `game_systems.flee` | write | `adventurer_id: u64`, `to_the_death: bool=false` | `{ ok: true, tx_hash }` |
| `ls_upgrade` | `game_systems.select_stat_upgrades` | write | `adventurer_id: u64`, `stat_upgrades: Stats` | `{ ok: true, tx_hash }` |
| `ls_buy_item` | `game_systems.buy_items` | write | `adventurer_id: u64`, `potions: u8`, `items: ItemPurchase[]` | `{ ok: true, tx_hash }` |
| `ls_get_adventurer` | `adventurer_systems.get_adventurer` (+ optional `get_adventurer_verbose`, `get_bag`) | read | `adventurer_id: u64`, `verbose?: bool` | `{ ok: true, adventurer, bag? }` |
| `ls_get_leaderboard` | no direct manifest function yet | read | `limit?: number`, `cursor?: string` | `{ ok: true, rows, cursor? }` |

## Input validation rules

### Shared

- `adventurer_id` must be integer `>= 0` and `< 2^64`.
- Reject unknown keys when `strict=true` mode is enabled.

### Write calls

- Require signer/account in runtime config.
- `weapon` and `potions` must be integer `u8` (`0..255`).
- `items` must be array of typed `ItemPurchase` objects.
- `stat_upgrades` must match `death_mountain::models::adventurer::stats::Stats` shape.

### Read calls

- Reads do not require signer.
- `verbose` defaults to `false` to reduce payload size.
- `limit` defaults to `50`, hard cap `200`.

## Error taxonomy and tx confirmation

[INFERRED] Standardized errors:

- `VALIDATION_ERROR`: bad input types/ranges.
- `RPC_ERROR`: node/provider failure.
- `CONTRACT_REVERT`: tx accepted but execution reverted.
- `TX_TIMEOUT`: receipt not finalized within configured wait window.
- `NOT_FOUND`: no adventurer/leaderboard page for request.

[INFERRED] Write confirmation behavior:

- `confirm="accepted"`: return on ACCEPTED_ON_L2.
- `confirm="finalized"`: wait for stronger finality where available.
- `timeout_ms` default: `120000`.

## Chain-aware config notes

[VERIFIED] from `dojo_sepolia.toml`:

- `rpc_url = https://api.cartridge.gg/x/starknet/sepolia/rpc/v0_8`
- `world_address = 0x785401cf74071ec444e37dbbd87281aba48afc86570b1a1537193d1ce39086f`
- `namespace.default = ls_0_0_9`

[INFERRED] runtime env contract:

- `LS_CHAIN` (`mainnet|sepolia`)
- `STARKNET_RPC_URL`
- `LS_WORLD_ADDRESS`
- `LS_GAME_SYSTEMS_ADDRESS`
- `LS_ADVENTURER_SYSTEMS_ADDRESS`
- signer/account fields for writes

## Open blocker

- [VERIFIED] No explicit leaderboard read function in currently mapped manifest entrypoints.
- [INFERRED] `ls_get_leaderboard` should query indexed data (Torii or equivalent), not direct game_systems ABI.
