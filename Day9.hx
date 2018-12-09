class Day9 {

    static public function main() {
        
        var players = 455;
        var marbles = 71223 * 100;

        var circle = new MarbleCircle();
        // Float can store bigger numbers than an Int, hence the 0.0.
        var playerScores = [for (i in 0...players) 0.0];

        var currentMarble = 3;
        var currentPlayer = 2;
        while (currentMarble <= marbles) {

            if (currentMarble % 23 == 0) {
                var s = circle.remove();
                playerScores[currentPlayer%players] += (currentMarble + s);
            } else {
                circle.insert(currentMarble);
            }

            currentMarble++;
            currentPlayer++;
            // trace(circle);
        }

        var maxScore = -1.0;
        // trace(playerScores);
        for (ps in playerScores) {
            if (maxScore < ps) {
                maxScore = ps;
            }
        }
        trace(maxScore);

    }

}

class Marble {
    public var prev:Marble;
    public var next:Marble;
    public var value:Int;

    public function new(v:Int) {
        this.value = v;
        this.prev = this;
        this.next = this;
    }
}

class MarbleCircle {

    public var circle: Marble;

    public function new() {
        var c0 = new Marble(0);
        var c1 = new Marble(1);
        var c2 = new Marble(2);

        c0.prev = c1;
        c0.next = c2;
        c1.prev = c2;
        c1.next = c0;
        c2.prev = c0;
        c2.next = c1;

        circle = c2;
    }

    public function insert(value) {
        var c = new Marble(value);
        circle = circle.next;

        c.next = circle.next;
        c.prev = circle;

        circle.next.prev = c;
        circle.next = c;

        circle = c;
    }

    public function remove() {
        for (i in 0...7) {
            circle = circle.prev;
        }

        var value = circle.value;
        
        circle.prev.next = circle.next;
        circle.next.prev = circle.prev;
        circle = circle.next;
        
        return value;
    }

    public function toString() {
        var startingValue = circle.value;
        circle = circle.next;
        var str = startingValue + ",";
        while (circle.value != startingValue) {
            str += circle.value + ",";
            circle = circle.next;
        }
        return str;
    }

}