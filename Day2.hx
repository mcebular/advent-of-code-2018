class Day2 {

    static public function main():Void {
        var inputContent:String = sys.io.File.getContent('input/2');
		var lines = inputContent.split("\n");

        var twot = 0;
        var threet = 0;
        for (line in lines) {
            //var twot = new Map<String, Int>;
            //var threet = new Map<String, Int>;
            var chc = new Map<String, Int>();
            for (c in new StringIterator(line)) {
                if (chc.exists(c)) {
                    chc.set(c, chc.get(c) + 1);
                } else {
                    chc.set(c, 1);
                }
            }

            var isTwo = false, isThree = false;
            for (k in chc.keys()) {
                if (chc.get(k) == 2 && !isTwo) {
                    twot++;
                    isTwo = true;
                }
                if (chc.get(k) == 3 && !isThree) {
                    threet++;
                    isThree = true;
                }
            }

        }

        trace(twot * threet);

        var done = false;
        for (line1 in lines) {
            for (line2 in lines) {
                if (stringDiff(line1, line2) == 1) {
                    trace(line1);
                    trace(line2);
                    done = true;
                    break;
                }
            }
            if (done) { break; }
        }

    }

    static public function stringDiff(s1:String, s2:String):Int {
        var n = 0;
        for (i in 0...s1.length) {
            if (s1.charAt(i) != s2.charAt(i)) {
                n++;
            }
        }
        return n;
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