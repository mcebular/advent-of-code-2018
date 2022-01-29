import haxe.Exception;

using Lambda;
using StringTools;


class Day24 {

    static public function main() {
        var inputContent: String = sys.io.File.getContent("input/24");

        var team1 = new Array<UnitGroup>();
        var team2 = new Array<UnitGroup>();
        
        var currentTeam = new Array<UnitGroup>();
        for (line in inputContent.split("\n")) {
            if (line.startsWith("Imm")) {
                currentTeam = team1;
                continue;
            }
            if (line.startsWith("Inf")) {
                currentTeam = team2;
                continue;
            }
            if (line.trim().length == 0) {
                continue;
            }

            currentTeam.push(UnitGroup.parse(line.trim()));
        }

        // part 1
        trace(combat(team1, team2, 0));

        // part 2
        var boost = 0;
        while (true) {
            final combatResult = combat(team1, team2, boost);
            if (combatResult.startsWith("Team 1")) {
                trace('With boost of $boost', combatResult);
                break;
            }

            boost++;
        }
    }

    private static function targeting(attacking: Array<UnitGroup>, defending: Array<UnitGroup>): Map<UnitGroup, UnitGroup> {
        var result = new Map<UnitGroup, UnitGroup>();

        attacking = attacking.copy();
        attacking.sort((u1, u2) -> {
            final powerDiff = u2.getEffectivePower() - u1.getEffectivePower();
            if (powerDiff != 0) return powerDiff;

            return u2.initiative - u1.initiative;
        });
        defending = defending.copy();

        while (attacking.length > 0 && defending.length > 0) {
            var att = attacking.shift();
            // find a target among defending units.
            defending.sort((u1, u2) -> {
                final damageDiff = att.damageTo(u2) - att.damageTo(u1);
                if (damageDiff != 0) return damageDiff;
                
                final powerDiff = u2.getEffectivePower() - u1.getEffectivePower();
                if (powerDiff != 0) return powerDiff;
                
                return u2.initiative - u1.initiative;
            });
            
            if (att.damageTo(defending[0]) == 0) {
                // Best damage this attacking unit can do is 0 damage, so it does not attack at all.
                continue;
            }

            var def = defending.shift();

            result.set(att, def);
        }

        return result;
    }

    private static function totalUnits(army: Array<UnitGroup>) {
        return army.map(u -> u.units).fold((r, i) -> r + i, 0);
    }

    private static function combat(team1: Array<UnitGroup>, team2: Array<UnitGroup>, team1boost: Int): String {
        team1 = team1.map(u -> u.boostedCopy(team1boost));
        team2 = team2.map(u -> u.copy());

        // +1 so we don't break out immediately.
        var prevUnits = [totalUnits(team1) + 1, totalUnits(team2) + 1];

        var steps = 0;
        while (team1.length > 0 && team2.length > 0) {
            steps++;

            if (prevUnits[0] == totalUnits(team1) && prevUnits[1] == totalUnits(team2)) {
                return "Stalemate!";
            }
            prevUnits = [totalUnits(team1), totalUnits(team2)];


            team1 = team1.filter(u -> u.units > 0);
            team2 = team2.filter(u -> u.units > 0);

            // Target phase
            var combatPairs = new Map<UnitGroup, UnitGroup>();

            for (pair in targeting(team1, team2).keyValueIterator()) {
                combatPairs.set(pair.key, pair.value);
            }

            for (pair in targeting(team2, team1).keyValueIterator()) {
                combatPairs.set(pair.key, pair.value);
            }

            // Attack phase
            var attackers = new Array<UnitGroup>();
            for (k in combatPairs.keys()) {
                attackers.push(k);
            }
            attackers.sort((u1, u2) -> u2.initiative - u1.initiative);

            for (att in attackers) {
                if (att.units <= 0) {
                    continue;
                }
                var def = combatPairs.get(att);
                att.doDamageTo(def);
            }
        }

        if (team1.length > 0) {
            final rem = team1.map(u -> u.units).fold((i,r) -> i + r, 0);
            return 'Team 1 wins with $rem remaining units.';
        }
        if (team2.length > 0) {
            final rem = team2.map(u -> u.units).fold((i,r) -> i + r, 0);
            return 'Team 2 wins with $rem remaining units.';
        }

        throw new Exception("Invalid combat ending.");
    }

}

//
// UnitGroup class
//

class UnitGroup {

    public var units: Int;
    
    public final hitPoints: Int;
    public final attackDamage: Int;
    public final attackType: String;
    public final initiative: Int;
    
    public final weaknesses: Array<String>;
    public final immunities: Array<String>;

    public function new(
        units: Int, 
        hitPoints: Int, 
        attackDamage: Int,
        attackType: String, 
        weaknesses: Array<String>, 
        immunities: Array<String>,
        initiative: Int
    ) {
        this.units = units;
        this.hitPoints = hitPoints;
        this.attackType = attackType;
        this.attackDamage = attackDamage;
        this.weaknesses = weaknesses;
        this.immunities = immunities;
        this.initiative = initiative;
    }

    public static function parse(str: String): UnitGroup {
        var r1 = ~/^(\d+) units each with (\d+) hit points ?(?:\((.+)\))? with an attack that does (\d+) (\w+) damage at initiative (\d+)$/;
        r1.match(str);

        final units: Int = Std.parseInt(r1.matched(1));
        final hitPoints: Int = Std.parseInt(r1.matched(2));
        final attackDamage: Int = Std.parseInt(r1.matched(4));
        final attackType: String = r1.matched(5);
        final initiative: Int = Std.parseInt(r1.matched(6));
        
        var weaknesses = new Array<String>();
        var immunities = new Array<String>();

        if (r1.matched(3) != null) {
            var r2 = ~/^(weak|immune) to ([\w, ]+)$/;
            var parts = r1.matched(3).split("; ");
            for (p in parts) {
                r2.match(p);
                if (r2.matched(1) == "weak") {
                    weaknesses = r2.matched(2).split(", ");
                } else {
                    immunities = r2.matched(2).split(", ");
                }
            }
        }

        return new UnitGroup(units, hitPoints, attackDamage, attackType, weaknesses, immunities, initiative);
    }

    public function getEffectivePower() {
        return units * attackDamage;
    }

    public function damageTo(other: UnitGroup): Int {
        if (other.immunities.contains(this.attackType)) {
            return 0;
        }
        if (other.weaknesses.contains(this.attackType)) {
            return this.getEffectivePower() * 2;
        } 
        return this.getEffectivePower();
    }

    public function doDamageTo(other: UnitGroup): Void {
        final kills: Int = Math.floor(this.damageTo(other) / other.hitPoints);
        other.units -= kills;
    }

    public function copy(): UnitGroup {
        return new UnitGroup(
            this.units,
            this.hitPoints,
            this.attackDamage,
            this.attackType,
            this.weaknesses.copy(),
            this.immunities.copy(),
            this.initiative
        );
    }

    public function boostedCopy(boost: Int): UnitGroup {
        return new UnitGroup(
            this.units,
            this.hitPoints,
            this.attackDamage + boost,
            this.attackType,
            this.weaknesses.copy(),
            this.immunities.copy(),
            this.initiative
        );
    }

    public function toString(): String {
        return '$units units each with $hitPoints hit points (weak to ${weaknesses.join(", ")}; immune to ${immunities.join(", ")}) with an attack that does $attackDamage $attackType damage at initiative $initiative';
    }

}
