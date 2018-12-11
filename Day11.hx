class Day11 {

    static public function main() {

        var serial = 6878;
        var n = 300;
        
        var fuelGrid = [for (i in 0...n) [for (j in 0...n) 0]];
        for (i in 0...n) {
            for (j in 0...n) {
                var x = i + 1;
                var y = j + 1;

                var rackId = x + 10;

                var powerLevel = ((rackId * y) + serial) * rackId;
                powerLevel = Std.int(powerLevel / 100) % 10;
                powerLevel -= 5;

                fuelGrid[i][j] = powerLevel;
            }
        }

        var max = 0;
        var gcx = 0;
        var gcy = 0;
        var gs = 0;

        // Tried to speed up algorithm by saving the accumulated sums and and adding only new
        // column and new row on every size iteration.
        var sumgrid = [for (i in 0...n) [for (j in 0...n) 0]];
        
        var tm = Sys.cpuTime();
        for (s in 0...n+1) {
            
            // Uncomment this for part 1
            // if (s > 3) break;

            trace(s, Sys.cpuTime() - tm);
            tm = Sys.cpuTime();

            for (i in 0...n) {
                if (i + s > n) continue;

                for (j in 0...n) {
                    if (j + s > n) continue;

                    var sm = 0;
                    for(h in 0...s-1) {
                        sm += fuelGrid[i+s-1][j+h];
                    }

                    for(k in 0...s) {
                        sm += fuelGrid[i+k][j+s-1];
                    }

                    sumgrid[i][j] += sm;

                    if (sumgrid[i][j] > max) {
                        max = sumgrid[i][j];
                        gcx = i;
                        gcy = j;
                        gs = s;
                    }

                }
            }

        }

        trace(gcx+1, gcy+1, gs);

    }

}