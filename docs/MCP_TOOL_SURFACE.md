# MCP Tool Surface Draft (Issue #2)

Date: 2026-02-09

## Source basis

- [VERIFIED] `research/ls2-function-signatures.md` generated from `/tmp/death-mountain/contracts/manifest_mainnet.json`
- [VERIFIED] `/tmp/death-mountain/contracts/dojo_sepolia.toml`
- [VERIFIED] `/tmp/death-mountain/contracts/torii-sepolia.toml` (Torii indexing config example)
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

### Dojo world + RPC

[VERIFIED] from `dojo_sepolia.toml`:

- `rpc_url = https://api.cartridge.gg/x/starknet/sepolia/rpc/v0_8`
- `world_address = 0x785401cf74071ec444e37dbbd87281aba48afc86570b1a1537193d1ce39086f`
- `namespace.default = ls_0_0_9`

[VERIFIED] from `dojo_mainnet.toml`:

- `rpc_url = https://api.cartridge.gg/x/starknet/mainnet/rpc/v0_8`
- `world_address = 0x02ef591697f0fd9adc0ba9dbe0ca04dabad80cf95f08ba02e435d9cb6698a28a`
- `namespace.default = ls_0_0_9`

### Torii (indexer) config hints

[VERIFIED] from `torii-sepolia.toml` in the same source repo:

- `rpc = https://api.cartridge.gg/x/starknet/sepolia`
- `events.raw = true`
- `sql.historical = ["ls_0_0_6-GameEvent"]`
- `indexing.pending = true`

[VERIFIED] mismatch note:

- `torii-sepolia.toml` uses `world_address = 0x29f11c…5753` and `ls_0_0_6` namespace history, which does not match the `ls_0_0_9` `world_address` in `dojo_sepolia.toml`. Treat this file as an example of the Torii shape, not the canonical LS2 Sepolia world.

[INFERRED] runtime env contract:

- `LS_CHAIN` (`mainnet|sepolia`)
- `STARKNET_RPC_URL`
- `LS_WORLD_ADDRESS`
- `LS_GAME_SYSTEMS_ADDRESS`
- `LS_ADVENTURER_SYSTEMS_ADDRESS`
- `LS_TORII_URL` (preferred) or `{LS_TORII_RPC_BASE, LS_TORII_WORLD_ADDRESS}` depending on client implementation
- signer/account fields for writes

[INFERRED] sane defaults by chain (from verified dojo configs above):

- `LS_CHAIN=sepolia` -> use Sepolia rpc/world pair.
- `LS_CHAIN=mainnet` -> use Mainnet rpc/world pair.
- Fail fast if provided `LS_WORLD_ADDRESS` does not match selected chain default and no explicit override flag is set.

## Open blocker

- [VERIFIED] No explicit leaderboard read function in currently mapped manifest entrypoints.
- [INFERRED] `ls_get_leaderboard` should query indexed data (Torii or equivalent), not direct game_systems ABI.
