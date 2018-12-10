class Day10 {

    static public function main() {
        
        var inputContent:String = sys.io.File.getContent('input/10');
		var lines = inputContent.split("\n");

        var stars = new Array<Star>();
        for (line in lines) {
            var s = Star.fromString(line);
            stars.push(s);
        }
        // trace(stars);
        
        var stdin  = Sys.stdin();
        var skip = true;
        var seconds = 0;
        while (true) {
            var moment = 1;
            if (!skip) {
                Sys.println("Press <Enter> to move one step forward.");
                stdin.readLine();
            } 
            
            seconds += moment;
            
            var minpos = new Vector(null, null);
            var maxpos = new Vector(null, null);

            for (i in 0...stars.length) {

                stars[i].position.x += stars[i].velocity.x * moment;
                stars[i].position.y += stars[i].velocity.y * moment;

                var s = stars[i];
                if (minpos.x == null || s.position.x < minpos.x) minpos.x = s.position.x;
                if (minpos.y == null || s.position.y < minpos.y) minpos.y = s.position.y;
                if (maxpos.x == null || s.position.x > maxpos.x) maxpos.x = s.position.x;
                if (maxpos.y == null || s.position.y > maxpos.y) maxpos.y = s.position.y;
            }

            // trace(minpos, maxpos);
            var n = maxpos.x - minpos.x + 1;
            var m = maxpos.y - minpos.y + 1;

            var nm = n * m;
            // nm can be negative (overflow)!
            if (nm > 10000 || nm < 0) {
                // trace(seconds);
                continue;
            } else {
                skip = false;
            }
            Sys.println("");

            // trace(stars.length);
            // draw
            var grid = [for (i in 0...n) [for (j in 0...m) " "]];
            for (star in stars) {
                grid[star.position.x-minpos.x][star.position.y-minpos.y] = "x";
            }

            // output
            trace("seconds: " + seconds);
            for (j in 0...m) {
                for (i in 0...n) {
                    Sys.print(grid[i][j]);
                }
                Sys.println("");
            }
        }

    }

}

class Star {
    public var position:Vector;
    public var velocity:Vector;
    public function new(px, py, vx, vy) {
        this.position = new Vector(px, py);
        this.velocity = new Vector(vx, vy);
    }

    static public function fromString(str:String): Star {
        var t = str.split("<");
        var pstr = t[1].split(">")[0].split(",");
        var vstr = t[2].split(">")[0].split(",");

        return new Star(
            Std.parseInt(StringTools.trim(pstr[0])),
            Std.parseInt(StringTools.trim(pstr[1])),
            Std.parseInt(StringTools.trim(vstr[0])),
            Std.parseInt(StringTools.trim(vstr[1]))
        );
    }

    public function toString() {
        return 'Star{pos=$position vel=$velocity}';
    }
}

class Vector {
    public var x:Int;
    public var y:Int;
    public function new(x, y) {
        this.x = x;
        this.y = y;
    }

    public function toString() {
        return '[$x, $y]';
    }
}