class Day13 {

    static public function main() {

        var inputContent:String = sys.io.File.getContent('input/13');
		var lines = inputContent.split("\n");

        var chart = new Array<Array<Position>>();
        var carts = new Array<Cart>();

        var i = 0;
        for (line in lines) {
            var chl = new Array<Position>();
            for (j in 0...line.length) {
                chl.push(new Position(line.charAt(j)));

                switch(line.charAt(j)) {
                    case "v": carts.push(new Cart(j, i, Down));
                    case "^": carts.push(new Cart(j, i, Up));
                    case ">": carts.push(new Cart(j, i, Right));
                    case "<": carts.push(new Cart(j, i, Left));
                }

            }
            i++;
            chart.push(chl);
        }

        /*
        for (ch in chart) {
            for (c in ch) {
                Sys.print(c);
            }
            Sys.println("");
        }
        */
        
        trace(carts);

        var step = 0;
        var crash = false;
        var cx = -1;
        var cy = -1;
        while (!crash) {

            carts.sort(function(c1, c2) { return (c1.x + 99999*c1.y) - (c2.x + 99999*c2.y);});

            for (i in 0...carts.length) {
                var cart = carts[i];
                switch (cart.direction) {
                    case Up:
                        switch (chart[cart.y-1][cart.x].rotation) {
                            case DiagonalLeft: cart.direction = Left;
                            case DiagonalRight: cart.direction = Right;
                            case Intersection:
                                switch (cart.nextIntersection) {
                                    case 0: cart.direction = Left;
                                    case 1: cart.direction = Up;
                                    case 2: cart.direction = Right;
                                }
                                cart.nextIntersection = (cart.nextIntersection + 1) % 3;
                            default:
                        }
                        cart.y--;
                    case Down:
                        switch (chart[cart.y+1][cart.x].rotation) {
                            case DiagonalLeft: cart.direction = Right;
                            case DiagonalRight: cart.direction = Left;
                            case Intersection:
                                switch (cart.nextIntersection) {
                                    case 0: cart.direction = Right;
                                    case 1: cart.direction = Down;
                                    case 2: cart.direction = Left;
                                }
                                cart.nextIntersection = (cart.nextIntersection + 1) % 3;
                            default:
                        }
                        cart.y++;
                    case Left:
                        switch (chart[cart.y][cart.x-1].rotation) {
                            case DiagonalLeft: cart.direction = Up;
                            case DiagonalRight: cart.direction = Down;
                            case Intersection:
                                switch (cart.nextIntersection) {
                                    case 0: cart.direction = Down;
                                    case 1: cart.direction = Left;
                                    case 2: cart.direction = Up;
                                }
                                cart.nextIntersection = (cart.nextIntersection + 1) % 3;
                            default:
                        }
                        cart.x--;
                    case Right:
                        switch (chart[cart.y][cart.x+1].rotation) {
                            case DiagonalLeft: cart.direction = Down;
                            case DiagonalRight: cart.direction = Up;
                            case Intersection:
                                switch (cart.nextIntersection) {
                                    case 0: cart.direction = Up;
                                    case 1: cart.direction = Right;
                                    case 2: cart.direction = Down;
                                }
                                cart.nextIntersection = (cart.nextIntersection + 1) % 3;
                            default:
                        }
                        cart.x++;
                }

                // check for crashes
                for (j in 0...carts.length) {
                    if (i == j) continue;
                    var ct = carts[j];
                    if (cart.x == ct.x && cart.y == ct.y && !cart.crashed && !ct.crashed) {
                        // crash = true; // part 1
                        trace('crash at $cart!');
                        cart.crashed = true;
                        ct.crashed = true;
                        break;
                    }
                }

                // Haxe can do "functional programming", filter out all crashed carts.
                var uncrashed = Lambda.filter(carts, function(cart) {return !cart.crashed;});
                if (uncrashed.length <= 1) {
                    trace('cart remaining: $uncrashed');
                    crash = true; // part 2
                }

            }

            step++;
        }

    }

}

class Cart {
    public var x: Int;
    public var y: Int;
    public var direction: Direction;
    public var nextIntersection: Int; // 0 - left, 1 - straight, 2 - right
    public var crashed: Bool;

    public function new(x, y, dir) {
        this.x = x;
        this.y = y;
        this.direction = dir;
        this.nextIntersection = 0;
        this.crashed = false;
    }

    public function toString() {
        return '[$x $y]';
    }
}

class Position {
    public var rotation: Rotation;

    public function new(char: String) {
        switch (char) {
            case "v":
                this.rotation = Vertical;
            case "^":
                this.rotation = Vertical;
            case "|":
                this.rotation = Vertical;
            case ">":
                this.rotation = Horizontal;
            case "<":
                this.rotation = Horizontal;
            case "-":
                this.rotation = Horizontal;
            case "/":
                this.rotation = DiagonalRight;
            case "\\":
                this.rotation = DiagonalLeft;
            case "+":
                this.rotation = Intersection;
            default:
                this.rotation = Invalid;
        }
    }

    public function toString() {
        if (this.rotation == null) return "?";
        switch (this.rotation) {
            case Vertical:
                return "|";
            case Horizontal:
                return "-";
            case DiagonalLeft:
                return "\\";
            case DiagonalRight:
                return "/";
            case Intersection:
                return "+";
            default:
                return " ";
        }
    }
}

enum Direction {
    Up;
    Down;
    Left;
    Right;
}

enum Rotation {
  Vertical;
  Horizontal;
  DiagonalRight;
  DiagonalLeft;
  Invalid;
  Intersection;
}