import haxe.Exception;

using Lambda;
using StringTools;


class Day23 {

    static public function main() {
        UnitTests.all();

        var inputContent: Array<String> = sys.io.File.getContent("input/23").split("\n");

        var nanobots = new Array<NanoBot>();
        for (line in inputContent) {
            if (line.trim().length == 0) {
                continue;
            }
            var rx = ~/^pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)$/;
            rx.match(line);

            nanobots.push(new NanoBot(
                Std.parseInt(rx.matched(1)),
                Std.parseInt(rx.matched(2)),
                Std.parseInt(rx.matched(3)),
                Std.parseInt(rx.matched(4))
            ));
        }

        part1(nanobots);
        part2(nanobots);
    }

    private static function part1(nanobots: Array<NanoBot>) {
        nanobots = nanobots.copy();
        nanobots.sort((a, b) -> b.r - a.r);

        var strongestNanoBot = nanobots[0];
        // trace(strongestNanoBot);

        var countInRange = 0;
        for (nanobot in nanobots) {
            final dist = nanobot.distanceTo(strongestNanoBot);
            if (dist <= strongestNanoBot.r) {
                countInRange++;
            }
        }
        trace('Part 1: $countInRange');
    }

    private static function part2(nanobots: Array<NanoBot>) {
        // Note: this worked for my input, but one more thing that *should* be 
        // done is when pushing cubes to queue, if there are multiple cubes with 
        // the same priority, cube closest to the origin (0, 0, 0) should have 
        // the highest priority. 
        // I think this would ensure that if there are multiple best positions, 
        // the closest one to origin would be found first (which conveniently 
        // happened anyway for my input).

        nanobots = nanobots.copy();

        final cubeQueue = new PriorityQueue<Cube>();

        var cube = getAllNanoBotsCube(nanobots);
        cubeQueue.push(-countNanoBotsInCube(nanobots, cube), cube);

        var maxNanobots = 0;
        var bestPosition: Vector3 = null;
        while (!cubeQueue.isEmpty()) {
            final current = cubeQueue.pop();
            final currentNb = countNanoBotsInCube(nanobots, cube);

            if (currentNb <= maxNanobots) {
                continue;
            }

            // if unit cube, no more splits necessary.
            if (current.isUnitCube()) {
                if (maxNanobots < currentNb) {
                    maxNanobots = currentNb;
                    bestPosition = current.center;
                }
                continue;
            }

            for (next in current.split()) {
                cubeQueue.push(-countNanoBotsInCube(nanobots, next), next);
            }
        }

        trace ('Part 2: ${new Vector3(0, 0, 0).distanceTo(bestPosition)}');
    }

    private static function getAllNanoBotsCube(nanobots: Array<NanoBot>): Cube {
        var minX = 0;
        var minY = 0;
        var minZ = 0;
        var maxX = 0;
        var maxY = 0;
        var maxZ = 0;

        for (nanobot in nanobots) {
            minX = Math.floor(Math.min(nanobot.pos.x, minX));
            minY = Math.floor(Math.min(nanobot.pos.y, minY));
            minZ = Math.floor(Math.min(nanobot.pos.z, minZ));
            maxX = Math.floor(Math.max(nanobot.pos.x, maxX));
            maxY = Math.floor(Math.max(nanobot.pos.y, maxY));
            maxZ = Math.floor(Math.max(nanobot.pos.z, maxZ));
        }

        var cube = new Cube(
            new Vector3(minX, minY, minZ),
            new Vector3(maxX, maxY, maxZ)
        );
        assertAllNanoBotsInCube(nanobots, cube);
        return cube;
    }

    private static function countNanoBotsInCube(nanobots: Array<NanoBot>, cube: Cube): Int {
        return nanobots
            .map(nb -> nb.canReachCube(cube))
            .filter(i -> i)
            .length;
    }

    private static function assertAllNanoBotsInCube(nanobots: Array<NanoBot>, cube: Cube): Void {
        var count = 0;
        for (nanobot in nanobots) {
            if (nanobot.canReachCube(cube)) {
                count++;
            } else {
                throw new Exception('Nanobot not in cube? $cube $nanobot');
            }
        }
    }

}

//
// NanoBot class
//
class NanoBot {
    public final pos: Vector3;
    public final r: Int;

    public function new (x, y, z, r) {
        this.pos = new Vector3(x, y, z);
        this.r = r;
    }

    public function distanceTo(other: NanoBot): Int {
        return this.pos.distanceTo(other.pos);
    }

    public function canReachCube(cube: Cube): Bool {
        // https://stackoverflow.com/a/4579069
        var dist: Int = this.r;
        if (this.pos.x < cube.from.x) dist -= Math.floor(Math.abs(this.pos.x - cube.from.x));
        else if (this.pos.x > cube.to.x) dist -= Math.floor(Math.abs(this.pos.x - cube.to.x));
        if (this.pos.y < cube.from.y) dist -= Math.floor(Math.abs(this.pos.y - cube.from.y));
        else if (this.pos.y > cube.to.y) dist -= Math.floor(Math.abs(this.pos.y - cube.to.y));
        if (this.pos.z < cube.from.z) dist -= Math.floor(Math.abs(this.pos.z - cube.from.z));
        else if (this.pos.z > cube.to.z) dist -= Math.floor(Math.abs(this.pos.z - cube.to.z));
        return dist >= 0;
    }
    
    public function toString(): String {
        return 'pos=<${pos.x},${pos.y},${pos.z}>, r=${r}';
    }
}

//
// Vector3 class
//
class Vector3 {
    public final x: Int;
    public final y: Int;
    public final z: Int;
    
    public function new (x, y, z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function equals(other: Vector3) {
        return this.x == other.x && this.y == other.y && this.z == other.z;
    }

    public function distanceTo(other: Vector3): Int {
        return Math.floor(
            Math.abs(this.x - other.x) + 
            Math.abs(this.y - other.y) + 
            Math.abs(this.z - other.z)
        );
    }

    public function toString(): String {
        return '<$x,$y,$z>';
    }
}

//
// Cube class
//
class Cube {
    public final from: Vector3;
    public final to: Vector3;
    public final center: Vector3;

    public function new (from, to) {
        this.from = from;
        this.to = to;
        this.center = _center(from, to);
    }

    private function _center(from: Vector3, to: Vector3): Vector3 {
        return new Vector3(
            Math.floor((from.x + to.x) / 2),
            Math.floor((from.y + to.y) / 2),
            Math.floor((from.z + to.z) / 2)
        );
    }

    public function split(): Array<Cube> {
        if (isUnitCube()) {
            throw new Exception("Cannot split a unit cube.");
        }
        return [
            new Cube(new Vector3(from.x, from.y, from.z), new Vector3(center.x, center.y, center.z)),
            new Cube(new Vector3(center.x + 1, from.y, from.z), new Vector3(to.x, center.y, center.z)),
            new Cube(new Vector3(from.x, center.y + 1, from.z), new Vector3(center.x, to.y, center.z)),
            new Cube(new Vector3(center.x + 1, center.y + 1, from.z), new Vector3(to.x, to.y, center.z)),
            new Cube(new Vector3(from.x, from.y, center.z + 1), new Vector3(center.x, center.y, to.z)),
            new Cube(new Vector3(center.x + 1, from.y, center.z + 1), new Vector3(to.x, center.y, to.z)),
            new Cube(new Vector3(from.x, center.y + 1, center.z + 1), new Vector3(center.x, to.y, to.z)),
            new Cube(new Vector3(center.x + 1, center.y + 1, center.z + 1), new Vector3(to.x, to.y, to.z))
        ];
    }

    public function isUnitCube(): Bool {
        return to.x - from.x == 0 &&
               to.y - from.y == 0 &&
               to.z - from.z == 0;
    }

    public function toString(): String {
        return 'Cube[$from $to]';
    }

}

//
// Unit tests
//
class UnitTests {
    public static function all() {
        testNanoBotCanReachCube();
        testCubeSplit();
    }

    public static function testNanoBotCanReachCube() {
        assert(new NanoBot(0, 0, 0, 0).canReachCube(new Cube(new Vector3(0, 0, 0), new Vector3(1, 1, 1))), true);
        assert(new NanoBot(0, 0, 0, 0).canReachCube(new Cube(new Vector3(1, 0, 0), new Vector3(1, 1, 1))), false);
        assert(new NanoBot(0, 0, 0, 1).canReachCube(new Cube(new Vector3(0, 0, 0), new Vector3(2, 2, 2))), true);
        assert(new NanoBot(0, 0, 0, 1).canReachCube(new Cube(new Vector3(1, 0, 0), new Vector3(2, 2, 2))), true);
        assert(new NanoBot(0, 0, 0, 3).canReachCube(new Cube(new Vector3(1, 1, 1), new Vector3(2, 2, 2))), true);
        assert(new NanoBot(5, 5, 0, 2).canReachCube(new Cube(new Vector3(1, 1, 0), new Vector3(4, 4, 0))), true);
        assert(new NanoBot(5, 5, 0, 1).canReachCube(new Cube(new Vector3(1, 1, 0), new Vector3(40, 4, 0))), true);
        assert(new NanoBot(5, 6, 0, 1).canReachCube(new Cube(new Vector3(1, 1, 0), new Vector3(40, 4, 0))), false);
        assert(new NanoBot(5, 6, 0, 2).canReachCube(new Cube(new Vector3(1, 1, 0), new Vector3(40, 4, 0))), true);
        assert(new NanoBot(0, 0, 0, 2).canReachCube(new Cube(new Vector3(-5, -5, -5), new Vector3(5, 5, 5))), true);
    }

    public static function testCubeSplit() {
        assert(new Vector3(1, 5, 8).equals(new Vector3(1, 5, 8)), true);
        assert(new Vector3(1, 5, 8).equals(new Vector3(1, 5, 7)), false);

        assertVec(new Cube(new Vector3(0, 0, 0), new Vector3(2, 2, 2)).center, new Vector3(1, 1, 1));

        // this one can only split in half.
        final cubes = new Cube(new Vector3(0, 0, 0), new Vector3(1, 0, 0)).split();
        assertVec(cubes[0].center, new Vector3(0, 0, 0));
        assertVec(cubes[1].center, new Vector3(1, 0, 0));
        assertVec(cubes[2].center, new Vector3(0, 0, 0));
        assertVec(cubes[3].center, new Vector3(1, 0, 0));
        assertVec(cubes[4].center, new Vector3(0, 0, 0));
        assertVec(cubes[5].center, new Vector3(1, 0, 0));
        assertVec(cubes[6].center, new Vector3(0, 0, 0));
        assertVec(cubes[7].center, new Vector3(1, 0, 0));

        // this one splits in exactly eight unit cubes.
        final cubes = new Cube(new Vector3(0, 0, 0), new Vector3(1, 1, 1)).split();
        assertVec(cubes[0].center, new Vector3(0, 0, 0));
        assertVec(cubes[1].center, new Vector3(1, 0, 0));
        assertVec(cubes[2].center, new Vector3(0, 1, 0));
        assertVec(cubes[3].center, new Vector3(1, 1, 0));
        assertVec(cubes[4].center, new Vector3(0, 0, 1));
        assertVec(cubes[5].center, new Vector3(1, 0, 1));
        assertVec(cubes[6].center, new Vector3(0, 1, 1));
        assertVec(cubes[7].center, new Vector3(1, 1, 1));

        // this one splits in eight unequal-sized unit cubes.
        final cubes = new Cube(new Vector3(0, 0, 0), new Vector3(2, 2, 2)).split();
        assertVec(cubes[0].from, new Vector3(0, 0, 0));
        assertVec(cubes[0].to,   new Vector3(1, 1, 1));
        assertVec(cubes[1].from, new Vector3(2, 0, 0));
        assertVec(cubes[1].to,   new Vector3(2, 1, 1));
        assertVec(cubes[2].from, new Vector3(0, 2, 0));
        assertVec(cubes[2].to,   new Vector3(1, 2, 1));
        assertVec(cubes[3].from, new Vector3(2, 2, 0));
        assertVec(cubes[3].to,   new Vector3(2, 2, 1));
        assertVec(cubes[4].from, new Vector3(0, 0, 2));
        assertVec(cubes[4].to,   new Vector3(1, 1, 2));
        assertVec(cubes[5].from, new Vector3(2, 0, 2));
        assertVec(cubes[5].to,   new Vector3(2, 1, 2));
        assertVec(cubes[6].from, new Vector3(0, 2, 2));
        assertVec(cubes[6].to,   new Vector3(1, 2, 2));
        assertVec(cubes[7].from, new Vector3(2, 2, 2));
        assertVec(cubes[7].to,   new Vector3(2, 2, 2));

        final cubes = new Cube(new Vector3(0, 0, 0), new Vector3(12, 12, 12)).split();
        assertVec(cubes[0].center, new Vector3(3, 3, 3));
        assertVec(cubes[1].center, new Vector3(9, 3, 3));
        assertVec(cubes[2].center, new Vector3(3, 9, 3));
        assertVec(cubes[3].center, new Vector3(9, 9, 3));
        assertVec(cubes[4].center, new Vector3(3, 3, 9));
        assertVec(cubes[5].center, new Vector3(9, 3, 9));
        assertVec(cubes[6].center, new Vector3(3, 9, 9));
        assertVec(cubes[7].center, new Vector3(9, 9, 9));
    }

    private static function assert<T>(a: T, b: T): Void {
        if (a != b) {
            throw new Exception('"$a" is not equal to "$b"');
        }
    }

    private static function assertVec(a: Vector3, b: Vector3): Void {
        if (!a.equals(b)) {
            throw new Exception('"$a" is not equal to "$b"');
        }
    }
}

//
// Priority queue implemented as a ordered linked list. Not the most efficient, but should be good enough.
// I copied this from Day22.hx (which also has some unit tests for this!)
//
class PriorityQueueItem<T> {
    public final priority: Int;
    public final value: T;

    public var next: PriorityQueueItem<T>;

    public function new(priority, value) {
        this.priority = priority;
        this.value = value;
    }
}

class PriorityQueue<T> {

    private var q: PriorityQueueItem<T> = null;

    private var _size: Int = 0;

    public function new() { }

    public function push(priority: Int, value: T) {
        if (q == null) {
            q = new PriorityQueueItem(priority, value);

        } else if (q.priority > priority) {
            final next = q;
            q = new PriorityQueueItem(priority, value);
            q.next = next;

        } else {
            var currentItem = q;
            while (currentItem != null) {
                if (currentItem.next == null || currentItem.next.priority > priority) {
                    final next = currentItem.next;
                    currentItem.next = new PriorityQueueItem(priority, value);
                    currentItem.next.next = next;
                    break;
                }
                currentItem = currentItem.next;
            };
        }
        this._size++;
    }

    public function peek(): T {
        if (this._size == 0) {
            return null;
        }
        return q.value;
    }

    public function pop(): T {
        if (this._size == 0) {
            throw new Exception("Calling .pop() on an empty queue.");
        }

        final v = this.peek();
        q = q.next;
        this._size--;
        return v;
    }

    public function isEmpty() {
        return this.size() == 0;
    }

    public function size() {
        return this._size;
    }

    public function _print() {
        var c = q;
        while (c != null) {
            Sys.print(c.priority + " -> ");
            c = c.next;
        }
        Sys.print("\n");
    }

}