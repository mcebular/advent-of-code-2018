class Day12 {

    static public function main() {

        var inputContent:String = sys.io.File.getContent('input/12');
		var lines = inputContent.split("\n");

        var rules = new Array<GrowthRule>();
        for (line in lines) {
            var r = GrowthRule.fromString(line);
            rules.push(r);
        }

        // trace(rules);

        var initialState = ".##..#.#..##..##..##...#####.#.....#..#..##.###.#.####......#.......#..###.#.#.##.#.#.###...##.###.#";
        var states = new Array<Bool>();
        states.push(false);
        states.push(false);
        states.push(false);
        for (i in 0...initialState.length) {
            states.push(initialState.charAt(i) == "#");
        }
        states.push(false);
        states.push(false);
        states.push(false);

        // trace(statesToString(states));

        // simulation
        var startIndex:Float = -3;
        var gens:Float = 50000000000; // part 2
        // var gens = 20; // part 1
        var equalgens = false;
        while (gens > 0) {

            // equal generations are off by 1, 
            // so we just add the remaining generations to startIndex
            if (equalgens) {
                startIndex += gens;
                break;
                continue;
            }

            // cut falses in front
            while(!(states[0] || states[1])) {
                states.shift();
                startIndex++;
            }

            // add two falses back
            states.insert(0, false);
            startIndex--;
            states.insert(0, false);
            startIndex--;

            if(!states[states.length-1] && !states[states.length-2]) {
                states.push(false);
            }

            var statesPrev = states.copy();
            for (i in 0...states.length-2) {

                var slice = statesPrev.slice(i-2,i+3);
                states[i] = ruleResult(rules, slice);

            }
            
            // At some point, generations become equal.
            if(states.length == statesPrev.length) {
                equalgens = true;
                for (i in 0...states.length-1) {
                    if (states[i+1] != statesPrev[i]) {
                        equalgens = false;
                        break;
                    }
                }
            }
            
            gens -= 1;
            // trace(statesToString(states));
        }

        var sum:Float = 0;
        for(i in 0...states.length) {
            if (states[i]) sum += i + startIndex;
        }
        trace(sum);

    }

    static public function ruleResult(rules:Array<GrowthRule>, plants:Array<Bool>) {
        for (r in rules) {
            if (r.fits(plants)) {
                return r.produces;
            }
        }
        return false;
    }

    static public function statesToString(states:Array<Bool>) {
        var str = "";
        for (s in states) {
            if (s) str += "#";
            else str += ".";
        }
        return str;
    }

}

class GrowthRule {

    public var combination:Array<Bool>;
    public var produces:Bool;

    public function new(combination:Array<Bool>, produces:Bool) {
        this.combination = combination;
        this.produces = produces;
    }

    static public function fromString(str:String):GrowthRule {
        var spl = str.split(" => ");
        
        var combination = new Array();
        for (i in 0...spl[0].length) {
            combination.push(spl[0].charAt(i) == "#");
        }

        var produces = spl[1] == "#";

        return new GrowthRule(combination, produces); 
    }

    public function fits(plants:Array<Bool>) {
        for (i in 0...combination.length) {
            if (combination[i] != plants[i]) {
                return false;
            }
        }
        return true;
    }

    public function toString() {
        return '$combination => $produces';
    }

}