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
import DebugPrint;

alias GraphInfo = tuple[int top, int bottom, int last, Graph[int] graph];

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

public int cyclomaticComplexity(Statement stmt) {
	GraphInfo info = makeGraph(<1, 2, 2, {<1,2>}>, stmt);
	//iprintln(info.graph);
	return cyclomaticComplexity(info.graph);
	
	//// From: https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity
	//// See authors :-)
 //   int result = 1;
 //   visit (stmt) {
 //       case \if(_,_) : result += 1;
 //       case \if(_,_,_) : result += 1;
 //       case \case(_) : result += 1;
 //       case \defaultCase() : result += 1;
 //       case \do(_,_) : result += 1;
 //       case \while(_,_) : result += 1;
 //       case \for(_,_,_) : result += 1;
 //       case \for(_,_,_,_) : result += 1;
 //       case foreach(_,_,_) : result += 1;
 //       case \catch(_,_): result += 1;
 //       case \conditional(_,_,_): result += 1;
 //       case infix(_,"&&",_) : result += 1;
 //       case infix(_,"||",_) : result += 1;
 //   }
 //   return result;
}

alias SLOCInfo = tuple[str name, int sloc];

bool orderSlocs(SLOCInfo si1, SLOCInfo si2) {
	switch (<si1.sloc > si2.sloc, si1.name > si2.name>) {
		case <true, _> : return true;
		case <false, true> : return true;
		default : return false;
	} 
}

public int sloc(value body) {
	set[int] methodLines = {};
	visit(body) {
		case /loc l : if (l.scheme == "project") {
			methodLines += {l.begin.line};
			methodLines += {l.end.line};
		}
	}
	return size(methodLines);
}

public void testing() {
	enterDebug(false);
	
	ast = createAstsFromEclipseProject(|project://Session1|, true);
	//ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	//ast = createAstFromFile(|project://SmallSql/src/smallsql/database/ExpressionFunctionTan.java|, true);
	//text(ast);
	int totalLines = 0;
	visit (ast) {
		case class(name, _, _, body) : {
			totalLines += sloc(body);
		}
	}
	println("Total loc [<totalLines>]");
	println("SLOC (new) [<sloc(ast)>]");
	visit (ast) {
		case method(_, name, _, _, stmt) : println("Metrics for [<name>] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)>]");
		case constructor(name, _, _, stmt) : println("Metrics [Constructor] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)>]");
		case initializer(stmt) : println("Metrics [Init] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)>]");
	}

	list[SLOCInfo] locs = [];
	visit (ast) {
		case class(name, _, _, body) : {
			locs += <name, sloc(body)>;
		}
	}
	//text(sort(locs, orderSlocs));

	println("Done");
	
	exitDebug();
}
