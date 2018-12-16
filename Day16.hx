class Day16 {

    static public function main() {

        var inputContent:String = sys.io.File.getContent('input/16');
        //var inputContent:String = "Before: [3, 2, 1, 1]\n9 2 1 2\nAfter:  [3, 2, 2, 1]";
		var lines = inputContent.split("\n");

        var samples = new Array<Sample>();
        var instructions = new Array<Array<Int>>();

        var i = 0;
        var linebreaks = 0;
        var part2 = false;
        while(i < lines.length) {
            if (linebreaks > 2) {
                part2 = true;
            }

            if (StringTools.trim(lines[i]).length == 0) {
                linebreaks++;
                i++;
                continue;
            } else {
                linebreaks = 0;
            }

            if (!part2) {
                if (StringTools.startsWith(lines[i], "Before")) {
                    var bs = StringTools.trim(lines[i].split(":")[1]);
                    var is = StringTools.trim(lines[i+1]);
                    var as = StringTools.trim(lines[i+2].split(":")[1]);

                    var bsa = [ for (i in bs.substring(1, bs.length-1).split(",")) Std.parseInt(i)];
                    var asa = [ for (i in as.substring(1, as.length-1).split(",")) Std.parseInt(i)];
                    var isa = [ for (i in is.split(" ")) Std.parseInt(i)];

                    samples.push(new Sample(bsa, asa, isa));

                    i+=3;
                    continue;
                }
            } else {
                instructions.push([ for (i in lines[i].split(" ")) Std.parseInt(i)]);
                i+=1;
                continue;
            }
        }

        var count = 0;
        for (sample in samples) {
            if (sample.possibleInstructions().length >= 3) {
                count++;
            }
        }
        trace(count); // part 1

        var possibles = new Map<Int, Array<String>>();
        for (sample in samples) {
            var instrNum = sample.instruction[0];
            var instrs = sample.possibleInstructions();

            if (!possibles.exists(instrNum)) {
                possibles.set(instrNum, instrs);
            } else {
                possibles.set(instrNum, intersection(possibles.get(instrNum), instrs));
            }
        }
        // trace(possibles);

        var determined = new Map<Int, String>();
        var ds = 0;
        while(ds < 16) {
            for (pk in possibles.keys()) {
                var pv = possibles.get(pk);
                for (d in determined.iterator()) {
                    pv.remove(d);
                    possibles.set(pk, pv);
                }

                if (pv.length == 1) {
                    determined.set(pk, pv[0]);
                    possibles.remove(pk);
                    ds++;
                }
            }
        }
        trace(determined);
        
        var register = new Register([0, 0, 0, 0]);
        for (instr in instructions) {
            var args = instr.slice(1);
            var op = Reflect.field(register, determined.get(instr[0]));
            Reflect.callMethod(register, op, args);
        }
        trace(register); // part 2
    }

    static public function intersection(arr1: Array<String>, arr2: Array<String>): Array<String> {
        var u = new Array<String>();
        for (g in arr1) {
            for (h in arr2) {
                if (g == h) {
                    u.push(g);
                    break;
                }
            }
        }
        return u;
    }

}

class Sample {
    public var before: Array<Int>;
    public var after: Array<Int>;
    public var instruction: Array<Int>;
    public function new(before, after, instruction) {
        this.before = before;
        this.after = after;
        this.instruction = instruction;
    }

    public function possibleInstructions() {
        var areg = new Register(after);
        var possible = new Array<String>();

        for (instr in Register.instructionSet) {
            var breg = new Register(before);
            var fn = Reflect.field(breg, instr);
            // trace("-----");
            // trace(instr, breg);
            Reflect.callMethod(breg, fn, instruction.slice(1));
            // trace(breg);
            if (breg.equals(areg)) {
                possible.push(instr);
            }
        }
        // trace(possible);
        return possible;
    }
}

class Register {

    public var memory: Array<Int>;

    public static var instructionSet = [
        "addr", "addi", "mulr", "muli", "setr", "seti", "banr", "bani", "borr", "bori", "gtir", "gtri", "gtrr", 
        "eqir", "eqri", "eqrr"
    ];

    public function new(initial: Array<Int>) {
        this.memory = initial.copy();
    }

    public function addr(a, b, c) { memory[c] = memory[a] + memory[b]; }
    public function addi(a, b, c) { memory[c] = memory[a] + b; }
    
    public function mulr(a, b, c) { memory[c] = memory[a] * memory[b]; }
    public function muli(a, b, c) { memory[c] = memory[a] * b; }
    
    public function setr(a, b, c) { memory[c] = memory[a]; }
    public function seti(a, b, c) { memory[c] = a; }

    public function banr(a, b, c) { memory[c] = memory[a] & memory[b]; }
    public function bani(a, b, c) { memory[c] = memory[a] & b; }
    
    public function borr(a, b, c) { memory[c] = memory[a] | memory[b]; }
    public function bori(a, b, c) { memory[c] = memory[a] | b; }
    
    public function gtir(a, b, c) { if (a > memory[b]) memory[c] = 1 else memory[c] = 0; }
    public function gtri(a, b, c) { if (memory[a] > b) memory[c] = 1 else memory[c] = 0; }
    public function gtrr(a, b, c) { if (memory[a] > memory[b]) memory[c] = 1 else memory[c] = 0; }

    public function eqir(a, b, c) { if (a == memory[b]) memory[c] = 1 else memory[c] = 0; }
    public function eqri(a, b, c) { if (memory[a] == b) memory[c] = 1 else memory[c] = 0; }
    public function eqrr(a, b, c) { if (memory[a] == memory[b]) memory[c] = 1 else memory[c] = 0; }

    public function copy() {
        return new Register(memory);
    }

    public function equals(other: Register) {
        for (i in 0...this.memory.length) {
            if (this.memory[i] != other.memory[i]) {
                return false;
            }
        }
        return true;
    }
}