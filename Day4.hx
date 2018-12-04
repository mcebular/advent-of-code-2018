class Day4 {

    static public function main() {
        var inputContent:String = sys.io.File.getContent('input/4');
		var lines = inputContent.split("\n");

        // logs in chronological order
        var logs = new Array<GuardShift>();
        for (line in lines) {
            var a = GuardShift.fromString(line);

            if (logs.length == 0) {
                logs.push(a);
                continue;
            }

            var inserted = false;
            for (i in 0...logs.length) {
                if (a.getTimestamp() < logs[i].getTimestamp()) {
                    logs.insert(i, a);
                    inserted = true;
                    break;
                }
            }
            if (!inserted) logs.push(a);
        }

        // create schedule 2d array, a row for each (day, guardId) combination
        var schedule = new Map<Int, Map<String, Array<String>>>();
        var currentId = null;
        for (l in logs) {
            var t = l.month + "-" + l.day;

            switch (l.action) {
                case GuardId(id):
                    currentId = id;
                    
                case Sleeps:
                    if (l.hour != 0) {
                        l.minute = 0;
                    }

                    if (!schedule.exists(currentId)) {
                        schedule.set(currentId, new Map());
                    }
                    if(!schedule.get(currentId).exists(t)) {
                        // we assume that guards are awake by default
                        schedule.get(currentId).set(t, [for (i in 0...60) "."]);
                    }
                    for (i in l.minute...60) {
                        schedule.get(currentId).get(t)[i] = "#";
                    }
                    
                case Wakes:
                    if (l.hour != 0) {
                        l.minute = 0;
                    }

                    if (!schedule.exists(currentId)) {
                        schedule.set(currentId, new Map());
                    }
                    if(!schedule.get(currentId).exists(t)) {
                        schedule.get(currentId).set(t, [for (i in 0...60) "."]);
                    }
                    for (i in l.minute...60) {
                        schedule.get(currentId).get(t)[i] = ".";
                    }
            }
        }

        // find the sleepiest guard (part 1)
        var sleepyTime = new Map<Int, Int>();
        for(g in schedule.keys()) {
            var gm = schedule.get(g);
            for(h in gm.keys()) {
                var arr = schedule.get(g).get(h);
                // trace(h, g, arr);
                var tmp = 0;
                for (x in arr) {
                    if (x == "#") tmp++;
                }

                if (!sleepyTime.exists(g)) {
                    sleepyTime.set(g, 0);
                }

                sleepyTime.set(g, sleepyTime.get(g) + tmp);
            }
        }

        var slp = mapMax(sleepyTime);
        trace(slp.a, slp.b); // guard id, time asleep total

        // find a minute the sleepiest guard was most frequently asleep (part 1)
        var max = sleepyMinute(schedule, slp.a);
        // (minute index, minute value)
        

        trace(max.a + " * " + slp.a + " = " + (max.a * slp.a));

        // find the guard that was most frequently asleep (part 2)
        var maxFreqId = null;
        var maxFreqMinute = 0;
        var maxFreqMinuteAmnt = 0;
        for (g in schedule.keys()) {
            var gx = sleepyMinute(schedule, g);
            if (maxFreqId == null || maxFreqMinuteAmnt < gx.b) {
                maxFreqMinute = gx.a;
                maxFreqMinuteAmnt = gx.b;
                maxFreqId = g;
            }
        }

        trace(maxFreqId + " * " + maxFreqMinute + " = " + (maxFreqId * maxFreqMinute));
    }

    static function sleepyMinute(schedule:Map<Int, Map<String, Array<String>>>, guardId:Int) {
        var acc = [for (i in 0...60) 0];
        var schGuard = schedule.get(guardId);
        for(d in schGuard.keys()) {
            var arr = schGuard.get(d);
            for (i in 0...arr.length) {
                if (arr[i] == "#") {
                    acc[i] += 1;
                }
            }
        }

        var max = 0;
        var imax = 0;
        for (i in 0...acc.length) {
            if (max < acc[i]) {
                max = acc[i];
                imax = i;
            }
        }

        return new Tuple(imax, max);
    }

    static function mapMax(map:Map<Int, Int>) {
        var key = null;
        var value = 0;
        for(k in map.keys()) {
            var v = map.get(k);
            if(key == null || value < v) {
                key = k;
                value = v;
            }
        }

        return new Tuple(key, value);
    }

}

class Tuple {
    public var a:Dynamic;
    public var b:Dynamic;

    public function new(a, b) {
        this.a = a;
        this.b = b;
    }
}

class GuardShift {
    var year:Int;
    public var month:Int;
    public var day:Int;

    public var hour:Int;
    public var minute:Int;

    public var action:GuardAction;

    public function new(yr, mo, day, hr, min, act) {
        this.year = yr;
        this.month = mo;
        this.day = day;
        this.hour = hr;
        this.minute = min;

        this.action = act;
    }

    static public function fromString(s:String) {
        var year = Std.parseInt(s.substr(1, 4));
        var month = Std.parseInt(s.substr(6, 2));
        var day = Std.parseInt(s.substr(9, 2));
        var hour = Std.parseInt(s.substr(12, 2));
        var minute = Std.parseInt(s.substr(15, 2));

        var a = s.substr(19);
        var action = null;
        if (StringTools.startsWith(a, "wakes")) {
            action = Wakes;
        } else if(StringTools.startsWith(a, "falls")) {
            action = Sleeps;
        } else {
            action = GuardId(Std.parseInt( (a.split("#")[1]).split(" ")[0] ));
        }
        return new GuardShift(year, month, day, hour, minute, action);
    }

    public function toString() {
        var t = getTimestamp();
        return '$hour:$minute = $action';
    }

    public function getTimestamp() {
        // we take 1500 as a starting point anc crate a timestamp
        return (year-1500)*31557600 + month * 2629800 + day * 86400 + hour * 3600 + minute * 60;
    }
}

enum GuardAction {
  Sleeps;
  Wakes;
  GuardId(id:Int);
}