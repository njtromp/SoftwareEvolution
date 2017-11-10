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
//import CyclomaticComplexity;

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

public GraphInfo makeGraph(GraphInfo info, \block(stmts)) {
	for (stmt <- stmts) {
		info = makeGraph(insertBlock(info), stmt);
	}
	return info;
}

public GraphInfo makeGraph(GraphInfo info, \if(_, ifBlock)) {
	return makeGraph(insertShortcut(info), ifBlock);
}

public GraphInfo makeGraph(GraphInfo info, \for(_, _, _, block)) {
	return makeGraph(insertShortcut(info), block);
}

public GraphInfo makeGraph(GraphInfo info, Statement stmt) {
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
	println("Total LOC [<totalLines>]");
	visit (ast) {
		case method(_, name, _, _, stmt) : println("[<name>] = [<sloc(stmt)>, <cyclomaticComplexity(stmt)>]");
		case constructor(name, _, _, stmt) : println("[Constructor] = [<sloc(stmt)>, <cyclomaticComplexity(stmt)>]");
		case initializer(stmt) : println("[Init] = [<sloc(stmt)>, <cyclomaticComplexity(stmt)>]");
	}
	println("Total LOC [<totalLines>]");
	//visit (ast) {
	//	case method(_, name, _, _, stmt) : {
	//		//if (name == "containsLetter") {
	//			//println("CC = [<cyclomaticComplexity(stmt)>]");
	//		//}
	//	}
	//}
	println("Done");
}
