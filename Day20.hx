import haxe.Exception;

using StringTools;
using Lambda;

class Day20 {

    static public function main() {
        var inputContent:String = sys.io.File.getContent('input/20').trim();

        var grid = new Grid();
        var walkers: Array<GridWalker> = [new GridWalker(0, 0, 0, inputContent, grid)];
        grid.get(0, 0).distance = 0;

        while (walkers.length > 0) {
            // trace(walkers.length);
            var nextWalkers: Array<GridWalker> = [];
            for (walker in walkers) {
                nextWalkers = nextWalkers.concat(walker.walk());
            }
            walkers = nextWalkers;
        }

        var over1000count: Int = 0;
        var maxDistance: Int = grid.get(0, 0).distance;
        for (g in grid) {
            maxDistance = Util.max(maxDistance, g.distance);
            if (g.distance >= 1000) {
                over1000count++;
            }
        }
        trace(maxDistance, over1000count);
    }
}

class GridWalker {

    final x: Int;
    final y: Int;
    final distance: Int;

    final path: String;

    final grid: Grid;

    public function new(x: Int, y: Int, distance: Int, path: String, grid: Grid) {
        this.x = x;
        this.y = y;
        this.distance = distance;
        this.path = path;
        this.grid = grid;
    }

    public function walk(): Array<GridWalker> {
        var c = path.charAt(0);
        var nextPath = path.substr(1);

        if (c == "$" || path.length == 0) {
            return [];
        }

        if (c == "^") {
            return [new GridWalker(x, y, distance, nextPath, grid)];
        }

        if (["N", "E", "S", "W"].contains(c)) {
            grid.set(x, y, c);
            var nx = x;
            var ny = y;
            if (c == "N") ny++;
            if (c == "S") ny--;
            if (c == "E") nx++;
            if (c == "W") nx--;

            return [new GridWalker(nx, ny, distance + 1, nextPath, grid)];
        }

        if (c == "(") {
            // Create a new walker for each possible branch.
            var splitStartIndices: Array<Int> = [0];
            var splitEndIndex: Int = null;
            var bracketNesting = 0;
            var i = 0;
            while (true) {
                var ci = nextPath.charAt(i);
                if (ci == "(") {
                    bracketNesting++;
                }
                if (ci == ")") {
                    if (bracketNesting > 0) {
                        bracketNesting--;
                    } else {
                        splitEndIndex = i;
                        break;
                    }
                }
                if (bracketNesting > 0) {
                    i++;
                    continue;
                }

                if (ci == "|") {
                    splitStartIndices.push(i);
                }

                i++;
            }

            splitStartIndices.push(splitEndIndex);

            var nextWalkers = new Array<GridWalker>();
            var prevIndex = splitStartIndices[0];
            var first = true;
            for (currIndex in splitStartIndices.slice(1)) {
                var nextWalkerPath = nextPath.substring(prevIndex, currIndex);
                
                if (first) {
                    first = false;
                    // When splitting, one of the walkers will also walk the rest of the path, while others will end
                    // after meeting at the common point.
                    nextWalkerPath += nextPath.substr(splitEndIndex + 1);
                }

                var nextWalker = new GridWalker(x, y, distance + 1, nextWalkerPath, grid);
                nextWalkers.push(nextWalker);
                prevIndex = currIndex + 1;
            }

            return nextWalkers;
        }

        trace(path);
        throw new Exception("Walk call failed.");
    }

}

class GridNode {

    public final x: Int;
    public final y: Int;
    public var distance: Int;

    public var north: GridNode;
    public var east: GridNode;
    public var south: GridNode;
    public var west: GridNode;

    public function new(x: Int, y: Int) {
        this.x = x;
        this.y = y;
    }

    public function toString() {
        return 'Node[x=$x y=$y, n=${north != null} e=${east != null} s=${south != null} w=${west != null}]';
    }
}

class Grid {

    private var grid: Map<String, GridNode>;

    public function new() {
        this.grid = new Map();
    }

    public function get(x: Int, y: Int): GridNode {
        var key = x + "," + y;
        var node = this.grid.get(key);
        if (node == null) {
            node = new GridNode(x, y);
            grid.set(key, node);
        }
        return node;
    }

    public function exists(x: Int, y: Int): Bool {
        var key = x + "," + y;
        return this.grid.get(key) != null;
    }

    public function set(x: Int, y: Int, links: String) {
        var node = this.get(x, y);
        var nextDistance = node.distance + 1;

        for (i in 0...links.length) {
            var link = links.charAt(i);
            if (link == "N") {
                var northNode = this.get(x, y + 1);
                northNode.distance = Util.min(northNode.distance, nextDistance);
                node.north = northNode;
                northNode.south = node;
            }
            else if (link == "E") {
                var eastNode = this.get(x + 1, y);
                eastNode.distance = Util.min(eastNode.distance, nextDistance);
                node.east = eastNode;
                eastNode.west = node;
            }
            else if (link == "S") {
                var southNode = this.get(x, y - 1);
                southNode.distance = Util.min(southNode.distance, nextDistance);
                node.south = southNode;
                southNode.north = node;
            }
            else if (link == "W") {
                var westNode = this.get(x - 1, y);
                westNode.distance = Util.min(westNode.distance, nextDistance);
                node.west = westNode;
                westNode.east = node;
            }
            else {
                throw new Exception("Invalid link: " + link);
            }
        }
        
    }

    public function iterator(): Iterator<GridNode> {
        return this.grid.iterator();
    }

}

class Util {

    public static function min(a: Int, b: Int): Int {
        return a <= b ? a : b;
    }

    public static function max(a: Int, b: Int): Int {
        return a >= b ? a : b;
    }

}