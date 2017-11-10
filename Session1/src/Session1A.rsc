module Session1A

import IO;
import Set;
import List;
import String;
import Relation;
import util::ValueUI;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import analysis::graphs::Graph;
import demo::McCabe; // :-) Lets see what we can do with it...

public int sloc(value body) {
	set[int] methodLines = {};
	visit(body) {
		case /loc l : if (l.scheme == "project") {
			methodLines += {l.begin.line, l.end.line};
		}
	}
	return size(methodLines);
}

alias GraphInfo = tuple[int top, int bottom, int last, Graph[int] graph];

public GraphInfo insertBlock(GraphInfo info) {
	Graph[int] g = info.graph;
	// Remove inner connection
	g -= <info.top, info.bottom>;
	// Replace with extra connections
	g += <info.top, info.last+1>;
	g += <info.last+1, info.last+2>;
	g += <info.last+2, info.bottom>;
	// Continue at new inserted connection
	return <info.last+1, info.last+2, info.last+2, g>;
}

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
		info = makeGraph(insertBlock(info), stmt);
	}
	return info;
}

public GraphInfo makeGraph(GraphInfo info, \if(_, ifBlock)) {
	println("If");
	return makeGraph(insertShortcut(info), ifBlock);
}

public GraphInfo makeGraph(GraphInfo info, \if(_, ifBlock, elseBlock)) {
	println("If-Else");
	partialGraph = makeGraph(insertChoice(info), ifBlock);
	return makeGraph(<info.last+5, info.last+6, partialGraph.last, partialGraph.graph>, elseBlock);
}

public GraphInfo makeGraph(GraphInfo info, \switch(_, cases)) {
	println("Switch");
	return makeGraph(info, cases);
}

public GraphInfo makeGraph(GraphInfo info, \case(_)) {
	println("Case");
	return insertShortcut(info);
}

public GraphInfo makeGraph(GraphInfo info, \defaultCase()) {
	println("Default");
	return insertShortcut(info);
}

public GraphInfo makeGraph(GraphInfo info, \for(_, _, body)) {
	println("For");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \for(_, _, _, body)) {
	println("For-Conditional");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \foreach(_, _, body)) {
	println("Foreach");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \do(body, _)) {
	println("Do");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \while(_, body)) {
	println("While");
	return makeGraph(insertShortcut(info), body);
}

public GraphInfo makeGraph(GraphInfo info, \try(body, _)) {
	println("Try");
	return makeGraph(info, body);
}

public GraphInfo makeGraph(GraphInfo info, \try(tryBody, _, finalBody)) {
	println("Try-Final");
	return makeGraph(insertShortcut(makeGraph(info, tryBody)), finalBody);
}

public GraphInfo makeGraph(GraphInfo info, \catch(_, body)) {
	println("Catch");
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

public int cyclomaticComplexity(Statement stmt) {
	GraphInfo info = makeGraph(<1, 2, 2, {<1,2>}>, stmt);
	return cyclomaticComplexity(info.graph);
}

public void testing() {
	ast = createAstsFromEclipseProject(|project://Session1|, true);
	//ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	int totalLines = 0;
	visit (ast) {
		case class(name, _, _, body) : {
			totalLines += sloc(body);
		}
	}
	println("Total loc [<totalLines>]");
	visit (ast) {
		case method(_, name, _, _, stmt) : println("Metrics for [<name>] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)>]");
		case constructor(name, _, _, stmt) : println("Metrics [Constructor] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)>]");
		case initializer(stmt) : println("Metrics [Init] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)>]");
	}
	println("Done");
}
