#[derive(Drop, Serde, Copy, PartialEq)]
pub enum CombatType {
    Magical,
    Hunter,
    Brute,
}

#[derive(Drop, Serde, Copy, PartialEq)]
pub enum WeaponCategory {
    Blade,
    Bludgeon,
    Magic,
}

#[derive(Drop, Serde, Copy, PartialEq)]
pub enum ArmorMaterial {
    Cloth,
    Hide,
    Metal,
}

#[derive(Drop, Serde, Copy, PartialEq)]
pub enum Tier {
    T1,
    T2,
    T3,
    T4,
    T5,
}

#[derive(Drop, Serde, Copy)]
pub struct Stats {
    pub strength: u8,
    pub dexterity: u8,
    pub vitality: u8,
    pub intelligence: u8,
    pub wisdom: u8,
    pub charisma: u8,
    pub luck: u8,
}

#[derive(Drop, Serde, Copy)]
pub struct EquippedItem {
    pub id: u16,
    pub tier: Tier,
    pub greatness: u8,
    pub combat_type: CombatType,
}

#[derive(Drop, Serde, Copy)]
pub struct Adventurer {
    pub health: u16,
    pub xp: u32,
    pub gold: u16,
    pub level: u8,
    pub stats: Stats,
    pub weapon: EquippedItem,
    pub stat_upgrades_available: u8,
    pub in_battle: bool,
}

#[derive(Drop, Serde, Copy)]
pub struct Beast {
    pub id: u16,
    pub level: u8,
    pub health: u16,
    pub combat_type: CombatType,
    pub tier: Tier,
}

#[derive(Drop, Serde, Copy, PartialEq)]
pub enum AgentAction {
    Explore,
    Attack,
    Flee,
    Upgrade,
    BuyItem,
    BuyPotion,
    Idle,
}

#[derive(Drop, Serde, Copy)]
pub struct CombatEstimate {
    pub adventurer_damage: u16,
    pub beast_damage: u16,
    pub hits_to_kill_beast: u8,
    pub hits_to_die: u8,
    pub favourable: bool,
}

pub fn tier_base_damage(tier: Tier) -> u16 {
    match tier {
        Tier::T1 => 42,
        Tier::T2 => 34,
        Tier::T3 => 28,
        Tier::T4 => 22,
        Tier::T5 => 16,
    }
}

#[cfg(test)]
mod tests {
    use super::{Tier, tier_base_damage};

    #[test]
    fn tier_damage_is_descending() {
        assert(tier_base_damage(Tier::T1) > tier_base_damage(Tier::T2), 't1>t2');
        assert(tier_base_damage(Tier::T2) > tier_base_damage(Tier::T3), 't2>t3');
        assert(tier_base_damage(Tier::T3) > tier_base_damage(Tier::T4), 't3>t4');
        assert(tier_base_damage(Tier::T4) > tier_base_damage(Tier::T5), 't4>t5');
    }
}
