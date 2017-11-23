module util::Visualize

import Set;
import List;
import Relation;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import ControlFlowGraph;

// Big thansk to Ingmelene Marlin for sharing this code
public Figure createVisualisation(CFG g) {
   edges = [edge("<from>", "<to>", toArrow(triangle(5, fillColor("black")))) | <int from, int to> <- g ];
   nodes = [drawNode(n) | n <- carrier(g)];
   return graph(nodes, edges, hint("layered"), gap(20));
}

Figure drawNode(int r) {
    return box(text("<r>"), vis::Figure::id("<r>"), gap(8));
}
