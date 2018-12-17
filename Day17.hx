class Day17 {

    static public function main() {

        var inputContent:String = sys.io.File.getContent('input/17');
		var lines = inputContent.split("\n");

        var veins = new Array<Vein>();

        var minx = -1, miny = -1;
        var maxx = -1, maxy = -1;
        for (line in lines) {
            var t0 = line.split(",");
            var t00 = t0[0].split("=");
            var t01 = t0[1].split("=");
            var t011 = t01[1].split("..");

            var v = new Vein(StringTools.trim(t00[0]), Std.parseInt(t00[1]), Std.parseInt(t011[0]), Std.parseInt(t011[1]));
            veins.push(v);

            if(v.primaryAxis == "x") {
                if(minx < 0 || v.number < minx) minx = v.number;
                if(maxx < 0 || v.number > maxx) maxx = v.number;

                if(miny < 0 || v.rangeStart < miny) miny = v.rangeStart;
                if(maxy < 0 || v.rangeEnd > maxy) maxy = v.rangeEnd;
            } else {
                if(miny < 0 || v.number < miny) miny = v.number;
                if(maxy < 0 || v.number > maxy) maxy = v.number;

                if(minx < 0 || v.rangeStart < minx) minx = v.rangeStart;
                if(maxx < 0 || v.rangeEnd > maxx) maxx = v.rangeEnd;
            }

        }

        trace(minx, maxx, miny, maxy);
        // trace(veins);
        
        var ground = new Ground(minx-1, maxx+1, miny-1, maxy+1);
        trace(ground.ground.length, ground.ground[0].length);
        
        for (vein in veins) {
            if (vein.primaryAxis == "x") {
                for(i in vein.rangeStart...vein.rangeEnd+1) {
                    ground.set(vein.number, i, 5);
                }
            } else {
                for(i in vein.rangeStart...vein.rangeEnd+1) {
                    ground.set(i, vein.number, 5);
                }
            }
        }

        var posx = Std.int(ground.ground[0].length / 2) - 1;
        ground.ground[0][posx] = 9;
        
        // ground.printGround();
        ground.pour(new Point(posx, 1));
        // ground.printGround();

        trace(ground.waterReachable());
        trace(ground.waterRetained());
    }

}

class Ground {

    public var ground: Array<Array<Int>>;

    var minx: Int;
    var maxx: Int;
    var miny: Int;
    var maxy: Int;

    public function new(minx, maxx, miny, maxy) {
        this.minx = minx;
        this.maxx = maxx;
        this.miny = miny;
        this.maxy = maxy;
        this.ground = [ for(i in 0...maxy-miny+1) [for (j in 0...maxx-minx+1) 0 ] ];

    }

    public function set(x, y, n) {
        this.ground[y-miny][x-minx] = n;
    }
    
    public function printGround() {
        Sys.println("");
        for (gro in ground) {
            for (g in gro) {
                var pr = "";
                switch (g) {
                    case 0: pr = ".";
                    case 1: pr = "|";
                    case 5: pr = "#";
                    case 6: pr = "~";
                    case 9: pr = "+";
                }
                Sys.print(pr);
            }
            Sys.println("");
        }
    }

    public function waterReachable(): Int {
        var sum = 0;
        for (gro in ground) {
            for (g in gro) {
                if (g == 1 || g == 6) sum++;
            }
        }
        return sum;
    }

    public function waterRetained(): Int {
        var sum = 0;
        for (gro in ground) {
            for (g in gro) {
                if (g == 6) sum++;
            }
        }
        return sum;
    }

    public function pour(start: Point) {
        
        var waterPoints = new Array<Point>();
        waterPoints.push(start);
        while(waterPoints.length > 0) {
            var p = waterPoints.pop();
            var x = p.x;
            var y = p.y;
            
            // waterfall
            var overfall = false;
            while(ground[y+1][x] == 0) {
                this.ground[y][x] = 1;
                y++;
                if (y+1 > ground.length-1) {
                    overfall = true;
                    break;
                }
            }
            if (overfall) continue;

            // calculate bounds & grounds
            // bound - how far water can go left or right before bumping into clay
            // ground - how far water can go before falling down
            var leftBound = x;
            while(this.ground[y][leftBound] < 2) {
                leftBound--;
                if (leftBound < 0) {
                    leftBound = -1;
                    break;
                }
            }
            
            var rightBound = x;
            while(this.ground[y][rightBound] < 2) {
                rightBound++;
                if (rightBound > ground[0].length) {
                    rightBound = -1;
                    break;
                }
            }

            var leftGround = x;
            while(this.ground[y+1][leftGround] > 4) {
                leftGround--;
                if (leftGround < 0) {
                    leftGround = -1;
                    break;
                }
            }

            var rightGround = x;
            while(this.ground[y+1][rightGround] > 4) {
                rightGround++;
                if (rightGround > ground[0].length) {
                    rightGround = -1;
                    break;
                }
            }

            if (leftBound >= 0 && rightBound >= 0 && leftBound > leftGround && rightBound < rightGround) {
                for (i in 1...rightBound-leftBound) {
                    this.ground[y][i+leftBound] = 6;
                }
                waterPoints.push(new Point(x, y-1));
            } else {
                var ls: Int = Std.int(Math.max(leftBound+1, leftGround));
                var rs: Int = Std.int(Math.min(rightBound-1, rightGround));
                for (i in 0...rs-ls+1) {
                    this.ground[y][i+ls] = 1;
                }
                if (this.ground[y+1][ls] < 1) waterPoints.push(new Point(ls, y+1));
                if (this.ground[y+1][rs] < 1) waterPoints.push(new Point(rs, y+1));
            }

        }

    }

}

class Point {
    public var x: Int;
    public var y: Int;
    public function new(x, y) {
        this.x = x;
        this.y = y;
    }
}

class Vein {
    public var primaryAxis: String;
    public var number: Int;
    public var rangeStart: Int;
    public var rangeEnd: Int;
    public function new(pa, n, rs, re) {
        this.primaryAxis = pa;
        this.number = n;
        this.rangeStart = rs;
        this.rangeEnd = re;
    }
}