import haxe.Exception;

class Day22 {

    static public function main() {
        PriorityQueueUnitTests.run();

        // var depth = 510;
        // var targetX = 10;
        // var targetY = 10;
        var depth = 8112;
        var targetX = 13;
        var targetY = 743;

        var area = new RegionsArea();

        for (x in 0...targetX + 200) {
            for (y in 0...targetY + 200) {
                var geoIndex = getGeoIndex(x, y, targetX, targetY, area);
                var erosionLevel = getErosionLevel(geoIndex, depth);

                var r = new Region(x, y, geoIndex, erosionLevel);
                area.set(x, y, r);
            }
        }

        // area.print(0, 0, targetX, targetY, targetX, targetY);

        // part 1
        trace(area.getRiskLevel(0, 0, targetX + 1, targetY + 1));

        // part 2
        rescue(area, targetX, targetY);
    }

    static private function rescue(area: RegionsArea, targetX: Int, targetY: Int) {
        // trace ("-----");

        final queue = new PriorityQueue<QueueState>();
        queue.push(0, new QueueState(0, 0, 0, Torch, null));
        
        final visited = new Map<String, QueueState>();

        while (!queue.isEmpty()) {
            final s: QueueState = queue.pop();

            Sys.print("\x1B[0G");
            Sys.print(queue.size());
            Sys.print("\x1B[10G");
            Sys.print(s.time);
            Sys.print("\x1B[20G");
            Sys.print(distance(s.x, s.y, targetX, targetY));
            Sys.print("\x1B[30G");
            Sys.print(s);
            Sys.print("\x1B[0G");

            if (visited.exists(s.toKey()) && visited.get(s.toKey()).time <= s.time) {
                continue;
            }
            visited.set(s.toKey(), s);

            if (s.x == targetX && s.y == targetY && s.tool == Torch) {
                trace(s);
                break;
            }

            // possible moves: up, down, left, right
            // !! only if current tool allows
            // !! takes 1 minute
            if (s.x > 0 && toolValidForRegion(s.tool, area.get(s.x - 1, s.y))) {
                queue.push(s.time + 1 + distance(s.x - 1, s.y, targetX, targetY), new QueueState(s.time + 1, s.x - 1, s.y, s.tool, s));
            }

            if (s.y > 0 && toolValidForRegion(s.tool, area.get(s.x, s.y - 1))) {
                queue.push(s.time + 1 + distance(s.x, s.y - 1, targetX, targetY), new QueueState(s.time + 1, s.x, s.y - 1, s.tool, s));
            }

            if (toolValidForRegion(s.tool, area.get(s.x + 1, s.y))) {
                queue.push(s.time + 1 + distance(s.x + 1, s.y, targetX, targetY), new QueueState(s.time + 1, s.x + 1, s.y, s.tool, s));
            }

            if (toolValidForRegion(s.tool, area.get(s.x, s.y + 1))) {
                queue.push(s.time + 1 + distance(s.x, s.y + 1, targetX, targetY), new QueueState(s.time + 1, s.x, s.y + 1, s.tool, s));
            }

            // possible moves: change gear (x2)
            // !! takes 7 minutes
            for (nt in [Nothing, Torch, ClimbingGear]) {
                if (nt == s.tool) continue;
                if (toolValidForRegion(nt, area.get(s.x, s.y))) {
                    queue.push(s.time + 7 + distance(s.x, s.y, targetX, targetY), new QueueState(s.time + 7, s.x, s.y, nt, s));
                }
            }
        }
    }

    private static function distance(fromX, fromY, toX, toY): Int {
        return Math.floor(Math.abs(fromX - toX) + Math.abs(fromY - toY));
    }

    private static function toolValidForRegion(tool: Tool, region: Region): Bool {
        if (region.type == Rocky) {
            return tool == ClimbingGear || tool == Torch;
        } else if (region.type == Wet) {
            return tool == ClimbingGear || tool == Nothing;
        } else if (region.type == Narrow) {
            return tool == Torch || tool == Nothing;
        } else {
            throw new Exception("Invalid region type: " + region.type);
        }
    }

    private static function getGeoIndex(x: Int, y: Int, tx: Int, ty: Int, area: RegionsArea): Int {
        if (x == 0 && y == 0 || x == tx && y == ty) {
            return 0;
        }
        if (x == 0) {
            return y * 48271;
        }
        if (y == 0) {
            return x * 16807;
        }
        return area.get(x - 1, y).erosionLevel * area.get(x, y - 1).erosionLevel;
    }

    private static function getErosionLevel(geoIndex: Int, caveDepth: Int) {
        return (geoIndex + caveDepth) % 20183;
    }

}


//
// QueueState class
//
class QueueState {
    public final time: Int;
    public final x: Int;
    public final y: Int;
    public final tool: Tool;
    public final previous: QueueState;

    public function new(time, x, y, tool, previous) {
        this.time = time;
        this.x = x;
        this.y = y;
        this.tool = tool;
        this.previous = previous;
    }

    public function toString() {
        return '<pos=($x, $y), tool=$tool, time=$time>';
    }

    public function toKey() {
        return '$x $y $tool';
    }
}

enum Tool {
    Nothing;
    Torch;
    ClimbingGear;
}

//
// Priority queue implemented as a ordered linked list. Not the most efficient, but should be good enough.
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

class PriorityQueueUnitTests {

    public static function run() {
        final q = new PriorityQueue<Int>();
        q.push(15, 15);
        
        assert(q.size(), 1);
        assert(q.peek(), 15);
        assert(q.pop(), 15);
        
        assert(q.size(), 0);
        assert(q.peek(), null);
    
        
        q.push(15, 15);
        q.push(16, 16);
        q.push(17, 17);
        
        q.push(32, 32);
        q.push(31, 31);
        q.push(33, 33);
        
        // q._print();

        assert(q.size(), 6); assert(q.peek(), 15); assert(q.pop(), 15);
        assert(q.size(), 5); assert(q.peek(), 16); assert(q.pop(), 16);
        assert(q.size(), 4); assert(q.peek(), 17); assert(q.pop(), 17);
        
        q.push(26, 26);
        q.push(25, 25);
        q.push(24, 24);

        // q._print();

        assert(q.size(), 6); assert(q.peek(), 24); assert(q.pop(), 24);
        assert(q.size(), 5); assert(q.peek(), 25); assert(q.pop(), 25);
        assert(q.size(), 4); assert(q.peek(), 26); assert(q.pop(), 26);

        assert(q.size(), 3); assert(q.peek(), 31); assert(q.pop(), 31);
        assert(q.size(), 2); assert(q.peek(), 32); assert(q.pop(), 32);
        assert(q.size(), 1); assert(q.peek(), 33); assert(q.pop(), 33);
        
        assert(q.size(), 0);
    }

    private static function assert<T>(a, b: T) {
        if (a != b) {
            throw new Exception('Assertion failed: ${a} is not equal to ${b}.');
        }
    }

}

//
// Area classes
//
class RegionsArea extends Area<Region> {

    public function print(fromX, fromY, toX, toY, targetX, targetY) {
        // toX, toY is inclusive when printing.
        for (y in fromY...toY + 1) {
            for (x in fromX...toX + 1) {
                if (x == 0 && y == 0) {
                    Sys.print("M");
                } else if (x == targetX && y == targetY) {
                    Sys.print("T");
                } else {
                    Sys.print(this.get(x, y).toChar());
                }
            }
            Sys.print("\n");
        }
    }

    public function getRiskLevel(fromX, fromY, toX, toY): Int {
        var riskSum = 0;
        for (x in fromX...toX) {
            for (y in fromY...toY) {
                riskSum += this.get(x, y).typeNumeric;
            }
        }
        return riskSum;
    }

}

class Area<T> {

    private final area: Map<Int, Map<Int, T>>;
    
    public function new() {
        this.area = new Map();
    }

    public function has(x: Int, y: Int) {
        return area.exists(x) && area.get(x).exists(y);
    }

    public function get(x: Int, y: Int): T {
        if (!area.exists(x)) {
            throw new Exception("");
        }
        var ax = area.get(x);
        if (!ax.exists(y)) {
            throw new Exception("");
        }

        return ax.get(y);
    }

    public function set(x: Int, y: Int, v: T) {
        if (!area.exists(x)) {
            area.set(x, new Map());
        }
        area.get(x).set(y, v);
    }

}

//
// Region class
//
class Region {
    
    public final x: Int;
    public final y: Int;
    public final geoIndex: Int;
    public final erosionLevel: Int;
    public final typeNumeric: Int;
    public final type: RegionType;

    public function new(x, y, geoIndex, erosionLevel) {
        this.x = x;
        this.y = y;
        this.geoIndex = geoIndex;
        this.erosionLevel = erosionLevel;
        this.typeNumeric = erosionLevel % 3;
        this.type = int2type(erosionLevel % 3);
    }

    private function int2type(t: Int): RegionType {
        switch (t) {
            case 0: return Rocky;
            case 1: return Wet;
            case 2: return Narrow;
            default: throw new Exception("Unknown type: " + this.type);
        }
    }

    public function toString() {
        return '[$x, $y]';
    }

    public function toChar() {
        switch (this.type) {
            case Rocky: return '.';
            case Wet: return '=';
            case Narrow: return '|';
        }
    }

}

enum RegionType {
    Rocky;
    Wet;
    Narrow;
}
