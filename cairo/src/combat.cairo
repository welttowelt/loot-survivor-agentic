use loot_survivor_agentic::constants::{
    EFFECTIVENESS_FAIR_X10, EFFECTIVENESS_STRONG_X10, EFFECTIVENESS_WEAK_X10,
    STRENGTH_DAMAGE_BONUS_PCT,
};
use loot_survivor_agentic::types::{
    Adventurer, Beast, CombatEstimate, CombatType, EquippedItem, tier_base_damage,
};

pub fn effectiveness(attacker: CombatType, defender: CombatType) -> u8 {
    if attacker == defender {
        return EFFECTIVENESS_FAIR_X10;
    }

    if (attacker == CombatType::Magical && defender == CombatType::Brute)
        || (attacker == CombatType::Brute && defender == CombatType::Hunter)
        || (attacker == CombatType::Hunter && defender == CombatType::Magical) {
        EFFECTIVENESS_STRONG_X10
    } else {
        EFFECTIVENESS_WEAK_X10
    }
}

pub fn has_type_advantage(weapon: EquippedItem, beast: Beast) -> bool {
    effectiveness(weapon.combat_type, beast.combat_type) == EFFECTIVENESS_STRONG_X10
}

pub fn estimate_adventurer_damage(weapon: EquippedItem, strength: u8, beast: Beast) -> u16 {
    let base = tier_base_damage(weapon.tier);
    let str_bonus = (base * strength.into()) / STRENGTH_DAMAGE_BONUS_PCT;
    let pre_mult = base + weapon.greatness.into() + str_bonus;
    let mult = effectiveness(weapon.combat_type, beast.combat_type);
    let mut out = (pre_mult * mult.into()) / 10;

    if out == 0 {
        out = 1;
    }

    out
}

pub fn estimate_beast_damage(beast: Beast) -> u16 {
    let base = tier_base_damage(beast.tier);
    let level_scale = 100 + beast.level.into() * 10;
    let mut out = (base * level_scale) / 100;

    if out == 0 {
        out = 1;
    }

    out
}

pub fn ceil_div_u16(x: u16, d: u16) -> u8 {
    if d == 0 {
        return 255;
    }
    (((x + d - 1) / d).try_into().unwrap())
}

pub fn evaluate_combat(adventurer: Adventurer, beast: Beast) -> CombatEstimate {
    let adv_dmg = estimate_adventurer_damage(adventurer.weapon, adventurer.stats.strength, beast);
    let bst_dmg = estimate_beast_damage(beast);

    let hits_to_kill = ceil_div_u16(beast.health, adv_dmg);
    let hits_to_die = ceil_div_u16(adventurer.health, bst_dmg);

    CombatEstimate {
        adventurer_damage: adv_dmg,
        beast_damage: bst_dmg,
        hits_to_kill_beast: hits_to_kill,
        hits_to_die,
        favourable: hits_to_kill <= hits_to_die,
    }
}

#[cfg(test)]
mod tests {
    use super::{
        ceil_div_u16, effectiveness, estimate_adventurer_damage, estimate_beast_damage, evaluate_combat,
        has_type_advantage,
    };
    use loot_survivor_agentic::types::{
        Adventurer, Beast, CombatType, EquippedItem, Stats, Tier,
    };

    fn sample_stats(strength: u8, dexterity: u8) -> Stats {
        Stats {
            strength,
            dexterity,
            vitality: 1,
            intelligence: 1,
            wisdom: 1,
            charisma: 1,
            luck: 1,
        }
    }

    fn sample_weapon(combat_type: CombatType, tier: Tier, greatness: u8) -> EquippedItem {
        EquippedItem { id: 1, tier, greatness, combat_type }
    }

    fn sample_adv(combat_type: CombatType) -> Adventurer {
        Adventurer {
            health: 100,
            xp: 0,
            gold: 100,
            level: 1,
            stats: sample_stats(5, 5),
            weapon: sample_weapon(combat_type, Tier::T1, 0),
            stat_upgrades_available: 0,
            in_battle: true,
        }
    }

    fn sample_beast(combat_type: CombatType, tier: Tier, level: u8, health: u16) -> Beast {
        Beast { id: 1, level, health, combat_type, tier }
    }

    #[test]
    fn test_triangle_magical_beats_brute() {
        assert(effectiveness(CombatType::Magical, CombatType::Brute) == 15, 'magical>brute');
    }

    #[test]
    fn test_triangle_brute_beats_hunter() {
        assert(effectiveness(CombatType::Brute, CombatType::Hunter) == 15, 'brute>hunter');
    }

    #[test]
    fn test_triangle_hunter_beats_magical() {
        assert(effectiveness(CombatType::Hunter, CombatType::Magical) == 15, 'hunter>magical');
    }

    #[test]
    fn test_triangle_same_type_is_fair() {
        assert(effectiveness(CombatType::Magical, CombatType::Magical) == 10, 'mirror');
    }

    #[test]
    fn test_triangle_weak_matchups() {
        assert(effectiveness(CombatType::Magical, CombatType::Hunter) == 5, 'magical<hunter');
        assert(effectiveness(CombatType::Brute, CombatType::Magical) == 5, 'brute<magical');
        assert(effectiveness(CombatType::Hunter, CombatType::Brute) == 5, 'hunter<brute');
    }

    #[test]
    fn test_has_type_advantage() {
        let w = sample_weapon(CombatType::Magical, Tier::T1, 0);
        let b = sample_beast(CombatType::Brute, Tier::T1, 1, 100);
        assert(has_type_advantage(w, b), 'advantage');
    }

    #[test]
    fn test_adventurer_damage_strong_matchup() {
        let w = sample_weapon(CombatType::Magical, Tier::T1, 0);
        let b = sample_beast(CombatType::Brute, Tier::T1, 1, 100);
        assert(estimate_adventurer_damage(w, 5, b) == 94, 'expected damage');
    }

    #[test]
    fn test_adventurer_damage_weak_matchup() {
        let w = sample_weapon(CombatType::Magical, Tier::T1, 0);
        let b = sample_beast(CombatType::Hunter, Tier::T1, 1, 100);
        assert(estimate_adventurer_damage(w, 5, b) == 31, 'expected weak damage');
    }

    #[test]
    fn test_adventurer_damage_floor_at_one() {
        let w = sample_weapon(CombatType::Magical, Tier::T5, 0);
        let b = sample_beast(CombatType::Hunter, Tier::T1, 1, 100);
        let d = estimate_adventurer_damage(w, 0, b);
        assert(d >= 1, 'floor');
    }

    #[test]
    fn test_beast_damage_scales_with_level() {
        let low = sample_beast(CombatType::Brute, Tier::T1, 1, 100);
        let high = sample_beast(CombatType::Brute, Tier::T1, 10, 100);
        assert(estimate_beast_damage(high) > estimate_beast_damage(low), 'scale');
    }

    #[test]
    fn test_evaluate_combat_favourable() {
        let adv = sample_adv(CombatType::Magical);
        let beast = sample_beast(CombatType::Brute, Tier::T5, 1, 80);
        let e = evaluate_combat(adv, beast);
        assert(e.favourable, 'favourable');
    }

    #[test]
    fn test_evaluate_combat_unfavourable() {
        let adv = sample_adv(CombatType::Magical);
        let beast = sample_beast(CombatType::Hunter, Tier::T1, 10, 300);
        let e = evaluate_combat(adv, beast);
        assert(!e.favourable, 'unfavourable');
    }

    #[test]
    fn test_ceil_div() {
        assert(ceil_div_u16(10, 5) == 2, 'exact');
        assert(ceil_div_u16(11, 5) == 3, 'remainder');
        assert(ceil_div_u16(11, 0) == 255, 'zero divisor');
    }
}
