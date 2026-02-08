use core::option::Option;

use loot_survivor_agentic::combat::{evaluate_combat, has_type_advantage};
use loot_survivor_agentic::constants::{CRITICAL_HP_PCT, LOW_HP_PCT, MAX_HEALTH};
use loot_survivor_agentic::types::{Adventurer, AgentAction, Beast, Stats};

// Upgrade index constants for tool interop.
pub const UPGRADE_STRENGTH: u8 = 0;
pub const UPGRADE_DEXTERITY: u8 = 1;
pub const UPGRADE_VITALITY: u8 = 2;
pub const UPGRADE_INTELLIGENCE: u8 = 3;
pub const UPGRADE_WISDOM: u8 = 4;
pub const UPGRADE_CHARISMA: u8 = 5;

fn hp_pct(health: u16) -> u16 {
    let pct_u32: u32 = (health.into() * 100_u32) / MAX_HEALTH.into();
    pct_u32.try_into().unwrap()
}

pub fn recommend_stat_upgrade(stats: Stats, level: u8, health: u16) -> u8 {
    if stats.charisma < 3 {
        return UPGRADE_CHARISMA;
    }
    if stats.dexterity < level {
        return UPGRADE_DEXTERITY;
    }
    if stats.intelligence < 4 {
        return UPGRADE_INTELLIGENCE;
    }
    if stats.wisdom < 4 {
        return UPGRADE_WISDOM;
    }
    if hp_pct(health) <= LOW_HP_PCT {
        return UPGRADE_VITALITY;
    }
    UPGRADE_STRENGTH
}

pub fn recommend_battle_action(adventurer: Adventurer, beast: Beast) -> AgentAction {
    if hp_pct(adventurer.health) <= CRITICAL_HP_PCT {
        return AgentAction::Flee;
    }

    let estimate = evaluate_combat(adventurer, beast);
    if estimate.favourable {
        return AgentAction::Attack;
    }

    if has_type_advantage(adventurer.weapon, beast) {
        return AgentAction::Attack;
    }

    if adventurer.stats.dexterity >= adventurer.level {
        AgentAction::Flee
    } else {
        AgentAction::Attack
    }
}

pub fn recommend_action(adventurer: Adventurer, beast_option: Option<Beast>) -> AgentAction {
    match beast_option {
        Option::Some(beast) => recommend_battle_action(adventurer, beast),
        Option::None => {
            if adventurer.stat_upgrades_available > 0 {
                return AgentAction::Upgrade;
            }
            if hp_pct(adventurer.health) <= LOW_HP_PCT && adventurer.gold > 0 {
                return AgentAction::BuyPotion;
            }
            AgentAction::Explore
        },
    }
}

#[cfg(test)]
mod tests {
    use core::option::Option;

    use super::{
        UPGRADE_CHARISMA, UPGRADE_DEXTERITY, UPGRADE_INTELLIGENCE, UPGRADE_STRENGTH,
        recommend_action, recommend_battle_action, recommend_stat_upgrade,
    };
    use loot_survivor_agentic::types::{
        Adventurer, AgentAction, Beast, CombatType, EquippedItem, Stats, Tier,
    };

    fn stats() -> Stats {
        Stats {
            strength: 5,
            dexterity: 5,
            vitality: 2,
            intelligence: 2,
            wisdom: 2,
            charisma: 0,
            luck: 1,
        }
    }

    fn adv() -> Adventurer {
        Adventurer {
            health: 500,
            xp: 0,
            gold: 100,
            level: 5,
            stats: stats(),
            weapon: EquippedItem { id: 1, tier: Tier::T1, greatness: 0, combat_type: CombatType::Magical },
            stat_upgrades_available: 0,
            in_battle: false,
        }
    }

    fn beast(combat_type: CombatType, health: u16, tier: Tier, level: u8) -> Beast {
        Beast { id: 1, level, health, combat_type, tier }
    }

    #[test]
    fn test_upgrade_cha_first() {
        let s = stats();
        assert(recommend_stat_upgrade(s, 5, 500) == UPGRADE_CHARISMA, 'cha first');
    }

    #[test]
    fn test_upgrade_dex_when_below_level() {
        let mut s = stats();
        s.charisma = 3;
        s.dexterity = 2;
        assert(recommend_stat_upgrade(s, 5, 500) == UPGRADE_DEXTERITY, 'dex');
    }

    #[test]
    fn test_upgrade_int_when_low() {
        let mut s = stats();
        s.charisma = 3;
        s.dexterity = 5;
        s.intelligence = 2;
        assert(recommend_stat_upgrade(s, 5, 500) == UPGRADE_INTELLIGENCE, 'int');
    }

    #[test]
    fn test_upgrade_defaults_to_str() {
        let mut s = stats();
        s.charisma = 3;
        s.dexterity = 6;
        s.intelligence = 5;
        s.wisdom = 5;
        assert(recommend_stat_upgrade(s, 5, 800) == UPGRADE_STRENGTH, 'str');
    }

    #[test]
    fn test_attack_when_favourable() {
        let a = adv();
        let b = beast(CombatType::Brute, 70, Tier::T5, 1);
        assert(recommend_battle_action(a, b) == AgentAction::Attack, 'attack fav');
    }

    #[test]
    fn test_flee_when_critical_hp() {
        let mut a = adv();
        a.health = 20;
        let b = beast(CombatType::Brute, 70, Tier::T5, 1);
        assert(recommend_battle_action(a, b) == AgentAction::Flee, 'flee crit');
    }

    #[test]
    fn test_flee_when_unfavourable_and_high_dex() {
        let mut a = adv();
        a.health = 300;
        a.stats.dexterity = 10;
        let b = beast(CombatType::Hunter, 400, Tier::T1, 10);
        assert(recommend_battle_action(a, b) == AgentAction::Flee, 'flee dex');
    }

    #[test]
    fn test_upgrade_before_explore() {
        let mut a = adv();
        a.stat_upgrades_available = 1;
        assert(recommend_action(a, Option::None) == AgentAction::Upgrade, 'upgrade');
    }

    #[test]
    fn test_buy_potion_when_low_hp() {
        let mut a = adv();
        a.health = 100;
        a.gold = 10;
        assert(recommend_action(a, Option::None) == AgentAction::BuyPotion, 'buy potion');
    }

    #[test]
    fn test_explore_when_healthy() {
        let a = adv();
        assert(recommend_action(a, Option::None) == AgentAction::Explore, 'explore');
    }

    #[test]
    fn test_combat_delegates_when_beast_present() {
        let a = adv();
        let b = beast(CombatType::Brute, 70, Tier::T5, 1);
        assert(recommend_action(a, Option::Some(b)) == AgentAction::Attack, 'delegate');
    }
}
