class Day19 {

    static public function main() {

        var inputContent:String = sys.io.File.getContent('input/19');
		var lines = inputContent.split("\n");

        var ptr = Std.parseInt(lines.shift().split(" ")[1]);

        var instructions = new Array<Instruction>();
        for (line in lines) {
            var tmp = line.split(" ");

            var instr = new Instruction(tmp[0], [for (i in tmp.slice(1)) Std.parseInt(i)]);
            instructions.push(instr);
        }

        var cpuStart = Sys.cpuTime();
        var register = new Register([1,0,0,0,0,0], ptr);
        while(register.getPointerValue() < instructions.length) {
            var instr = instructions[register.getPointerValue()];
            // trace(register.getPointerValue() + "," + instr);

            var op = Reflect.field(register, instr.operation);
            Reflect.callMethod(register, op, instr.registers);
            // trace(register);

            register.incrementPointerValue();
        }

        register.decrementPointerValue();
        trace(Sys.cpuTime() - cpuStart);
        trace(register);

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