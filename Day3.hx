class Day3 {

    static public function main():Void {
        var inputContent:String = sys.io.File.getContent('input/3');
		var lines = inputContent.split("\n");

        // prepare the fabric
        var n = 1000;
        var fabric = [for (i in 0...n) [for (j in 0...n) 0]];
        
        // cut the fabric!
        var claims = new Array();
        for (line in lines) {
            if (line.charAt(0) != "#") {
                continue;
            }

            var h1 = line.split("@");
            var h2 = h1[1].split(":");
            var h3 = h2[0].split(",");
            var h4 = h2[1].split("x");

            var id = Std.parseInt(h1[0].substr(1));
            var x = Std.parseInt(h3[0]);
            var y = Std.parseInt(h3[1]);
            var w = Std.parseInt(h4[0]);
            var h = Std.parseInt(h4[1]);

            claims.push(new Claim(id, x, y, w, h));

            for (i in x...x+w) {
                for (j in y...y+h) {
                    fabric[i][j] += 1;
                }
            }
        }

        // count two or more claims
        var count = 0;
        for (i in 0...n) {
            for (j in 0...n) {
                if (fabric[i][j] > 1) {
                    count++;
                }
            }
        }

        // check each claim if it contains only ones
        var overlapless = null;
        for (c in claims) {
            var ok = true;
            for (i in c.x...c.x+c.width) {
                for (j in c.y...c.y+c.height) {
                    if (fabric[i][j] != 1) {
                        ok = false;
                    }
                    if(!ok) break;
                }
                if(!ok) break;
            }
            if(ok) {
                overlapless = c;
                break;
            }
        }

        trace(count);
        trace(overlapless);
    }
}

class Claim {
    public var id:Int;
    public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;

    public function new(id, x, y, w, h) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.width = w;
        this.height = h;
    }
}