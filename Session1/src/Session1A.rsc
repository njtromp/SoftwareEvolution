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

public int cyclomaticComplexityCWI(Statement stmt) {
	// From: https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity
	// See authors :-)
    int cc = 1;
    visit (stmt) {
        case \if(_,_) : cc += 1;
        case \if(_,_,_) : cc += 1;
        case \case(_) : cc += 1;
        case \defaultCase() : cc += 1;
        case \do(_,_) : cc += 1;
        case \while(_,_) : cc += 1;
        case \for(_,_,_) : cc += 1;
        case \for(_,_,_,_) : cc += 1;
        case foreach(_,_,_) : cc += 1;
        case \catch(_,_): cc += 1;
        case \conditional(_,_,_): cc += 1;
        case infix(_,"&&",_) : cc += 1;
        case infix(_,"||",_) : cc += 1;
    }
    return cc;
} 

public int cyclomaticComplexity(Statement stmt) {
	return cyclomaticComplexity(makeGraph(stmt));
	//return cyclomaticComplexityCWI(stmt);	
}

alias SLOCInfo = tuple[str name, int sloc];

bool orderSlocs(SLOCInfo si1, SLOCInfo si2) {
	switch (<si1.sloc > si2.sloc, si1.name > si2.name>) {
		case <true, _> : return true;
		case <false, true> : return true;
		default : return false;
	} 
}

public int sloc(Statement stmt) {
	return countLines(stmt);
}

public int sloc(Declaration decl) {
	return countLines(decl);
}

public int sloc(list[Declaration] decls) {
	return ( 0 | it + countLines(decl) | decl <- decls);
}

public int sloc(set[Declaration] decls) {
	return ( 0 | it + countLines(decl) | decl <- decls);
}

public int countLines(value body) {
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
	//enterDebug(false);
	
	ast = createAstsFromEclipseProject(|project://Session1|, true);
	//ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	//ast = createAstFromFile(|project://SmallSql/src/smallsql/database/ExpressionFunctionTan.java|, true);
	//text(ast);
	int totalLines = 0;
	//visit (ast) {
	//	case class(name, _, _, body) : {
	//		totalLines += sloc(body);
	//	}
	//}
	totalLines = sloc(ast);
	println("Total loc [<totalLines>]");
	println("SLOC (new) [<sloc(ast)>]");
	visit (ast) {
		case m:method(_, name, _, _, stmt) : {
			println("Metrics for [<name>] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
			//if (name == "graphCheck") text(m);
		}
		case constructor(name, _, _, stmt) : println("Metrics [Constructor] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
		case initializer(stmt) : println("Metrics [Init] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
	}

	list[SLOCInfo] locs = [];
	visit (ast) {
		case class(name, _, _, body) : {
			locs += <name, sloc(body)>;
		}
	}
	//text(sort(locs, orderSlocs));
	println((0 | it + l | <m, l> <- locs));

	println("Done");
	
	//exitDebug();
}
