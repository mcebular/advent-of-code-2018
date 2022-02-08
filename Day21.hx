import haxe.Exception;

class Day21 {

    static public function main() {

        var inputContent:String = sys.io.File.getContent('input/21');
		var lines = inputContent.split("\n");

        var ptr = Std.parseInt(lines.shift().split(" ")[1]);

        var instructions = new Array<Instruction>();
        for (line in lines) {
            var tmp = line.split(" ");

            var instr = new Instruction(tmp[0], [for (i in tmp.slice(1)) Std.parseInt(i)]);
            // trace(instr.toReadable());
            instructions.push(instr);
        }

        // true  = walk thorugh program step-by-step
        // false = program runs without stopping
        final DEBUG_MODE = false;

        var register = new Register([0,0,0,0,0,0], ptr);

        var firstHaltingNumber: Int = null;
        var lastHaltingNumber: Int = null;
        var haltingNumbers = new Map<Int, Bool>();
        
        while(register.getPointerValue() < instructions.length) {
            var instr = instructions[register.getPointerValue()];
            if (DEBUG_MODE == true) {
                Sys.print('\n');
                Sys.print('[0] ${register.memory[0]}                          \n');
                Sys.print('[1] ${register.memory[1]}                          \n');
                // Sys.print('[2] ${register.memory[2]}                          \n');
                Sys.print('[3] ${register.memory[3]}                          \n');
                Sys.print('[4] ${register.memory[4]}                          \n');
                Sys.print('[5] ${register.memory[5]}                          \n');
                Sys.print('\n');
                Sys.print('${register.getPointerValue()}                      \n');
                Sys.print('${instr}                                           \n');
                Sys.print('                      \x1B[0G');
            }
            
            // Stopping allows analyzing of what the program is doing.
            var line = "";
            if (DEBUG_MODE == true) {
                line = Sys.stdin().readLine();
                Sys.print('\x1B[10F');
            }
            
            // Solving notes:
            // Inner-most circle runs from 18 to 25, and exits once [1] * 256 > [3].
            // Program halts when at 28, register [5] == [1] (which is user input).

            if (line.length > 0) {
                // Allow direct memory modification if given an input.
                var parts = line.split("=");
                var reg = Std.parseInt(parts[0]);
                var val = Std.parseInt(parts[1]);
                register.memory[reg] = val;

            } else {
                if (register.getPointerValue() == 18) {
                    // we are at "addi 1 1 4". We can skip most of the inner-most loop
                    // by setting [1] = [3] / 256.
                    register.memory[1] = Math.floor(register.memory[3] / 256);
    
                } else if (register.getPointerValue() == 28) {
                    // we are at "eqrr 5 0 1". Value in [5] is the value we should've 
                    // set in [0] to halt the program.
                    final haltingNum = register.memory[5];
                    if (firstHaltingNumber == null) {
                        firstHaltingNumber = haltingNum;
                    }
                    if (haltingNumbers.exists(haltingNum)) {
                        // we already saw that number, let's terminate the program.
                        register.memory[2] = 99;
                    } else {
                        lastHaltingNumber = haltingNum;
                        haltingNumbers.set(haltingNum, true);
                    }
                }

                // Perform next operation if there were no direct memory modifications.
                var op = Reflect.field(register, instr.operation);
                Reflect.callMethod(register, op, instr.registers);
                register.incrementPointerValue();
            }
        }

        Sys.print('\x1B[0J');
        // Part 1
        trace(firstHaltingNumber);
        // Part 2
        trace(lastHaltingNumber);
    }

}

class Instruction {
    public var operation: String;
    public var registers: Array<Int>;
    public function new(operation: String, registers: Array<Int>) {
        this.operation = operation;
        this.registers = registers;
    }

    public function toString() {
        return '$operation $registers';
    }

    public function toReadable() {
        final a = registers[0];
        final b = registers[1];
        final c = registers[2];
        switch(operation) {
            case "addr":
                return '[$c] = [$a] + [$b]';
            case "addi":
                return '[$c] = [$a] + $b';
            case "mulr":
                return '[$c] = [$a] * [$b]';
            case "muli":
                return '[$c] = [$a] * $b';
            case "setr":
                return '[$c] = [$a]';
            case "seti":
                return '[$c] = $a';
            case "banr":
                return '[$c] = [$a] & [$b]';
            case "bani":
                return '[$c] = [$a] & $b';
            case "borr":
                return '[$c] = [$a] | [$b]';
            case "bori":
                return '[$c] = [$a] | $b';
            case "gtir":
                return '[$c] = $a > [$b]';
            case "gtri":
                return '[$c] = [$a] > $b';
            case "gtrr":
                return '[$c] = [$a] > [$b]';
            case "eqir":
                return '[$c] = $a == [$b]';
            case "eqri":
                return '[$c] = [$a] == $b';
            case "eqrr":
                return '[$c] = [$a] == [$b]';
            default:
                return "???";
                
        }
    }
}

class Register {

    public var memory: Array<Int>;
    public var instructionPointer: Int;

    public function new(initial: Array<Int>, ptr) {
        this.memory = initial.copy();
        this.instructionPointer = ptr;
    }

    public function getPointerValue() {
        return this.memory[this.instructionPointer];
    }

    public function incrementPointerValue() {
        this.memory[this.instructionPointer]++;
    }

    public function decrementPointerValue() {
        this.memory[this.instructionPointer]--;
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

    public function toString() {
        var ipv = getPointerValue();
        return 'MEM=$memory IP=$ipv';
    }

}