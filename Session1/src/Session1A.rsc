module Session1A

import IO;
import Set;
import List;
import String;
import Relation;
import util::Math;
import util::ValueUI;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import demo::McCabe; // :-) Lets see what we can do with it...
import DebugPrint;
import SLOC;
import ControlFlowGraph;

public map[str, int] cwiStats = ();
public map[str, int] graphStats = ();

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

public void testing() {
	//enterDebug(false);
	
	println("Creating ASTs");
	//ast = createAstsFromEclipseProject(|project://Session1|, true);
	ast = createAstFromFile(|project://SmallSql/src/smallsql/database/ExpressionArithmetic.java|, true);
	//ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	//ast = createAstsFromEclipseProject(|project://HsqlDB|, true);
	println("ASTs created");

	//text(ast);
	//int totalLines = 0;
	//visit (ast) {
	//	case class(name, _, _, body) : {
	//		totalLines += sloc(body);
	//	}
	//}
	//println("Total loc [<totalLines>]");
	//println("SLOC (new) [<sloc(ast)>]");
	int count = 0;
	int maxError = 0;
	visit (ast) {
		case m:method(_, name, _, _, stmt) : {
			if (name == "getBoolean") {
				count += 1;
				if (count == 14) {
					println("There we go...");
				}
			}
			cc = cyclomaticComplexity(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			maxError = max(maxError, abs(cc-ccwi)); 
			if (abs(cc - ccwi) > 5)
				println("Metrics for [<name>] = [loc:<sloc(stmt)>, cc:<cc> (<ccwi>)] <count>");
			//if (name == "graphCheck") text(m);
		}
		//case constructor(name, _, _, stmt) : println("Metrics [Constructor] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
		//case initializer(stmt) : println("Metrics [Init] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
	}
	println("Max error [<maxError>]");

	//list[SLOCInfo] locs = [];
	//visit (ast) {
	//	case class(name, _, _, body) : {
	//		locs += <name, sloc(body)>;
	//	}
	//}
	////text(sort(locs, orderSlocs));
	//println((0 | it + l | <m, l> <- locs));

	println("Done");
	
	//exitDebug();
}
