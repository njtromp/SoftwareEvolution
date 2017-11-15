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

public int cyclomaticComplexityCWI(Statement stmt) {
	// From: https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity
	// See authors :-)
    int cc = 1;
	void count(str action) {
        cwiStats[action] ? 0 += 1;
        cc += 1;
    }
    visit (stmt) {
        case \if(_,_) : count("If");
        case \if(_,_,_) : count("If-Else");
        case \case(_) :  count("Case");
        case \defaultCase() :  count("Default");
        case \do(_,_) :  count("Do");
        case \while(_,_) :  count("While");
        case \for(_,_,_) :  count("For");
        case \for(_,_,_,_) : count("For-Conditional");
        case foreach(_,_,_) : count("Foreach");
        case \catch(_,_): count("Catch");
        case \conditional(_,_,_) : 
        		count("Conditional");
        case infix(_,"&&",_) : count("Infix-&&");
        case infix(_,"||",_) : count("Infix-||");
    }
    return cc;
} 

public int cyclomaticComplexity(Statement stmt) {
	return cyclomaticComplexity(makeGraph(stmt));
}

public data Metrics = Metrics(int sloc, int cc, int ccwi);

public void testing() {
	
	println("Creating ASTs");
	//ast = createAstsFromEclipseProject(|project://Session1|, true);
	//ast = createAstFromFile(|project://SmallSql/src/smallsql/database/ExpressionArithmetic.java|, true);
	ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	//ast = createAstsFromEclipseProject(|project://HsqlDB|, true);
	println("ASTs created");

	println("Analysing...");
	int count = 0;
	int maxDifference = 0;
	str maxDiffMethodName = "";
	cwiStats = ();
	ccStats = (); // is declared in ControlFlowGraph!
	str fullMethodName = "";
	
	list[Metrics] metrics = [];
	visit (ast) {
		case m:method(_, name, _, _, stmt) : {
			methodName = name;
			//println("<packageName>/<className>/<methodName>");
			cc = cyclomaticComplexity(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += Metrics(sloc(stmt), cc, ccwi);
			if (maxDifference < abs(cc - ccwi)) {
				maxDifference = abs(cc - ccwi);
				fullMethodName = m.decl.path;
			} 
			//if (abs(cc - ccwi) > 5)
			//	println("Metrics for [<name>] = [loc:<sloc(stmt)>, cc:<cc> (<ccwi>)] <count>");
		}
		//case constructor(name, _, _, stmt) : println("Metrics [Constructor] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
		//case initializer(stmt) : println("Metrics [Init] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexity(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
	}
	println("Analysis done.");
	
	//println("Max CC difference [<maxDifference>] occured in [<fullMethodName>]");
	//println("========== CWI =============");
	//println(cwiStats);
	//println("=========== CC =============");
	//println(ccStats);
	
	totalSLOC = sloc(ast);
	totalMethodSLOC = ( 0 | it + m.sloc | m <- metrics);
	println("Total SLOC [<totalSLOC>]");
	if (totalSLOC < 66000) {
		println("Volume: ++");
	} else if (totalSLOC < 246000) {
		println("Volume: +");
	} else if (totalSLOC < 665000) {
		println("Volume: o");
	} else if (totalSLOC < 1310000) {
		println("Volume: -");
	} else {
		println("Volume: --");
	}
		
	list[Metrics] lowRiskMethods = [];
	list[Metrics] moderateRiskMethods = [];
	list[Metrics] highRiskMethods = [];
	list[Metrics] veryHighRiskMethods = [];
	for (m <- metrics) {
		if (m.ccwi <= 10) {
			lowRiskMethods += m;
		} else if (m.ccwi <= 20) {
			moderateRiskMethods += m;
		} else if (m.ccwi <= 50) {
			highRiskMethods += m;
		} else  {
			veryHighRiskMethods += m;
		}
	}
	println("Low       <sloc(lowRiskMethods)*100/totalMethodSLOC>");
	println("Mod       <sloc(moderateRiskMethods)*100/totalMethodSLOC>");
	println("High      <sloc(highRiskMethods)*100/totalMethodSLOC>");
	println("Very High <sloc(veryHighRiskMethods)*100/totalMethodSLOC>");
	
	//if (sloc(veryHighRiskMethods)*100/totalMethodSLOC == 5) {
	//	println("Complexity: ++");
	//} else if (sloc(veryHighRiskMethods)*100/totalMethodSLOC > 0) {
	//	println("Complexity: -");
	//} else if (sloc(veryHighRiskMethods)*100/totalMethodSLOC > 10) {
	//	println("Complexity: o");
	//} else if (sloc(veryHighRiskMethods)*100/totalMethodSLOC > 0) {
	//	println("Complexity: +");
	//} else if (sloc(veryHighRiskMethods)*100/totalMethodSLOC > 0) {
	//	println("Complexity: ++");
	//}
	

	println("Done");
	
}

public int sloc(list[Metrics] metrics) {
	return ( 0 | it + m.sloc | m <-metrics);
}
