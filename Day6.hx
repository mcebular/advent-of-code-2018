class Day6 {

    static public function main() {
        var inputContent:String = sys.io.File.getContent('input/6');
		var lines = inputContent.split("\n");

        var coords = new Array<Coordinate>();
        var tl = new Coordinate(0, 999, 999);
        var br = new Coordinate(0, 0, 0);
        for (i in 0...lines.length) {
            var t = lines[i].split(",");
            var c = new Coordinate(i+1, Std.parseInt(t[0]), Std.parseInt(t[1]));

            if(c.x >= br.x && c.y >= br.y) {
                br = c;
            }
            if(c.x <= tl.x && c.y <= tl.y) {
                tl = c;
            }

            coords.push(c);
        }

        var grid = [for (i in tl.y-1...tl.y+br.y) [for (j in tl.x-1...tl.x+br.x) 0]];
        /*
        for (c in coords) {
            trace(c.x, c.y);
            grid[c.x-tl.x][c.y-tl.y] = c.t;
        }
        */
        
        for (i in 0...grid.length) {
            for (j in 0...grid[i].length) {
                var closests = new Map<Int, Int>();
                for (c in coords) {
                    var d = manhattan(new Coordinate(0, tl.x-1+i, tl.y-1+j), c);
                    closests.set(c.t, d);
                }
                var m = mapMinVal(closests);
                if (m == null) {
                    grid[i][j] = 0;
                } else {
                    grid[i][j] = m;
                }
            }
        }
        
        // calculate sizes. if on border, size is invalid
        var sizes = new Map<Int, Int>();
        for (i in 0...grid.length) {
            for (j in 0...grid[i].length) {
                var k = grid[i][j];
                if (k == 0) {
                    continue;
                }
                if (i == 0 || i == grid.length-1) {
                    sizes.set(k, -1);
                    continue;
                }
                if(j == 0 || j == grid[i].length-1) {
                    sizes.set(k, -1);
                    continue;
                }

                if (!sizes.exists(k)) {
                    sizes.set(k, 1);
                } else {
                    if (sizes.get(k) != -1) {
                        sizes.set(k, sizes.get(k)+1);
                    }
                }
            }
        }

        var maxd = null;
        var maxt = null;
        for (k in sizes.keys()) {
            if (maxd == null || sizes.get(k) > maxd) {
                maxd = sizes.get(k);
                maxt = k;
            }
        }

        //trace(sizes);
        trace(maxt + ", d=" + maxd);
        
        // part 2
        var gs = 0;
        for (i in 0...grid.length) {
            for (j in 0...grid[i].length) {
                var ms = 0;
                for (c in coords) {
                    var d = manhattan(new Coordinate(0, tl.x-1+i, tl.y-1+j), c);
                    ms += d;
                }
                if (ms < 10000) {
                    gs += 1;
                }
            }
        }

        trace(gs);
    }

    // returns name or null if multiple mins found
    static public function mapMinVal(map:Map<Int, Int>) {
        var mind = null;
        var mint = null;
        for (k in map.keys()) {
            if (mind == null || map.get(k) < mind) {
                mind = map.get(k);
                mint = k;
            }
        }
        var multiple = 0;
        for (k in map.keys()) {
            var val = map.get(k);
            if (mind == val) {
                multiple++;
            }
            if (multiple >= 2) {
                mint = null;
                break;
            }
        }

        return mint;
    } 

    static public function manhattan(p:Coordinate, q:Coordinate) {
        return Std.int(Math.abs(p.x - q.x) + Math.abs(p.y - q.y));
    }
}

class Coordinate {
    public var t:Int; // name
    public var x:Int;
    public var y:Int;

    public function new(t, x, y) {
        this.t = t;
        this.x = x;
        this.y = y;
    }

    public function toString() {
        return '$t[$x $y]';
    }
}

class StringIterator {
    var s:String;
    var i:Int;

    public function new(s:String) {
        this.s = s;
        this.i = 0;
    }

    public function hasNext() {
        return i < s.length;
    }

    public function next() {
        var c = s.charAt(i);
        i += 1;
        return c;
    }
}