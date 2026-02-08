# LS2 Function Signature Table (Mainnet Manifest)

Source: `/tmp/death-mountain/contracts/manifest_mainnet.json`

| Contract | Function | Mutability | Inputs | Outputs |
|---|---|---|---|---|
| `ls_0_0_9-adventurer_systems` | `get_adventurer` | `view` | `adventurer_id: core::integer::u64` | `death_mountain::models::adventurer::adventurer::Adventurer` |
| `ls_0_0_9-adventurer_systems` | `get_adventurer_health` | `view` | `adventurer_id: core::integer::u64` | `core::integer::u16` |
| `ls_0_0_9-adventurer_systems` | `get_adventurer_level` | `view` | `adventurer_id: core::integer::u64` | `core::integer::u8` |
| `ls_0_0_9-adventurer_systems` | `get_adventurer_packed` | `view` | `adventurer_id: core::integer::u64` | `core::felt252` |
| `ls_0_0_9-adventurer_systems` | `get_adventurer_verbose` | `view` | `adventurer_id: core::integer::u64` | `death_mountain::models::adventurer::adventurer::AdventurerVerbose` |
| `ls_0_0_9-adventurer_systems` | `get_bag` | `view` | `adventurer_id: core::integer::u64` | `death_mountain::models::adventurer::bag::Bag` |
| `ls_0_0_9-adventurer_systems` | `get_bag_packed` | `view` | `adventurer_id: core::integer::u64` | `core::felt252` |
| `ls_0_0_9-adventurer_systems` | `unpack_adventurer` | `view` | `packed_adventurer: core::felt252` | `death_mountain::models::adventurer::adventurer::Adventurer` |
| `ls_0_0_9-game_systems` | `attack` | `external` | `adventurer_id: core::integer::u64, to_the_death: core::bool` | `none` |
| `ls_0_0_9-game_systems` | `buy_items` | `external` | `adventurer_id: core::integer::u64, potions: core::integer::u8, items: core::array::Array::<death_mountain::models::market::ItemPurchase>` | `none` |
| `ls_0_0_9-game_systems` | `drop` | `external` | `adventurer_id: core::integer::u64, items: core::array::Array::<core::integer::u8>` | `none` |
| `ls_0_0_9-game_systems` | `equip` | `external` | `adventurer_id: core::integer::u64, items: core::array::Array::<core::integer::u8>` | `none` |
| `ls_0_0_9-game_systems` | `explore` | `external` | `adventurer_id: core::integer::u64, till_beast: core::bool` | `none` |
| `ls_0_0_9-game_systems` | `flee` | `external` | `adventurer_id: core::integer::u64, to_the_death: core::bool` | `none` |
| `ls_0_0_9-game_systems` | `get_game_state` | `view` | `adventurer_id: core::integer::u64` | `death_mountain::models::game::GameState` |
| `ls_0_0_9-game_systems` | `select_stat_upgrades` | `external` | `adventurer_id: core::integer::u64, stat_upgrades: death_mountain::models::adventurer::stats::Stats` | `none` |
| `ls_0_0_9-game_systems` | `start_game` | `external` | `adventurer_id: core::integer::u64, weapon: core::integer::u8` | `none` |
