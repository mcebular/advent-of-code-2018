class Day8 {

    static public function main() {
        var inputContent:String = sys.io.File.getContent('input/8');
		var reads = inputContent.split(" ");

        var numbers = new Array<Int>();
        for (r in reads) {
            numbers.push(Std.parseInt(r));
        }

        var tree = buildTree(0, numbers);
        //trace(tree);

        var ms = metadataSum(tree, 0);
        trace(ms);

        var ms2 = metadataSum2(tree, 0);
        trace(ms2);

    }

    static public function buildTree(si, numbers) {
        var nc = numbers[si];
        var mc = numbers[si+1];

        var node = new Node();
        var nextIndex = si+2;
        for (i in 0...nc) {
            var nodes = buildTree(nextIndex, numbers);
            node.addNode(nodes);

            node.setSize(node.tsize + nodes.tsize);
            nextIndex += nodes.tsize;
        }

        node.tsize += 2;

        for (i in 0...mc) {
            node.metadata.push(numbers[si+node.tsize+i]);
        }
        node.tsize += mc;

        return node;
    }

    // part 1
    static public function metadataSum(tree:Node, sum:Int) {
        var s = sum;
        for (node in tree.children) {
            var r = metadataSum(node, 0);
            s += r;
        }

        for (m in tree.metadata) {
            s += m;
        }

        return s;
    }

    // part 2
    static public function metadataSum2(tree:Node, sum:Int) {
        var s = sum;

        if (tree.children.length == 0) {
            for (m in tree.metadata) {
                s += m;
            }
            return s;
        } else {
            for (m in tree.metadata) {
                if (m-1 < tree.children.length) {
                    var r = metadataSum2(tree.children[m-1], 0);
                    s += r;
                }
            }
            return s;
        }

    }

}

class Node {
    public var children: Array<Node>;
    public var metadata: Array<Int>;

    public var tsize: Int; // hmmm

    public function new() {
        this.children = new Array<Node>();
        this.metadata = new Array<Int>();
        this.tsize = 0;
    }

    public function addNode(n:Node) {
        this.children.push(n);
    }

    public function setSize(x) {
        this.tsize = x;
    }

    public function toString() {
        return '($tsize) $metadata $children';
    }
}