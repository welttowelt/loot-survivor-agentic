# LS2 ABI + Entrypoint Map (Issue #1)

Date: 2026-02-08
Source repo: `Provable-Games/death-mountain`
Source path: `contracts/manifest_mainnet.json`, `contracts/manifest_sepolia.json`

## Verified contract addresses

### Mainnet

- world: `0x2ef591697f0fd9adc0ba9dbe0ca04dabad80cf95f08ba02e435d9cb6698a28a`
- adventurer_systems: `0x3fc7ecd6d577daa1ee855a9fa13a914d01acda06715c9fc74f1ee1a5e346a01`
- beast_systems: `0x74abc15c0ddef39bdf1ede2a643c07968d3ed5bacb0123db2d5b7154fbb35c7`
- game_systems: `0x6f7c4350d6d5ee926b3ac4fa0c9c351055456e75c92227468d84232fc493a9c`
- game_token_systems: `0x5e2dfbdc3c193de629e5beb116083b06bd944c1608c9c793351d5792ba29863`
- loot_systems: `0x4c386505ce1cc0be91e7ae8727c9feec66692a92c851b01e7f764ea0143dbe4`
- objectives_systems: `0x403224d3586a402bf3d9a7553493ba0d931e306e6aae8472503afdf90083e32`
- renderer_systems: `0x6135cd4ee82eb5e7652a636a952c893315914f0655a3cc834ce8b6b1e5ff1cb`
- settings_systems: `0x3caf941b916a83550d8f6325802e0cb686c9a0c8b30a23fb9df531ae24d12d0`

### Sepolia

- world: `0x785401cf74071ec444e37dbbd87281aba48afc86570b1a1537193d1ce39086f`
- adventurer_systems: `0x1c7c0588bf58151c7054ef0f712a4ed407aded804e1359dacd4404c6517b1fa`
- beast_systems: `0x1a200cfdc9a6dfc8580678021d67f705986052074219cfadce922ee02c51062`
- game_systems: `0x38197b89d5c2e676d06aa93cf97b5be9ee4bf2b13ba972de4997f931f3559ee`
- game_token_systems: `0x49fe8fc7f0215673f7478b6160f747700d2d2c7cc5821397f9a24bb2fdd5dd2`
- loot_systems: `0x36b143a2609f660c88e1bc7bc2d598c7e6f85374416142e7ee14e41f380bf8`
- objectives_systems: `0x5cba8beaadb745bdf6d166e3a1a897e535228dbd839051750278719444bca28`
- renderer_systems: `0x4eaae90111bf72a05970979a0bf36fe29be367aed83f55d181e04d638f64fdf`
- settings_systems: `0x1b640888c06d7e245c82ccdac2c4d7878a7f9fd8e8eb7df55773f60ed8de981`

## Player-facing write entrypoints (external)

From `ls_0_0_9-game_systems`:
- `start_game`
- `explore`
- `attack`
- `flee`
- `select_stat_upgrades`
- `buy_items`
- `equip`
- `drop`

Other related writes:
- `ls_0_0_9-game_token_systems.player_name`

## High-value read entrypoints (view)

From `ls_0_0_9-adventurer_systems`:
- `get_adventurer`
- `get_adventurer_verbose`
- `get_adventurer_packed`
- `get_adventurer_health`
- `get_adventurer_level`
- `get_adventurer_entropy`
- `get_bag`
- `get_bag_packed`
- `unpack_adventurer`
- `unpack_bag`
- `get_market`

From `ls_0_0_9-game_systems`:
- `get_game_state`

From `ls_0_0_9-beast_systems`:
- `get_beast`
- `get_entity_stats`
- `get_collectable_count`

## MCP mapping draft (first pass)

- `ls_new_game` -> `game_systems.start_game`
- `ls_explore` -> `game_systems.explore`
- `ls_attack` -> `game_systems.attack`
- `ls_flee` -> `game_systems.flee`
- `ls_upgrade` -> `game_systems.select_stat_upgrades`
- `ls_buy_item` -> `game_systems.buy_items`
- `ls_get_adventurer` -> `adventurer_systems.get_adventurer` (+ optional `get_adventurer_verbose`)
- `ls_get_game_state` -> `game_systems.get_game_state`

## Required env/config (initial)

- `LS_CHAIN` (`mainnet` | `sepolia`)
- `LS_WORLD_ADDRESS`
- `LS_GAME_SYSTEMS_ADDRESS`
- `LS_ADVENTURER_SYSTEMS_ADDRESS`
- `LS_TORII_URL` (for leaderboard/indexed views)
- Standard Starknet RPC + account signing env vars for writes

## Assumptions to validate next

- Exact argument shapes for `select_stat_upgrades`, `buy_items`, `equip`, `drop`
- Best read source for leaderboard in LS2 (Torii model query vs custom API)
- Canonical Adventurer/BAG decode path for tool responses (packed vs verbose)

## Next step

- Generate a strict function signature table (name, inputs, outputs) for all mapped MCP calls.
