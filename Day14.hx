class Day14 {

    static public function main() {

        var afterXrecipes = 430971; // part 1
        var recipeList = "430971"; // part 2

        // part 1
        var recipes = new RecipeList();
        while(recipes.length < afterXrecipes + 10) {
            recipes.combineRecipes();
        }

        trace(recipes.getRecipesAfter(afterXrecipes, 10));

        // part 2
        var gotem = false;
        var recipes = new RecipeList();
        while(!gotem) {
            recipes.combineRecipes();

            var ri = recipes.firstRecipe.prev;
            gotem = true;
            for (i in 0...recipeList.length) {
                if (ri.value != Std.parseInt(recipeList.charAt(recipeList.length-1-i))) {
                    gotem = false;
                    break;
                }
                ri = ri.prev;
            }

            if (gotem) {
                trace(recipes.length - recipeList.length);
            }

            if (!gotem) {
                // If upon combinating recipes two new are generated, we need to check for both
                // possibilities (i.e. from last recipe backward and from one-before-last recipe
                // backwards).
                // There's probably a better way to do checking for such case.
                var ri = recipes.firstRecipe.prev.prev;
                gotem = true;
                for (i in 0...recipeList.length) {
                    if (ri.value != Std.parseInt(recipeList.charAt(recipeList.length-1-i))) {
                        gotem = false;
                        break;
                    }
                    ri = ri.prev;
                }

                if (gotem) {
                    trace(recipes.length - recipeList.length - 1);
                }
            }

        }
        
    }

}

class Recipe {
    public var prev: Recipe;
    public var next: Recipe;
    public var value: Int;

    public function new(v: Int) {
        this.value = v;
        this.prev = this;
        this.next = this;
    }
}

class RecipeList {

    public var firstRecipe: Recipe;
    public var elf1: Recipe;
    public var elf2: Recipe;
    public var length: Float;

    public function new() {
        var r1 = new Recipe(3);
        var r2 = new Recipe(7);
        
        r1.prev = r2;
        r1.next = r2;
        r2.prev = r1;
        r2.next = r1;
        
        this.firstRecipe = r1;
        this.elf1 = r1;
        this.elf2 = r2;
        this.length = 2;

    }

    // adds a new recipe at the end
    public function addRecipe(value: Int) {
        var r = new Recipe(value);
        var i = firstRecipe.prev;

        r.next = i.next;
        r.prev = i;

        i.next.prev = r;
        i.next = r;

    }

    public function combineRecipes() {

        var newRecipeValue = (elf1.value + elf2.value) + "";

        for (i in 0...newRecipeValue.length) {
            this.addRecipe(Std.parseInt(newRecipeValue.charAt(i)));
            this.length++;
        }
        
        for(elf in 1...3) {
            var start: Recipe;
            if (elf == 1) {
                start = elf1;
            } else {
                start = elf2;
            }

            for (i in 0...start.value+1) {
                start = start.next;
            }

            if (elf == 1) {
                elf1 = start;
            } else {
                elf2 = start;
            }
        }
        
    }

    public function getRecipesAfter(startIndex: Int, amount: Int) {
        
        var i = firstRecipe;
        while (startIndex > 0) {
            i = i.next;
            startIndex--;
        }

        var start = i;
        var str = start.value + "";
        start = start.next;
        while (amount-1 > 0) {
            str += start.value;
            start = start.next;
            amount--;
        }
        return str;

    }

    public function toString() {
        var start = firstRecipe;
        var str = "[" + this.length + "] " + start.value + ",";
        start = start.next;
        while (start != firstRecipe) {
            str += start.value + ",";
            start = start.next;
        }
        return str;
    }

}