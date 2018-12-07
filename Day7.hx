class Day7 {

    static public function main() {
        var inputContent:String = sys.io.File.getContent('input/7');
		var lines = inputContent.split("\n");

        var instr = new Map<String, Array<String>>();
        for (line in lines) {
            var req = line.charAt(5);
            var step = line.charAt(36);


            if (!instr.exists(step)) {
                instr.set(step, new Array<String>());
            }
            if (!instr.exists(req)) {
                instr.set(req, new Array<String>());
            }

            instr.get(step).push(req);
        }

        var steps = new Array<String>();
        while (instr.keys().hasNext()) {
            
            for (k in instr.keys()) {
                var reqs = instr.get(k).copy();

                if (reqs.length == 0) {
                    steps.push(k);
                    instr.remove(k);
                    continue;
                }

                for (i in 0...steps.length) {
                    if (reqs.indexOf(steps[i]) != -1) {
                        reqs.remove(steps[i]);
                    }
                    if (reqs.length == 0) {
                        instr.remove(k);
                        var j = i;
                        // if there are multiple free steps, do this step after steps that are
                        // done earlier (i.e. B before D)
                        while (steps[j+1] < k) {
                            j++;
                        }
                        steps.insert(j+1, k);
                        break;
                    }
                }
            }

        }
        trace(instr);
        var o = "";
        for (s in steps) {
            o += s;
        }
        trace(o);

        // part 2
        var instr = new Map<String, Array<String>>();
        var ttc = new Map<String, Int>();
        for (line in lines) {
            var req = line.charAt(5);
            var step = line.charAt(36);


            if (!instr.exists(step)) {
                instr.set(step, new Array<String>());
            }
            if (!instr.exists(req)) {
                instr.set(req, new Array<String>());
            }

            if (!ttc.exists(step)) {
                ttc.set(step, 60 + step.charCodeAt(0) - 65 + 1);
            }
            if (!ttc.exists(req)) {
                ttc.set(req, 60 + req.charCodeAt(0) - 65 + 1);
            }

            instr.get(step).push(req);
        }
        
        var workers = 5;

        var w = [for (i in 0...workers) null];
        var i = 0;
        while (ttc.keys().hasNext()) {

            for (k in instr.keys()) {

                var reqs = instr.get(k).copy();
                
                for (r in reqs.copy()) {
                    if (!instr.exists(r)) {
                        reqs.remove(r);
                    }
                }

                // assign workers to parts
                if (reqs.length == 0) {
                    for (v in 0...w.length) {
                        if (w[v] == null && w.indexOf(k) == -1) {
                            w[v] = k;
                        }
                    }   
                }

            }

            for (v in 0...w.length) {
                if(w[v] == null) {
                    continue;
                }

                // worker is working on it.
                ttc.set(w[v], ttc.get(w[v]) - 1);

                // if worker is done, set him to idle and remove part from ttc and instr
                if(ttc.get(w[v]) <= 0) {
                    ttc.remove(w[v]);
                    instr.remove(w[v]);
                    w[v] = null;
                }
            }

            i++;
        }

        trace(i);

    }

}