class Day18 {

    static public function main() {

        var inputContent:String = sys.io.File.getContent('input/18');
		var lines = inputContent.split("\n");

        var area = new Array<Array<Int>>();

        for (line in lines) {
            var w = new Array<Int>();
            for (i in 0...line.length)  {
                var c = line.charAt(i);
                switch (c) {
                    case ".": w.push(0);
                    case "|": w.push(3);
                    case "#": w.push(6);
                }
            }
            area.push(w);
        }

        var time: Float = 0;
        var areaInitial: Array<Array<Int>> = null;
        while (time < 1000000000) {

            if(time == 1000) areaInitial = deepCopy(area);

            var areaCopy = deepCopy(area);

            for (i in 0...area.length) {
                for (j in 0...area[i].length) {
                    
                    var trees = adjacent(areaCopy, i, j, 3);
                    var lumberyards = adjacent(areaCopy, i, j, 6);

                    //trace(i, j, trees, lumberyards);
                    
                    if (areaCopy[i][j] == 0) {
                        if (trees >= 3) {
                            area[i][j] = 3;
                        }
                    }

                    if (areaCopy[i][j] == 3) {
                        if (lumberyards >= 3) {
                            area[i][j] = 6;
                        }
                    }

                    if (areaCopy[i][j] == 6) {
                        if (trees < 1 || lumberyards < 1) {
                            area[i][j] = 0;
                        }
                    }
                }
            }

            if (areaInitial != null) {
                if (compareArrays(area, areaInitial)) {
                    //trace("same as 1000 at " + time);
                    break;                    
                }
            }

            time++;
            /*
            for(ar in area) {
                for (a in ar) {
                    var c = "";
                    switch (a) {
                        case 0: c = ".";
                        case 3: c = "|";
                        case 6: c = "#";
                    }
                    Sys.print(c);
                }
                Sys.println("");
            }
            Sys.println("");
            */
        }

        var totalTrees = 0;
        var totalLumber = 0;
        for (ar in area) {
            for (a in ar) {
                if (a == 3) totalTrees++;
                if (a == 6) totalLumber++;
            }
        }

        trace(totalTrees, totalLumber, totalTrees * totalLumber);

    }

    static public function arrayGet(area: Array<Array<Int>>, i, j) {
        if (i >= 0 && i < area.length) {
            if (j >= 0 && j < area.length) {
                if(i == 9 && j ==8) trace(i, j, "hehexd");
                return area[i][j];
            }
        }
        return null;
    }

    static public function deepCopy(area: Array<Array<Int>>): Array<Array<Int>> {
        var n = [ for (i in 0...area.length) [ for (j in 0...area.length) area[i][j]]];
        return n;
    }

    static public function compareArrays(a1: Array<Array<Int>>, a2: Array<Array<Int>>): Bool {
        for (i in 0...a1.length) {
            for(j in 0...a2.length) {
                if (a1[i][j] != a2[i][j]) return false;
            }
        }
        return true;
    }

    static public function adjacent(area: Array<Array<Int>>, i: Int, j: Int, t: Int) {
        var count = 0;

        for(p in -1...2) {
            for (q in -1...2) {
                var a = i+p;
                var b = j+q;
                if ((a >= 0 && a < area.length) && (b >= 0 && b < area.length)) {
                    if (p == 0 && q == 0) continue;
                    if (area[a][b] == t) count++;
                }
            }
        }

        return count;
    }

}