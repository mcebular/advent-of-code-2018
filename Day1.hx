class Day1 {
	static public function main():Void {
		var inputContent:String = sys.io.File.getContent('input/1');
		var lines = inputContent.split("\n");

		var n = 0, nf = 0, hasnf = false;

		var fr = new Map<Int, Int>(); 
		var frr = 0, hasFrr = false;
		
		while (!hasFrr) {
			for (line in lines) {
				// Skip zeros
				if (line.length < 2) {
					continue;
				}
				var p = line.charAt(0);
				var r = Std.parseInt(line.substr(1));

				if (p == "+") {
					n = n + r;
				} else {
					n = n - r;
				}

				// if n exists in map, we found second appearance
				if (fr.exists(n) && !hasFrr) {
					hasFrr = true;
					frr = n;
				}
				fr.set(n, 1);
			}

			// save n after one full iteration
			if (!hasnf) {
				hasnf = true;
				nf = n;
			}
		}

		trace(frr);
		trace(nf);
	}
}
