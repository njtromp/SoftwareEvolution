module CallAnalysis

import Set;
import Relation;
import analysis::graphs::Graph;

public alias Proc = str;

public rel[Proc, Proc] Calls = {
	<"a", "b">, <"b", "d">, <"b", "c">, <"d", "c">, 
	<"d", "e">, <"f", "g">, <"g", "e">, <"f", "e">
};

public alias Comp = str;

public rel[Comp, Comp] lift(rel[Proc, Proc] aCalls, rel[Proc, Comp] aPartOf){
	return { <C1, C2> | <Proc P1, Proc P2> <- aCalls, <Comp C1, Comp C2> <- aPartOf[P1] * aPartOf[P2]};
}

public rel[Proc, Proc] calls = {
	<"Main", "a">, <"Main", "b">,
	<"a", "b">, <"a", "c">, <"a", "d">,
	<"b", "d">
};

public rel[Proc, Comp] comps = {
	<"Main", "Appl">, <"a", "Appl">,
	<"b", "DB">,
	<"c", "Lib">,
	<"c", "Lib">
};