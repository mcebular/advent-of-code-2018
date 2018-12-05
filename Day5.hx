class Day5 {

    static public function main() {
        var inputContent:String = sys.io.File.getContent('input/5');
		var lines = inputContent.split("\n");

        var output = ""; // part 1
        var chars = new Map<Int, Int>();        
        for (c in new StringIterator(StringTools.rtrim(lines[0]))) {
            chars.set(c.toLowerCase().charCodeAt(0), c.toUpperCase().charCodeAt(0));

            if (output == "") {
                output += c;
                continue;
            }

            if (reacts(output.charAt(output.length-1), c)) {
                output = output.substr(0, output.length-1);
            } else {
                output += c;
            }
        }

        var shortest:String = null;
        for (k in chars.keys()) {
            var tmp = performCollapsing(StringTools.replace(StringTools.replace(lines[0], String.fromCharCode(k), ""), String.fromCharCode(chars.get(k)), ""));
            if (shortest == null || tmp.length < shortest.length) {
                shortest = tmp;
            }
        }

        trace(output.length);
        trace(shortest.length);
    }

    static function performCollapsing(s:String) {
        var output = "";
        for (c in new StringIterator(StringTools.rtrim(s))) {
            if (output == "") {
                output += c;
                continue;
            }

            if (reacts(output.charAt(output.length-1), c)) {
                output = output.substr(0, output.length-1);
            } else {
                output += c;
            }
        }
        return output;
    }

    static function reacts(c1:String, c2:String):Bool {
        //trace(c1, c2);
        if (c1.toLowerCase() == c2.toLowerCase() && c1.charCodeAt(0) != c2.charCodeAt(0)) {
            return true;
        } else {
            return false;
        }
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