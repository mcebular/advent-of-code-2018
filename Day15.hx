import haxe.Exception;

using StringTools;
using Day15.AreaFunctions;
using Day15.UnitTest;


class Day15 {

    static public function main() {

        AreaTests.parseTests();

        AreaFunctions.hasAdjacentEnemyTests();
        AreaFunctions.distancesToEnemiesTests();
        AreaFunctions.findPositionTowardsEnemyTests();

        UnitFunctions.weakestUnitTests();

        var inputContent: String = sys.io.File.getContent("input/15");
        // var area = Area.parse(inputContent);
        // area.print();

        // part 1
        var part1 = combat(Area.parse(inputContent), 3);
        trace(part1);

        // part 2
        var elfCount = Area.parse(inputContent).getElves().length;
        var elfPower = 4;
        var part2: Int = null;
        while (true) {
            var area = Area.parse(inputContent, elfPower);
            part2 = combat(area, elfPower);
            if (area.getElves().length == elfCount) {
                break;
            }
            elfPower++;
        }
        trace(elfPower, part2);
    }

    static public function combat(area: Area, elfPower: Int) {
        // Let's start iterating for rounds!
        var gameOver = false;
        var roundsPlayed = 0;
        while (true) {
            // First, collect all units in their "reading order".
            var units = area.getUnits();
            // trace (units);

            for (unit in units) {
                if (unit.hp <= 0) {
                    // Unit is dead. Ignore it.
                    continue;
                }

                if (!UnitFunctions.hasAnyEnemies(unit, units)) {
                    gameOver = true;
                    break;
                }

                if (!AreaFunctions.hasAdjacentEnemy(area, unit.x, unit.y)) {
                    // MOVE: For each unit, find nearest enemy unit and related shortest path(s).
                    var distancesAndEnemies = AreaFunctions.distancesToEnemies(area, unit.x, unit.y);
                    // distancesAndEnemies.distances.print();
                    // trace(distancesAndEnemies.enemies);

                    if (distancesAndEnemies.enemies.length > 0) {
                        // MOVE: Of all the enemies, pick 1st in "reading order" (smallest Y, then smallest X).
                        var movingTowardsUnit: Unit = null;
                        for (enemy in distancesAndEnemies.enemies) {
                            if (movingTowardsUnit == null) {
                                movingTowardsUnit = enemy;
                                continue;
                            }
                            if (enemy.y < movingTowardsUnit.y) {
                                movingTowardsUnit = enemy;
                            } else if (enemy.y == movingTowardsUnit.y && enemy.x < movingTowardsUnit.x) {
                                movingTowardsUnit = enemy;
                            }
                        }

                        // MOVE: From distances 2d array, pick next move to make by backtracking from enemy -> unit.
                        var nextPosition = AreaFunctions.findPositionTowardsEnemy(distancesAndEnemies.distances, movingTowardsUnit);
                        // trace(nextPosition);
                        // distancesAndEnemies.distances.print();
                        AreaFunctions.moveUnit(area, unit, nextPosition);
                    }
                }

                // ATTACK: For each unit, check if it is adjacent to an enemy.
                if (AreaFunctions.hasAdjacentEnemy(area, unit.x, unit.y)) {
                    var enemies = AreaFunctions.adjacentEnemies(area, unit);
                    var weakestEnemy = UnitFunctions.weakestUnit(enemies);

                    // ATTACK: deal HP damage of unit's AP.
                    weakestEnemy.hp -= unit.ap;

                    // ATTACK: if unit died, clean it up.
                    if (weakestEnemy.hp <= 0) {
                        area.set(weakestEnemy.x, weakestEnemy.y, new Open(weakestEnemy.x, weakestEnemy.y));
                    }
                }
            }

            if (gameOver) {
                break;
            }

            roundsPlayed++;
            // Sys.println('Round ${roundsPlayed}:');
            // area.print();
        }

        var units = area.getUnits();
        var hpSum = 0;
        for (unit in units) {
            hpSum += unit.hp;
        }

        // trace(roundsPlayed, hpSum, roundsPlayed * hpSum);
        return roundsPlayed * hpSum;
    }

}

//
// Utility Unit functions
//

class UnitFunctions {

    //
    // hasAnyEnemies
    //

    public static function hasAnyEnemies(unit: Unit, units: Array<Unit>): Bool {
        for(other in units) {
            if (other.hp <= 0) continue;
            if (unit.isEnemy(other)) return true;
        }
        return false;
    }

    //
    // weakestUnit
    //

    public static function weakestUnit(units: Array<Unit>): Unit {
        if (units.length == 0) {
            return null;
        }
        units = units.copy();
        units.sort((a: Unit, b: Unit) -> {
            var hpDiff = a.hp - b.hp;
            if (hpDiff != 0) {
                return hpDiff;
            }

            var yDiff = a.y - b.y;
            if (yDiff != 0) {
                return yDiff;
            }

            return a.x - b.x;
        });
        return units[0];
    }

    public static function weakestUnitTests() {
        var a = new Elf(1, 1); a.hp = 10;
        var b = new Elf(1, 1); b.hp = 20;
        var c = new Elf(1, 1); c.hp = 30;
        var d = new Elf(1, 1); d.hp = 40;
        var e = new Elf(1, 1); e.hp = 50;

        UnitTest.assert(weakestUnit([a, b, c]), a);
        UnitTest.assert(weakestUnit([c, d, e]), c);
        UnitTest.assert(weakestUnit([d, b, c]), b);
        UnitTest.assert(weakestUnit([a, e, d]), a);

        // .A.
        // .XB
        var a = new Elf(1, 0);
        var b = new Elf(2, 1);
        UnitTest.assert(weakestUnit([a, b]), a);

        // .XA
        // .B.
        var a = new Elf(2, 0);
        var b = new Elf(1, 1);
        UnitTest.assert(weakestUnit([a, b]), a);

        // BX.
        // .A.
        var a = new Elf(1, 1);
        var b = new Elf(0, 0);
        UnitTest.assert(weakestUnit([a, b]), b);

        // .B.
        // AX.
        var a = new Elf(0, 1);
        var b = new Elf(1, 0);
        UnitTest.assert(weakestUnit([a, b]), b);
    }

}

//
// Utility Area functions
//

class AreaFunctions {

    //
    // moveUnit
    //

    static public function moveUnit(area: Area, unit: Unit, position: Position) {
        // First, make sure we are only moving by one square.
        if (!position.isAdjacent(new Position(unit.x, unit.y))) {
            throw new Exception('Invalid move: From ${new Position(unit.x, unit.y)} to ${position}.');
        }
        // Then, make sure the target position is open.
        if (!area.get(position.x, position.y).isOpen()) {
            throw new Exception('Invalid move: Position ${position} is occupied by ${area.get(position.x, position.y)}.');
        }

        area.set(unit.x, unit.y, new Open(unit.x, unit.y));
        area.set(position.x, position.y, unit);
        unit.x = position.x;
        unit.y = position.y;
    }

    //
    // findPositionTowardsEnemy
    //

    static public function findPositionTowardsEnemy(distances: IntArea, enemy: Unit): Position {
        if (distances.get(enemy.x, enemy.y) == null) {
            throw new Exception("Enemy position has no distance to.");
        }
        var pos = new Position(enemy.x, enemy.y);
        var dis = distances.get(pos.x, pos.y);

        while (dis > 1) {
            var hasAdj = false;
            for (adj in pos.adjacent(distances.width - 1, distances.height - 1)) {
                var nextDis = distances.get(adj.x, adj.y);
                if (nextDis == dis - 1) {
                    pos = adj;
                    dis = nextDis;
                    hasAdj = true;
                    break;
                }
            }
            if (!hasAdj) throw new Exception("No fitting adjacent position in distances.");
        }

        return pos;
    }

    static public function findPositionTowardsEnemyTests() {
        //.12
        //.01
        var p = findPositionTowardsEnemy(new IntArea([null,1,2,null,0,1], 3), new Goblin(2, 0));
        UnitTest.assert(p.x, 1);
        UnitTest.assert(p.y, 0);

        //.01
        //.12
        var p = findPositionTowardsEnemy(new IntArea([null,0,1,null,1,2], 3), new Goblin(2, 1));
        UnitTest.assert(p.x, 2);
        UnitTest.assert(p.y, 0);

        //10.
        //21.
        var p = findPositionTowardsEnemy(new IntArea([1,0,null,2,1,null], 3), new Goblin(0, 1));
        UnitTest.assert(p.x, 0);
        UnitTest.assert(p.y, 0);

        //21.
        //10.
        var p = findPositionTowardsEnemy(new IntArea([2,1,null,1,0,null], 3), new Goblin(0, 0));
        UnitTest.assert(p.x, 1);
        UnitTest.assert(p.y, 0);

        //0.4
        //123
        var p = findPositionTowardsEnemy(new IntArea([0, null, 4, 1, 2, 3], 3), new Elf(2, 0));
        UnitTest.assert(p.x, 0);
        UnitTest.assert(p.y, 1);
    }

    //
    // distancesToEnemies
    //

    static public function distancesToEnemies(area: Area, x, y: Int): {
        distances: IntArea,
        enemies: Array<Unit>
    } {
        var unit: Unit = cast(area.get(x, y), Unit);
        var distances = IntArea.init(area.width, area.height, null);
        
        // start from the [x, y] and calculate distance for the whole area... or at least until the nearest enemy.
        var frontier = new Array<Position>();
        frontier.push(new Position(x, y));
        distances.set(x, y, 0);

        var nearestEnemyDistance: Int = null;
        var nearestEnemies = new Array<Unit>();

        while (frontier.length > 0) {
            var current = frontier.shift();
            var currentEntity = area.get(current.x, current.y);
            var currentDistance = distances.get(current.x, current.y);

            if (nearestEnemyDistance != null && currentDistance >= nearestEnemyDistance) {
                break;
            }

            var neighbours = [
                new Position(current.x-1, current.y),
                new Position(current.x+1, current.y),
                new Position(current.x, current.y-1),
                new Position(current.x, current.y+1),
            ];
            for (next in neighbours) {
                if (next.x < 0 || next.x >= area.width || next.y < 0 || next.y >= area.height) {
                    continue;
                }

                var nextEntity = area.get(next.x, next.y);
                if (distances.get(next.x, next.y) == null && (nextEntity.isOpen() || nextEntity.isUnit())) {
                    var nextDistance = 1 + distances.get(current.x, current.y);

                    if (nextEntity.isOpen() || unit.isEnemy(cast(nextEntity, Unit))) {
                        distances.set(next.x, next.y, nextDistance);
                    }

                    if (nextEntity.isUnit() && unit.isEnemy(cast(nextEntity))) {
                        if (nearestEnemyDistance == null) {
                            nearestEnemyDistance = nextDistance;
                        }
                        if (nextDistance == nearestEnemyDistance) {
                            nearestEnemies.push(cast(nextEntity, Unit));
                        }
                    }
                    if (nextEntity.isOpen()) {
                        frontier.push(next);
                    }
                }
            }
        }

        return { distances: distances, enemies: nearestEnemies };
    }

    static public function distancesToEnemiesTests() {
        UnitTest.assertThrows(() -> distancesToEnemies(Area.parse("...\n...\n..."), 1, 1));
        UnitTest.assertThrows(() -> distancesToEnemies(Area.parse("...\n.#.\n..."), 1, 1));

        var s1 = distancesToEnemies(Area.parse("...\n.E.\n..."), 1, 1);
        UnitTest.assertArrayEquals(s1.distances.array(), [2, 1, 2, 1, 0, 1, 2, 1, 2]);
        UnitTest.assert(s1.enemies.length, 0);

        var s2 = distancesToEnemies(Area.parse("G..\n...\n..."), 0, 0);
        UnitTest.assertArrayEquals(s2.distances.array(), [0, 1, 2, 1, 2, 3, 2, 3, 4]);
        UnitTest.assert(s2.enemies.length, 0);

        //G.
        //..
        //.E
        var s3 = distancesToEnemies(Area.parse("G.\n..\n.E"), 0, 0);
        UnitTest.assertArrayEquals(s3.distances.array(), [0, 1, 1, 2, 2, 3]);
        UnitTest.assert(s3.enemies.length, 1);
        UnitTest.assert(s3.enemies[0].x, 1);
        UnitTest.assert(s3.enemies[0].y, 2);

        //G.G
        //.E.
        //.G.
        var s4 = distancesToEnemies(Area.parse("G.G\n.E.\n.G."), 1, 1);
        UnitTest.assertArrayEquals(s4.distances.array(), [null, 1, null, 1, 0, 1, null, 1, null]);
        UnitTest.assert(s4.enemies.length, 1);

        //G.G
        //EE.
        //G.E
        var s5 = distancesToEnemies(Area.parse("G.G\nEE.\nG.E"), 1, 1);
        UnitTest.assertArrayEquals(s5.distances.array(), [2, 1, 2, null, 0, 1, 2, 1, null]);
        UnitTest.assert(s5.enemies.length, 3);

        //GG.E.
        //.....
        //....E
        var s6 = distancesToEnemies(Area.parse("GG.E.\n.....\n....E"), 0, 0);
        UnitTest.assertArrayEquals(s6.distances.array(), [0, null, 4, 5, null, 1, 2, 3, 4, 5, 2, 3, 4, 5, null]);
        UnitTest.assert(s6.enemies.length, 1);
        UnitTest.assert(s6.enemies[0].x, 3);
        UnitTest.assert(s6.enemies[0].y, 0);


        var sX = distancesToEnemies(Area.parse("#######\n#E..G.#\n#...#.#\n#.G.#G#\n#######"), 1, 1);
        UnitTest.assertArrayEquals(sX.distances.array(), [
            null, null, null, null, null, null, null,
            null, 0, 1, 2, 3, null, null,
            null, 1, 2, 3, null, null, null,
            null, 2, 3, null, null, null, null,
            null, null, null, null, null, null, null,
        ]);
        UnitTest.assert(sX.enemies.length, 2);
        UnitTest.assert(sX.enemies[0].x, 4);
        UnitTest.assert(sX.enemies[0].y, 1);
        UnitTest.assert(sX.enemies[1].x, 2);
        UnitTest.assert(sX.enemies[1].y, 3);
    }

    //
    // hasAdjacentEnemy
    //

    static public function hasAdjacentEnemy(area: Area, x: Int, y: Int) {
        return adjacentEnemies(area, cast(area.get(x, y), Unit)).length > 0;
    }

    static public function hasAdjacentEnemyTests() {
        UnitTest.assertFalse(hasAdjacentEnemy(Area.parse("...\n.E.\n..."), 1, 1));
        UnitTest.assertFalse(hasAdjacentEnemy(Area.parse("G.G\n.E.\nG.G"), 1, 1));
        UnitTest.assertFalse(hasAdjacentEnemy(Area.parse(".E.\n.E.\n..."), 1, 1));
        UnitTest.assertFalse(hasAdjacentEnemy(Area.parse(".G.\n.G.\n..."), 1, 0));
        UnitTest.assertFalse(hasAdjacentEnemy(Area.parse("EEE\n...\nGGG"), 1, 0));

        UnitTest.assertThrows(() -> hasAdjacentEnemy(Area.parse("EEE\n...\nGGG"), 1, 1));
        UnitTest.assertThrows(() -> hasAdjacentEnemy(Area.parse("EEE\n.#.\nGGG"), 1, 1));

        UnitTest.assertTrue(hasAdjacentEnemy(Area.parse("EG.\n...\n..."), 0, 0));
        UnitTest.assertTrue(hasAdjacentEnemy(Area.parse("...\n..G\n..E"), 2, 2));
        UnitTest.assertTrue(hasAdjacentEnemy(Area.parse(".G.\n.E.\n..."), 1, 1));
        UnitTest.assertTrue(hasAdjacentEnemy(Area.parse("...\nGE.\n..."), 1, 1));
        UnitTest.assertTrue(hasAdjacentEnemy(Area.parse("...\n.EG\n..."), 1, 1));
        UnitTest.assertTrue(hasAdjacentEnemy(Area.parse("...\n.E.\n.G."), 1, 1));
        UnitTest.assertTrue(hasAdjacentEnemy(Area.parse(".E.\n.G.\n.E."), 1, 1));
    }

    //
    // adjacentEnemies
    //

    static public function adjacentEnemies(area: Area, unit: Unit) {
        var result = new Array<Unit>();
        for (adj in new Position(unit.x, unit.y).adjacent(area.width - 1, area.height - 1)) {
            var other = area.get(adj.x, adj.y);
            if (other.isUnit() && unit.isEnemy(cast(other, Unit))) {
                result.push(cast(other, Unit));
            }
        }
        return result;
    }

}

//
// Position class
//

class Position {

    public final x: Int;
    public final y: Int;

    public function new(x: Int, y: Int) {
        this.x = x;
        this.y = y;
    }

    public function adjacent(boundX: Int, boundY: Int): Array<Position> {
        var adjs = new Array<Position>();
        if (this.y > 0)                        adjs.push(new Position(this.x, this.y-1)); // up
        if (this.x > 0)                        adjs.push(new Position(this.x-1, this.y)); // left
        if (boundX == null || this.x < boundX) adjs.push(new Position(this.x+1, this.y)); // right
        if (boundY == null || this.y < boundY) adjs.push(new Position(this.x, this.y+1)); // down
        return adjs;
    }

    public function isAdjacent(other: Position): Bool {
        for(adj in this.adjacent(null, null)) {
            if (adj.x == other.x && adj.y == other.y) {
                return true;
            }
        }
        return false;
    }

    public function toString(): String {
        return '[x=$x, y=$y]';
    }

}

//
// Entity classes
//

class Entity {

    public var x: Int;
    public var y: Int;

    public function new(x: Int, y: Int) { 
        this.x = x;
        this.y = y;
    }

    public function toChar(): String {
        return "?";
    }

    public function toString(): String {
        return 'x=$x,y=$y';
    }

    public function clone(): Entity {
        return new Entity(this.x, this.y);
    }

    public function isUnit(): Bool {
        throw new Exception("");
    }

    public function isOpen(): Bool {
        throw new Exception("");
    }

}

class Wall extends Entity {

    override public function toChar() {
        return "#";
    }

    override public function isUnit(): Bool {
        return false;
    }

    override public function isOpen(): Bool {
        return false;
    }

    override public function toString(): String {
        return 'Wall<${super.toString()}>';
    }

}

class Open  extends Entity{

    override public function toChar() {
        return ".";
    }

    override public function isUnit(): Bool {
        return false;
    }

    override public function isOpen(): Bool {
        return true;
    }

    override public function toString(): String {
        return 'Open<${super.toString()}>';
    }

}

class Unit extends Entity {

    public var hp: Int;
    public var ap: Int;

    public function new(x: Int, y: Int) {
        super(x, y);
        this.hp = 200;
        this.ap = 3;
    }

    public function isEnemy(other: Unit) {
        return this.toChar() != other.toChar();
    }

    override public function isUnit(): Bool {
        return true;
    }

    override public function isOpen(): Bool {
        return false;
    }

    override public function toString(): String {
        return '${super.toString()},HP=$hp,AP=$ap';
    }
    
}

class Goblin extends Unit {

    override public function toChar() {
        return "G";
    }

    override public function toString(): String {
        return 'Goblin<${super.toString()}>';
    }

}

class Elf extends Unit {

    public function new (x: Int, y: Int, ?ap: Int = 3) {
        super(x, y);
        this.ap = ap;
    }

    override public function toChar() {
        return "E";
    }

    override public function toString(): String {
        return 'Elf<${super.toString()}>';
    }

}

//
// Area class (Array2D of entities)
//

class Area extends Array2D<Entity> {

    public static function parse(input: String, ?elfPower: Int = 3): Area {
        var result = new Array<Entity>();
        var width = null;

        var lines = input.split("\n");
        for (y in 0...lines.length) {
            var line = lines[y].trim();
            if (width == null) width = line.length;
            for (x in 0...line.length) {
                var c = line.charAt(x);
                switch(c) {
                    case "#": result.push(new Wall(x, y));
                    case ".": result.push(new Open(x, y));
                    case "G": result.push(new Goblin(x, y));
                    case "E": result.push(new Elf(x, y, elfPower));
                }
            }
        }
        return new Area(result, width);
    }

    public function getUnits(): Array<Unit> {
        var units = new Array<Unit>();
        for (e in arr) {
            if (e.isUnit()) {
                units.push(cast(e, Unit));
            }
        }
        return units;
    }

    public function getElves(): Array<Elf> {
        var units = new Array<Elf>();
        for (e in arr) {
            if (e.isUnit() && e.toChar() == "E") {
                units.push(cast(e, Elf));
            }
        }
        return units;
    }

    public function print() {
        for (i in 0...arr.length) {
            Sys.print(arr[i].toChar());
            if (i % width == width - 1) {
                Sys.print("\n");
            }
        }
        Sys.print("\n");
    }

    public function toString(): String {
        var result = "";
        for (i in 0...arr.length) {
            result += arr[i];
            if (i % width == width - 1) {
                result += "\n";
            }
        }
        return result;
    }

}

class AreaTests {

    public static function parseTests() {
        var a = Area.parse("...\n.E.\n.GG");
        UnitTest.assert(a.width, 3);
        UnitTest.assert(a.height, 3);
        UnitTest.assertTrue(a.get(0, 0).isOpen());
        UnitTest.assertTrue(a.get(1, 1).toChar() == "E");
        UnitTest.assertTrue(a.get(1, 2).toChar() == "G");
        UnitTest.assertTrue(a.get(2, 2).toChar() == "G");
        UnitTest.assertTrue(a.get(0, 2).x == 0);
        UnitTest.assertTrue(a.get(0, 2).y == 2);
        UnitTest.assertTrue(a.get(1, 2).x == 1);
        UnitTest.assertTrue(a.get(1, 2).y == 2);
        UnitTest.assertTrue(a.get(2, 2).x == 2);
        UnitTest.assertTrue(a.get(2, 2).y == 2);

        var b = Area.parse(".....\n.E...");
        UnitTest.assert(b.width, 5);
        UnitTest.assert(b.height, 2);
    }

}

//
// IntArea class (Array2D of Ints)
//

class IntArea extends Array2D<Int> {

    public function new(arr: Array<Int>, width: Int) {
        super(arr, width);
    }

    public static function init(width: Int, height: Int, value: Int): IntArea {
        return new IntArea([for (i in 0...(width * height)) null], width);
    }

    public function print() {
        for (i in 0...arr.length) {
            var a = arr[i];
            if (a > 9) { Sys.print("+"); }
            else if (a < 0) { Sys.print("-"); }
            else if (a == null) { Sys.print("_"); }
            else { Sys.print(a); }
            if (i % width == width - 1) {
                Sys.print("\n");
            }
        }
        Sys.print("\n");
    }

}

//
// Array2D class
//

class Array2D<T> {

    private var arr: Array<T>;
    public final width: Int;
    public final height: Int;

    public function new(arr, width) {
        this.arr = arr;
        this.width = width;
        this.height = Math.floor(arr.length / width);
    }

    public function array(): Array<T> {
        return arr;
    }

    public function get(x: Int, y: Int): T {
        return arr[y * width + x];
    }

    public function set(x: Int, y: Int, v: T) {
        arr[y * width + x] = v;
    }

    public function iterator(): Iterator<T> {
        return arr.iterator();
    }

}

//
// Unit testing functions
//

class UnitTest {

    public static function assertThrows(func: () -> Void) {
        var hasException = false;
        try {
            func();
        } catch (e: Exception) {
            hasException = true;
        }
        if (!hasException) {
            throw new Exception('Assertion failed: expected to catch exception, but nothing was thrown.');
        }
    }

    public static function assertTrue(val: Bool) {
        assert(val, true);
    }

    public static function assertFalse(val: Bool) {
        assert(val, false);
    }

    public static function assertArrayEquals(a: Array<Int>, b: Array<Int>) {
        assert(a.length, b.length);
        for(i in 0...a.length) {
            assert(a[i], b[i]);
        }
    }

    public static function assert<T>(a, b: T) {
        if (a != b) {
            throw new Exception('Assertion failed: ${a} is not equal to ${b}.');
        }
    }

}