module ControlFlowGraph

import lang::java::jdt::m3::AST;
import analysis::graphs::Graph;
import DebugPrint;

public alias GraphInfo = tuple[int top, int bottom, int last, Graph[int] graph];

public GraphInfo insertShortcut(GraphInfo info) {
	Graph[int] g = info.graph;
	// Remove inner connection
	g -= <info.top, info.bottom>;
	// Replace with new connections
	g += <info.top, info.last+1>;
	g += <info.last+1, info.last+2>;
	g += <info.last+2, info.last+3>;
	g += <info.last+3, info.last+4>;
	g += <info.last+4, info.bottom>;
	// Create shortcut flow
	g += <info.last+1, info.last+4>;
	// Continue at new inserted connection
	return <info.last+2, info.last+3, info.last+4, g>;
}

public GraphInfo insertChoice(GraphInfo info) {
	Graph[int] g = info.graph;
	// Remove inner connection
	g -= <info.top, info.bottom>;
	// Replace with new connections on the left hand side
	g += <info.top, info.last+1>;
	g += <info.last+1, info.last+2>;
	g += <info.last+2, info.last+3>;
	g += <info.last+3, info.last+4>;
	g += <info.last+4, info.bottom>;
	// Replace with new connections on the right hand side
	g += <info.last+1, info.last+5>;
	g += <info.last+5, info.last+6>;
	g += <info.last+6, info.last+4>;
	// Continue at new inserted connection on the left hand side
	return <info.last+2, info.last+3, info.last+6, g>;
}

public GraphInfo makeGraph(GraphInfo info, \block(stmts)) {
	for (stmt <- stmts) {
		info = makeGraph(info, stmt);
	}
	return info;
}

public GraphInfo makeGraph(GraphInfo info, \if(_, ifBlock)) {
	dprintln("If");
	return makeGraph(insertShortcut(info), ifBlock);
}

public GraphInfo makeGraph(GraphInfo info, \if(_, ifBlock, elseBlock)) {
	dprintln("If-Else");
	partialGraph = makeGraph(insertChoice(info), ifBlock);
	return makeGraph(<info.last+5, info.last+6, partialGraph.last, partialGraph.graph>, elseBlock);
}

public GraphInfo makeGraph(GraphInfo info, \switch(_, cases)) {
	dprintln("Switch");
	return makeGraph(info, cases);
}

public GraphInfo makeGraph(GraphInfo info, \case(_)) {
	dprintln("Case");
	return insertShortcut(info);
}

public GraphInfo makeGraph(GraphInfo info, \defaultCase()) {
	dprintln("Default");
	return insertShortcut(info);
}

public GraphInfo makeGraph(GraphInfo info, \for(_, _, body)) {
	dprintln("For");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \for(_, _, _, body)) {
	dprintln("For-Conditional");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \foreach(_, _, body)) {
	dprintln("Foreach");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \do(body, _)) {
	dprintln("Do");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \while(_, body)) {
	dprintln("While");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \try(body, _)) {
	dprintln("Try");
	return makeGraph(info, body);
}

public GraphInfo makeGraph(GraphInfo info, \try(tryBody, _, finalBody)) {
	dprintln("Try-Final");
	return makeGraph(makeGraph(info, tryBody), finalBody);
}

// TODO Not picked up ....
public GraphInfo makeGraph(GraphInfo info, \catch(_, body)) {
	dprintln("Catch");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, Statement stmt) {
	return info;
}

public GraphInfo makeGraph(GraphInfo info, list[Statement] stmts) {
	for (stmt <- stmts) {
		info = makeGraph(info, stmt);
	}
	return info;
}
