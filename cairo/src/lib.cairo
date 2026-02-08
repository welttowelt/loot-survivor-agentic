//! Loot Survivor Cairo helpers for agent integration.
//! Focus: deterministic packing/unpacking of Adventurer core state.

use core::traits::DivRem;

#[derive(Drop, Serde, Copy)]
pub struct AdventurerCore {
    pub health: u16,
    pub xp: u16,
    pub gold: u16,
    pub beast_health: u16,
    pub stat_upgrades_available: u8,
    pub stats_packed: u32,
    pub equipment_packed: u128,
    pub item_specials_seed: u16,
    pub action_count: u16,
}

/// Bit layout mirrors LS2 death-mountain Adventurer pack() layout:
/// health(10) | xp(15) | gold(9) | beast_health(10) | stat_upgrades(4)
/// | stats_packed(30) | equipment_packed(128) | item_specials_seed(16) | action_count(16)
pub fn unpack_adventurer_core(value: felt252) -> AdventurerCore {
    let packed: u256 = value.into();

    let (packed, health) = DivRem::div_rem(packed, TWO_POW_10_NZ);
    let (packed, xp) = DivRem::div_rem(packed, TWO_POW_15_NZ);
    let (packed, gold) = DivRem::div_rem(packed, TWO_POW_9_NZ);
    let (packed, beast_health) = DivRem::div_rem(packed, TWO_POW_10_NZ);
    let (packed, stat_upgrades_available) = DivRem::div_rem(packed, TWO_POW_4_NZ);
    let (packed, stats_packed) = DivRem::div_rem(packed, TWO_POW_30_NZ);
    let (packed, equipment_packed) = DivRem::div_rem(packed, TWO_POW_128_NZ);
    let (packed, item_specials_seed) = DivRem::div_rem(packed, TWO_POW_16_NZ_U256);
    let (_, action_count) = DivRem::div_rem(packed, TWO_POW_16_NZ_U256);

    AdventurerCore {
        health: health.try_into().unwrap(),
        xp: xp.try_into().unwrap(),
        gold: gold.try_into().unwrap(),
        beast_health: beast_health.try_into().unwrap(),
        stat_upgrades_available: stat_upgrades_available.try_into().unwrap(),
        stats_packed: stats_packed.try_into().unwrap(),
        equipment_packed: equipment_packed.try_into().unwrap(),
        item_specials_seed: item_specials_seed.try_into().unwrap(),
        action_count: action_count.try_into().unwrap(),
    }
}

pub fn pack_adventurer_core(core: AdventurerCore) -> felt252 {
    let packed: u256 = core.health.into()
        + core.xp.into() * TWO_POW_10
        + core.gold.into() * TWO_POW_25
        + core.beast_health.into() * TWO_POW_34
        + core.stat_upgrades_available.into() * TWO_POW_44
        + core.stats_packed.into() * TWO_POW_48
        + core.equipment_packed.into() * TWO_POW_78
        + core.item_specials_seed.into() * TWO_POW_206
        + core.action_count.into() * TWO_POW_222;

    packed.try_into().unwrap()
}

const TWO_POW_4_NZ: NonZero<u256> = 0x10;
const TWO_POW_9_NZ: NonZero<u256> = 0x200;
const TWO_POW_10: u256 = 0x400;
const TWO_POW_10_NZ: NonZero<u256> = 0x400;
const TWO_POW_15_NZ: NonZero<u256> = 0x8000;
const TWO_POW_16_NZ_U256: NonZero<u256> = 0x10000;
const TWO_POW_25: u256 = 0x2000000;
const TWO_POW_30_NZ: NonZero<u256> = 0x40000000;
const TWO_POW_34: u256 = 0x400000000;
const TWO_POW_44: u256 = 0x100000000000;
const TWO_POW_48: u256 = 0x1000000000000;
const TWO_POW_78: u256 = 0x40000000000000000000;
const TWO_POW_206: u256 = 0x4000000000000000000000000000000000000000000000000000;
const TWO_POW_222: u256 = 0x40000000000000000000000000000000000000000000000000000000;
const TWO_POW_128_NZ: NonZero<u256> = 0x100000000000000000000000000000000;

#[cfg(test)]
mod tests {
    use super::{AdventurerCore, pack_adventurer_core, unpack_adventurer_core};

    #[test]
    fn roundtrip_pack_unpack() {
        let sample = AdventurerCore {
            health: 387,
            xp: 15642,
            gold: 501,
            beast_health: 423,
            stat_upgrades_available: 7,
            stats_packed: 0x1ABCDE,
            equipment_packed: 0x1234567890ABCDEF1234567890ABCDEF,
            item_specials_seed: 65530,
            action_count: 1024,
        };

        let packed = pack_adventurer_core(sample);
        let unpacked = unpack_adventurer_core(packed);

        assert(unpacked.health == sample.health, 'health mismatch');
        assert(unpacked.xp == sample.xp, 'xp mismatch');
        assert(unpacked.gold == sample.gold, 'gold mismatch');
        assert(unpacked.beast_health == sample.beast_health, 'beast mismatch');
        assert(unpacked.stat_upgrades_available == sample.stat_upgrades_available, 'upgrades mismatch');
        assert(unpacked.stats_packed == sample.stats_packed, 'stats mismatch');
        assert(unpacked.equipment_packed == sample.equipment_packed, 'equip mismatch');
        assert(unpacked.item_specials_seed == sample.item_specials_seed, 'seed mismatch');
        assert(unpacked.action_count == sample.action_count, 'actions mismatch');
    }

    #[test]
    fn unpack_zero_is_zeroed() {
        let unpacked = unpack_adventurer_core(0);
        assert(unpacked.health == 0, 'health');
        assert(unpacked.xp == 0, 'xp');
        assert(unpacked.gold == 0, 'gold');
        assert(unpacked.beast_health == 0, 'beast_health');
        assert(unpacked.stat_upgrades_available == 0, 'upgrades');
        assert(unpacked.stats_packed == 0, 'stats_packed');
        assert(unpacked.equipment_packed == 0, 'equipment_packed');
        assert(unpacked.item_specials_seed == 0, 'item_specials_seed');
        assert(unpacked.action_count == 0, 'action_count');
    }
}
