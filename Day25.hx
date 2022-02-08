using Lambda;
using StringTools;


class Day25 {

    static public function main() {
        var points: Array<Point> = sys.io.File.getContent("input/25")
            .split("\n")
            .map(line -> line.trim())
            .filter(line -> line.length > 0)
            .map(line -> Point.parse(line));

        var constellations = new Array<Array<Point>>();

        while (points.length > 0) {
            var prevPointsCount = points.length;

            var currentConstellation: Array<Point> = [points.shift()];
            constellations.push(currentConstellation);
            while (prevPointsCount != points.length) {
                prevPointsCount = points.length;

                // add points to current constellation as long as possible
                for (p in points) {
                    if (p.fitsConstellation(currentConstellation)) {
                        currentConstellation.push(p);
                        points.remove(p);
                    }
                }
            }
        }
        
        trace(constellations.length);
    }

}

class Point {
    final x: Int;
    final y: Int;
    final z: Int;
    final w: Int;

    public function new(x, y, z, w) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    public static function parse(str: String): Point {
        final pts: Array<Int> = str.split(",").map(p -> Std.parseInt(p));
        return new Point(pts[0], pts[1], pts[2], pts[3]);
    }

    public function distanceTo(other: Point): Int {
        return Math.floor(
            Math.abs(this.x - other.x) + 
            Math.abs(this.y - other.y) + 
            Math.abs(this.z - other.z) +
            Math.abs(this.w - other.w)
        );
    }

    public function fitsConstellation(constellation: Array<Point>): Bool {
        for (other in constellation) {
            if (this.distanceTo(other) <= 3) {
                return true;
            }
        }
        return false;
    }

    public function toString(): String {
        return '[$x,$y,$z,$w]';
    }

}
