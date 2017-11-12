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
import ControlFlowGraph;

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
